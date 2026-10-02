import SwiftUI
import AuthenticationServices

public struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authService: AuthService = AuthService.shared

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegistering: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 20)

                    // Official Luma Logo
                    LumaLogoView(size: 84, showCardBackground: true, isAnimated: true)
                        .padding(.top, 10)

                    VStack(spacing: 6) {
                        Text(isRegistering ? "Crear cuenta Luma" : "Iniciar Sesión en Luma")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Sincroniza tus letras, traducciones en vivo y modelos neuronales.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Error banner
                    if let error = authService.authError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal, 24)
                    }

                    // Apple Sign In Button
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            authService.handleAppleSignIn(result: result)
                            if authService.isAuthenticated {
                                dismiss()
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(14)
                    .padding(.horizontal, 24)

                    // Divider
                    HStack {
                        Rectangle().fill(Color(.systemGray4)).frame(height: 1)
                        Text("o con correo")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        Rectangle().fill(Color(.systemGray4)).frame(height: 1)
                    }
                    .padding(.horizontal, 24)

                    // Email & Password Fields
                    VStack(spacing: 14) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            TextField("Correo electrónico", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            SecureField("Contraseña", text: $password)
                        }
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)

                    // Submit Button
                    Button {
                        Task {
                            let success = await authService.loginWithEmail(email: email, password: password)
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            if authService.isAuthenticating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(isRegistering ? "Crear Cuenta" : "Entrar")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(14)
                        .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .disabled(authService.isAuthenticating)
                    .padding(.horizontal, 24)

                    // Guest Login Option
                    Button {
                        authService.loginAsGuest()
                        dismiss()
                    } label: {
                        Text("Continuar sin cuenta (Modo Local)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    Spacer(minLength: 20)

                    // Cloudflare Edge footer badge
                    HStack(spacing: 6) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("Conectado a Cloudflare Edge • Actualizaciones OTA activas")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
