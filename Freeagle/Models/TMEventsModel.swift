//
//  TMEventsModel.swift
//  Freeagle
//
//  Created by Gabriele Zito on 21/07/25.
//

import Foundation

struct TicketMasterResponse: Codable {
    let embedded: EmbeddedEvents
    let links: Links
    let page: Page
    
    enum CodingKeys: String, CodingKey{
        case embedded = "_embedded"
        case links = "_links"
        case page
    }
}

struct EmbeddedEvents: Codable{
    let events: [Event]
}

struct Event: Codable, Identifiable{
    let name: String
    let type: String
    let id: String
    let test: Bool
    let url: String
    let locale: String
    let images: [Images]
    let sales: Sale
    let dates: DateInfo
    let classifications: [Classification]
    let _links: EventLink
    let _embedded: EventEmbedded
    
    var thumbnailURL: String?{
        images.first(where: {$0.ratio == "16_9" && $0.width >= 640})?.url
    }
    var venueName: String?{
        _embedded.venues?.first?.name
    }
}

struct EventEmbedded: Codable{
    let venues: [Venue]?
    let attactions: [Attraction]?
}

struct Attraction: Codable{
    let name: String
    let type: String
    let id: String
    let test: Bool
    let url: String
    let locale: String
    let images: [Images]
    let classifications: Classification
    let upcomingEvents: UpcomingEvents
    let _links: Links
    //externalLinks
}

struct Venue: Codable{
    let name: String
    let type: String
    let id: String
    let test: Bool
    let locale: String
    let postalCode: String?
    let city: City
    let country: Country
    let location: Location?
    let upcomingEvents: UpcomingEvents?
    let _links: Links
}

struct UpcomingEvents: Codable{
    let mfxit: Int?
    let _total: Int
    let _filtered: Int
    
    enum CodingKeys: String, CodingKey{
        case mfxit = "mfx-it"
        case _total, _filtered
    }
}

struct Location: Codable{
    let longitude: String
    let latitude: String
}

struct Country: Codable{
    let name: String
    let countryCode: String
}

struct City: Codable{
    let name: String
}

struct EventLink: Codable{
    let selfLink: Link?
    let attractions: [Link]?
    let venues: [Link]?
}

struct Classification: Codable{
    let primary: Bool
    let segment: Category
    let genre: Category
    let subGenre: Category
    let type: Category
    let subType: Category
    let family: Bool
}

struct Category: Codable{
    let id: String
    let name: String
}

struct DateInfo: Codable{
    let start: DateStart
    let timezone: String
    let status: Status
    let spanMultipleDays: Bool
}

struct DateStart: Codable{
    let localDate: String
    let localTime: String
    let dateTime: String
    let dateTBD: Bool
    let dateTBA: Bool
    let timeTBA: Bool
    let noSpecificTime: Bool
}

struct Status: Codable{
    let code: String
}

struct Sale: Codable{
    let pub: SaleInfo
    
    enum CodingKeys: String, CodingKey{
        case pub = "public"
    }
}

struct SaleInfo: Codable{
    let startDateTime: String
    let endDateTime: String
    let startTBD: Bool
    let startTBA: Bool
}

struct Images: Codable{
    let ratio: String
    let url: String
    let width: Int
    let height: Int
    let fallback: Bool
}

struct Links: Codable{
    let first: Link?
    let selfLink: Link?
    let next: Link?
    let last: Link?
    
    enum CodingKeys: String, CodingKey{
        case first
        case selfLink = "self"
        case next
        case last
    }
}

struct Link: Codable{
    let href: String?
}

struct Page: Codable{
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let number: Int
}
