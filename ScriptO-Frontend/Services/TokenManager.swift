import Foundation

/*
 TokenManager.swift
 
 A singleton service responsible for managing authentication tokens in the ScriptO application.
 This manager handles the storage, retrieval, and clearing of JWT tokens using UserDefaults
 for persistent storage across app sessions.
 
 Key Responsibilities:
 - Secure token storage in UserDefaults
 - Token retrieval for API authentication
 - Token clearing for logout functionality
 - Debug logging for token operations
*/

class TokenManager {
    static let shared = TokenManager()
    private var token: String?
    
    func saveToken(_ token: String) {
        self.token = token
    }
    
    func getToken() -> String? {
        return token
    }
    
    func clearToken() {
        token = nil
    }
} 