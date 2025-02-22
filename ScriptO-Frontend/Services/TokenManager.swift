import Foundation

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