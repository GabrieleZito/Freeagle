//
//  PredictHQResponse.swift
//  Freeagle
//
//  Created by Gabriele Zito on 27/07/25.
//

import Foundation

struct PHQResponse: Codable{
    var count: Int
    var next: String
    var results: [Event]
}

struct Event: Codable, Identifiable{
    var inviteCode: String?
    var id: String
    var title: String
    var description: String
    var category: String
    var entities: [Entity]
    var start_local: String
    var end_local: String
    var location: [Double]
    var geo: Geo
    var users: [User]?
    
}

struct Entity: Codable{
    var entity_id: String
    var name: String
    var type: String
    var formatted_address: String?
}

struct Geo: Codable{
    var address: Address
}

struct Address: Codable{
    var country_code: String
    var formatted_address: String
    var postCode: String?
    var locality: String?
    var region: String?
}
