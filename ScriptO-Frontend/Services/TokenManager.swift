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

public class TokenManager {
    public static let shared = TokenManager()
    private let tokenKey = "authToken"
    
    public func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        print("🔑 Token saved: \(token)")
    }
    
    public func getToken() -> String? {
        let token = UserDefaults.standard.string(forKey: tokenKey)
        print("🔑 Token retrieved: \(token ?? "nil")")
        return token
    }
    
    public func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        print("🔑 Token cleared")
    }
} 