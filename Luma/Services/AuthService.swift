import Foundation
import Combine
import AuthenticationServices

public final class AuthService: ObservableObject {
    public static let shared = AuthService()

    @Published public var currentUser: UserSession?
    @Published public var isAuthenticated: Bool = false
    @Published public var authError: String?
    @Published public var isAuthenticating: Bool = false

    private let userDefaultsKey = "Luma_CurrentUser_Session"

    private init() {
        loadStoredSession()
    }

    private func loadStoredSession() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let session = try? JSONDecoder().decode(UserSession.self, from: data) {
            self.currentUser = session
            self.isAuthenticated = true
        } else {
            // Default demo authenticated user so the app is immediately fully usable
            let defaultUser = UserSession(
                id: "usr_luma_prime",
                email: "usuario@luma.ai",
                fullName: "Usuario Luma",
                isPro: true,
                authToken: "cf_token_live_sec_9941a",
                authProvider: .apple
            )
            self.currentUser = defaultUser
            self.isAuthenticated = true
            saveSession(defaultUser)
        }
    }

    public func loginWithEmail(email: String, password: String) async -> Bool {
        await MainActor.run {
            self.isAuthenticating = true
            self.authError = nil
        }

        // Basic verification
        guard email.contains("@") && email.contains(".") else {
            await MainActor.run {
                self.authError = "Ingresa un correo electrónico válido"
                self.isAuthenticating = false
            }
            return false
        }

        guard password.count >= 6 else {
            await MainActor.run {
                self.authError = "La contraseña debe tener al menos 6 caracteres"
                self.isAuthenticating = false
            }
            return false
        }

        // Simulate network exchange with Cloudflare Worker auth endpoint
        try? await Task.sleep(nanoseconds: 600_000_000)

        let session = UserSession(
            id: UUID().uuidString,
            email: email,
            fullName: email.components(separatedBy: "@").first?.capitalized ?? "Usuario",
            isPro: true,
            authToken: "cf_jwt_\(UUID().uuidString.prefix(12))",
            authProvider: .email
        )

        await MainActor.run {
            self.currentUser = session
            self.isAuthenticated = true
            self.isAuthenticating = false
            self.saveSession(session)
        }

        return true
    }

    public func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                let email = appleIDCredential.email ?? "apple.user@privaterelay.appleid.com"
                let nameComponents = appleIDCredential.fullName
                let fullName = [nameComponents?.givenName, nameComponents?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")

                let session = UserSession(
                    id: userId,
                    email: email,
                    fullName: fullName.isEmpty ? "Usuario de Apple" : fullName,
                    isPro: true,
                    authToken: "cf_apple_tok_\(UUID().uuidString.prefix(10))",
                    authProvider: .apple
                )

                self.currentUser = session
                self.isAuthenticated = true
                self.saveSession(session)
            }
        case .failure(let error):
            self.authError = error.localizedDescription
        }
    }

    public func loginAsGuest() {
        let guestSession = UserSession(
            id: "guest_\(UUID().uuidString.prefix(6))",
            email: "invitado@luma.local",
            fullName: "Invitado",
            isPro: false,
            authToken: nil,
            authProvider: .guest
        )
        self.currentUser = guestSession
        self.isAuthenticated = true
        saveSession(guestSession)
    }

    public func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    private func saveSession(_ session: UserSession) {
        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
