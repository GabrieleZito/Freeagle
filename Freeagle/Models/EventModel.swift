//
//  EventModel.swift
//  Freeagle
//
//  Created by Gabriele Zito on 21/07/25.
//

//"id": "DEmbG4NATBH7eYi95f",
//    "title": "Palermo International Half Marathon & 10K",
//    "description": "Sourced from predicthq.com",
//    "category": "sports",
//    "startDate": "2025-10-19",
//    "startTime": "09:30:00",
//    "latitude": 38.1995197,
//    "longitude": 13.3285416,
//    "address": "Viale Regina Elena, 90151 Palermo, Italy"

import Foundation

struct Event: Codable, Identifiable{
    var id: String
    var title: String
    var description: String
    var category: String
    var startDate: String
    var startTime: String
    var latitude: Double
    var longitude: Double
    var address: String
}

