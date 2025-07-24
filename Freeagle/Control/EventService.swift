//
//  EventService.swift
//  Freeagle
//
//  Created by Gabriele Zito on 24/07/25.
//
import Foundation

struct eventService {
    private let baseURL: String = "https://afp-server-g7j1.onrender.com"
    //private let baseURL: String = "http://localhost:3000"
    
    func fetchEvents() async throws -> [Event] {
        let url = URL(string: "\(baseURL)/events/all")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let events = try JSONDecoder().decode([Event].self, from: data)
        return events
    }
}
