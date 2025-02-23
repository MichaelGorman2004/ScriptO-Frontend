import Foundation
import SwiftUI

// Import local models and services
@_exported import struct CoreGraphics.CGRect
@_exported import struct CoreGraphics.CGFloat

// Import models
// @_exported import Models // Add this if you have a Models module
// Otherwise, make sure Note.swift and APIError.swift are in your project

/*
 APIClient.swift
 
 The primary networking layer for the ScriptO application. This client handles all API
 communications with the backend server, managing authentication, request formatting,
 and response handling. It includes comprehensive error handling and debug logging.
 
 Key Features:
 - RESTful API communication
 - JWT token authentication
 - JSON encoding/decoding
 - Error handling and logging
 - Preview mode support for SwiftUI previews
 - ISO8601 date formatting
*/

class APIClient {
    static let shared = APIClient()
    let baseURL = "http://localhost:8000/api/v1"
    
    #if DEBUG
    var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    #endif
    
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }()
    
    func setAuthToken(_ token: String) {
        TokenManager.shared.saveToken(token)
        print("Auth token set in APIClient: \(token)")
    }
    
    func getAuthHeader() -> String? {
        guard let token = TokenManager.shared.getToken() else {
            print("No auth token found in TokenManager")
            return nil
        }
        return "Bearer \(token)"
    }
    
    func createNote(_ note: Note) async throws -> Note {
        print("📝 Creating note with title: \(note.title)")
        print("🔑 Token status: \(TokenManager.shared.getToken() != nil ? "Found" : "Missing")")
        
        #if DEBUG
        if isPreview {
            print("Preview mode: Simulating note creation")
            return note
        }
        #endif
        
        print("Starting note creation...")
        
        guard let url = URL(string: "\(baseURL)/notes") else {
            print("❌ Invalid URL: \(baseURL)/notes")
            throw APIError.invalidURL
        }
        print("📍 Using URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        guard let token = TokenManager.shared.getToken() else {
            print("❌ No auth token found")
            throw APIError.unauthorized
        }
        print("🔑 Found auth token: \(token)")
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try jsonEncoder.encode(note)
            print("📤 Request body:")
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print(jsonString)
            }
            
            print("⏳ Making request to: \(url)")
            let (data, response) = try await URLSession.shared.data(for: request)
            print("✅ Received response")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw APIError.invalidResponse
            }
            
            print("📥 Response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                print("✅ Success! Decoding response...")
                return try jsonDecoder.decode(Note.self, from: data)
            case 401:
                print("❌ Unauthorized - clearing token")
                TokenManager.shared.clearToken()
                throw APIError.unauthorized
            default:
                if let errorResponse = try? jsonDecoder.decode(ErrorResponse.self, from: data) {
                    print("❌ Server error: \(errorResponse.message)")
                    throw APIError.customError(errorResponse.message)
                }
                print("❌ Invalid response")
                throw APIError.invalidResponse
            }
        } catch {
            print("❌ Error creating note: \(error)")
            throw error
        }
    }
    
    // Add other API methods as needed
}

// Add this extension to handle the date formatting
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
} 