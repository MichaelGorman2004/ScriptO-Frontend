import Foundation
import SwiftUI
import CoreGraphics


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
    
    func saveNote(_ note: Note) async throws -> Note {
        let endpoint = note.id == UUID() ? "/notes/" : "/notes/\(note.id)"
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            print("❌ Invalid URL constructed: \(baseURL)\(endpoint)")
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = note.id == UUID() ? "POST" : "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Configure URLSession to handle redirects
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Accept": "application/json"]
        config.httpShouldSetCookies = true
        config.urlCredentialStorage = nil  // Prevent credential persisting
        let session = URLSession(configuration: config)
        
        // Add authentication token
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        // Prepare note data
        let noteData = [
            "title": note.title,
            "tags": note.tags,
            "subject": note.subject,
            "content": note.content.map { element in
                var elementDict: [String: Any] = [
                    "type": element.type,
                    "content": [   // Make content a single dictionary instead of array
                        "points": element.optimizedContent().map { point in
                            [
                                "x": point.x,
                                "y": point.y,
                                "pressure": point.pressure
                            ]
                        }
                    ],
                    "bounds": [
                        "x": element.bounds.origin.x,
                        "y": element.bounds.origin.y,
                        "width": element.bounds.size.width,
                        "height": element.bounds.size.height
                    ]
                ]
                
                if let properties = element.strokeProperties {
                    elementDict["stroke_properties"] = [
                        "color": properties.color,
                        "width": properties.width
                    ]
                }
                
                return elementDict
            }
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: noteData)
        
        do {
            print("📝 Debug: Sending request with body length: \(request.httpBody?.count ?? 0)")
            let (data, response) = try await session.data(for: request)
            print("📝 Debug: Received response with data length: \(data.count)")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            
            if httpResponse.statusCode == 307 {
                if let location = httpResponse.allHeaderFields["Location"] as? String {
                    print("📝 Debug: Redirect location: \(location)")
                }
            }
            
            guard httpResponse.statusCode == 200 else {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    print("❌ Server error (\(httpResponse.statusCode)): \(errorResponse.message)")
                    throw APIError.customError(errorResponse.message)
                }
                print("❌ Invalid response (Status \(httpResponse.statusCode))")
                // Print response body for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
                throw APIError.invalidResponse
            }
            
            // Parse API response with the updated APIResponse type
            let apiResponse: APIResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            guard let noteData = apiResponse.data else {
                throw APIError.invalidResponse
            }
            
            // Convert the AnyCodable data back to a dictionary
            let noteDict = noteData.mapValues(\.value)
            
            // Convert dictionary to Note
            let jsonData = try JSONSerialization.data(withJSONObject: noteDict)
            let savedNote: Note = try JSONDecoder().decode(Note.self, from: jsonData)
            return savedNote
        } catch let error as URLError where error.code == .cannotConnectToHost {
            print("❌ Connection refused. Is the server running at \(baseURL)?")
            throw APIError.customError("Cannot connect to server. Please check if the server is running.")
        } catch {
            print("📝 Debug: Detailed error: \(error)")
            throw APIError.customError("Network error: \(error.localizedDescription)")
        }
    }
    
    func checkServerStatus() async -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            return false
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(for: URLRequest(url: url))
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
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

// Replace the current APIResponse struct with this updated version
struct APIResponse: Codable {
    let success: Bool
    let message: String
    let data: [String: AnyCodable]?
    let metadata: [String: String]?
}

// Add this new struct to handle dynamic JSON values
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map(\.value)
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues(\.value)
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map(AnyCodable.init))
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues(AnyCodable.init))
        default:
            try container.encodeNil()
        }
    }
} 