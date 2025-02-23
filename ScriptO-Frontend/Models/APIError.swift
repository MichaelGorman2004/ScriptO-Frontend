import Foundation

/*
 APIError.swift
 
 Error types for the ScriptO application's networking layer.
 Provides specific error cases for different failure scenarios.
*/

public enum APIError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case customError(String)
}

public struct ErrorResponse: Codable {
    public let success: Bool
    public let message: String
    
    public init(success: Bool = false, message: String) {
        self.success = success
        self.message = message
    }
} 