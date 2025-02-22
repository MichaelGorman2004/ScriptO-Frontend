import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case unauthorized
    case decodingError(Error)
    case customError(String)
}

struct ErrorResponse: Codable {
    let success: Bool
    let message: String
} 