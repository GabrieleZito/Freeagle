//
//  UserService.swift
//  Freeagle
//
//  Created by Gabriele Zito on 21/07/25.
//

import Foundation
import ParthenoKit

struct APIService {
    //private let baseURL: String = "https://afp-server-g7j1.onrender.com"
    private let baseURL: String = "http://localhost:3000"
    
    func getUserByUsername(username: String) async throws -> User?{
        guard let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(baseURL)/users/username/\(encodedUsername)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if data.isEmpty || data == Data("null".utf8) {
            return nil
        }
        let decoded = try JSONDecoder().decode(User.self, from: data)
        return decoded
    }
    
    func getUser(username: String) async throws -> Bool{
        let url = URL(string: "\(baseURL)/users/getUser/\(username)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotParseResponse)
        }
        
        let boolValue = responseString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true"
        return boolValue
    }
    
    
    
    func setUser(username: String) async throws{
        let url = URL(string: "\(baseURL)/users/newUser/\(username)")!
        let (_, _) = try await URLSession.shared.data(from: url)
    }
    
    func joinEvent(inviteCode: String, username: String, participate: Bool) async throws -> Bool{
        let invite = inviteCode.split(separator: "-")
        let eventId = invite[0]
        let inviter = invite[1]
        let url = URL(string: "\(baseURL)/events/\(eventId)/\(inviter)/\(username)/\(participate)")!
        
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotParseResponse)
        }
        
        let boolValue = responseString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true"
        return boolValue
    }
    
    
    
    func newEvent(event: Event) async throws{
        let url = URL(string: "\(baseURL)/events/newEvent")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(event)
        print(encoded)
        request.httpBody = encoded
        
        let (_, _) = try await URLSession.shared.data(for: request)
        //try await debugPostRequest()
    }
    func debugPostRequest() async throws {
        let url = URL(string: "\(baseURL)/events/newEvent")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create your body
        let requestBody = [
            "key": "value",
            "name": "test"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            // Debug: Print what we're sending
            print("Request URL: \(url.absoluteString)")
            print("Request Method: \(request.httpMethod ?? "nil")")
            print("Request Headers:")
            request.allHTTPHeaderFields?.forEach { key, value in
                print("  \(key): \(value)")
            }
            
            if let bodyData = request.httpBody {
                print("Body Data Length: \(bodyData.count) bytes")
                if let bodyString = String(data: bodyData, encoding: .utf8) {
                    print("Body Content: \(bodyString)")
                }
            } else {
                print("No body data!")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status: \(httpResponse.statusCode)")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Body: \(responseString)")
            }
            
        } catch {
            print("Error: \(error)")
        }
    }
    
    func fetchEvents() async throws -> [Event] {
        let url = URL(string: "\(baseURL)/events/all")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let events = try JSONDecoder().decode([Event].self, from: data)
        return events
    }
    
    func fetchEvents2() async throws -> PHQResponse{
        let apiKey = "x7ucXBvt0rr7VF-D7ctX_ZWoauc4miToT-RbyJis"
        
        // Add the trailing slash that the server expects
        let apiURL = "https://api.predicthq.com/v1/events/?country=IT&place.scope=PMO&category=conferences,expos,concerts,festivals,performing-arts,sports,community&limit=100"
        
        guard let url = URL(string: apiURL) else {
            throw URLError(.badURL)
        }
        
        //print("Final URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("Freeagle", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(PHQResponse.self, from: data)
        return response
    }
    
    func debugResponse(response: URLResponse, data: Data){
        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
            print("Response Headers:")
            httpResponse.allHeaderFields.forEach { key, value in
                print("  \(key): \(value)")
            }
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Body: \(responseString)")
        } else {
            print("Could not decode response as UTF-8")
            print("Raw data: \(data)")
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // PredictHQ likely uses ISO8601 dates
            
            let response = try decoder.decode(PHQResponse.self, from: data)
            print("Successfully decoded: \(response)")
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted:", context.debugDescription)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("Other decoding error: \(error)")
        }
        
    }
    
    func debugURLRequest(_ request: URLRequest) {
        print("=== URL REQUEST DEBUG ===")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("HTTP Method: \(request.httpMethod ?? "GET")")
        print("Headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            print("  \(key): \(value)")
        }
        print("Authorization header: '\(request.value(forHTTPHeaderField: "Authorization") ?? "nil")'")
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("========================")
    }
}

