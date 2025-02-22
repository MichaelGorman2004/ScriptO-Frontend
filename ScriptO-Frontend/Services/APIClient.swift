import Foundation

class APIClient {
    static let shared = APIClient()
    let baseURL = "http://localhost:8000/api/v1"
    private var authToken: String?
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func createNote(_ note: Note) async throws -> Note {
        guard let url = URL(string: "\(baseURL)/notes") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(note)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            return try decoder.decode(Note.self, from: data)
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.invalidResponse
        }
    }
    
    // Add other API methods as needed
} 