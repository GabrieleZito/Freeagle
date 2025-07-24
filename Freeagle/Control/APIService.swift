//
//  UserService.swift
//  Freeagle
//
//  Created by Gabriele Zito on 21/07/25.
//

import Foundation

struct APIService {
    private let baseURL: String = "https://afp-server-g7j1.onrender.com"
    //private let baseURL: String = "http://localhost:3000"
    
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
    
    func fetchEvents() async throws -> [Event] {
        let url = URL(string: "\(baseURL)/events/all")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let events = try JSONDecoder().decode([Event].self, from: data)
        return events
    }
}
