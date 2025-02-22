import Foundation

public enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case unauthorized
    case decodingError(Error)
    case customError(String)
}

public struct ErrorResponse: Codable {
    public let success: Bool
    public let message: String
    
    public init(success: Bool, message: String) {
        self.success = success
        self.message = message
    }
} 