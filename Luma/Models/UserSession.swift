import Foundation

public enum AuthProvider: String, Codable {
    case apple = "Apple"
    case email = "Email"
    case guest = "Invitado"
}

public struct UserSession: Identifiable, Codable, Equatable {
    public let id: String
    public var email: String
    public var fullName: String
    public var isPro: Bool
    public var avatarUrl: String?
    public var authToken: String?
    public var authProvider: AuthProvider
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        email: String,
        fullName: String,
        isPro: Bool = false,
        avatarUrl: String? = nil,
        authToken: String? = nil,
        authProvider: AuthProvider = .email,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.isPro = isPro
        self.avatarUrl = avatarUrl
        self.authToken = authToken
        self.authProvider = authProvider
        self.createdAt = createdAt
    }
}
