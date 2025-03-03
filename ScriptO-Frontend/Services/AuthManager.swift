import Foundation

/*
 AuthManager.swift
 
 Authentication service manager handling user registration and login functionality.
 This manager coordinates with the API client to process authentication requests
 and manage user sessions.
 
 Key Features:
 - User registration with email/password
 - User login with credentials
 - Token management integration
 - Error handling for auth failures
 - Response parsing and validation
*/

class AuthManager {
    static let shared = AuthManager()
    
    func register(email: String, fullName: String, password: String) async throws -> String {
        guard let url = URL(string: "\(APIClient.shared.baseURL)/users/register") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let registerData = [
            "email": email,
            "full_name": fullName,
            "password": password
        ]
        request.httpBody = try JSONEncoder().encode(registerData)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Print response for debugging
            print("Registration Response Status Code: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Registration Response: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 201, 200: // Accept both 201 (Created) and 200 (OK)
                // Try to automatically log in after successful registration
                return try await login(username: email, password: password)
            default:
                // Try to decode error message if available
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.customError(errorResponse.message)
                }
                throw APIError.invalidResponse
            }
        } catch {
            print("Registration error: \(error)")
            throw error
        }
    }
    
    func login(username: String, password: String) async throws -> String {
        guard let url = URL(string: "\(APIClient.shared.baseURL)/auth/login") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Create form data string
        let formData = "username=\(username)&password=\(password)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        request.httpBody = formData.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Print response for debugging
        print("Login Response Status Code: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Login Response: \(responseString)")
        }
        
        if httpResponse.statusCode == 200 {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            let token = loginResponse.data.accessToken
            
            // Store token in both TokenManager and APIClient
            TokenManager.shared.saveToken(token)
            APIClient.shared.setAuthToken(token)
            return token
        } else {
            // Try to decode error message if available
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.customError(errorResponse.message)
            }
            throw APIError.unauthorized
        }
    }
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let data: TokenData
    
    struct TokenData: Codable {
        let accessToken: String
        let tokenType: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
        }
    }
} 