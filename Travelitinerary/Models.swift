
//
//  Models.swift
//  TravelItinerary
//
//  Created by Chandan Munjal on 17/03/26.
//

import Foundation

// MARK: - Itinerary Models
struct Itinerary: Identifiable {
    let id = UUID()
    let location: String
    let days: [ItineraryDay]
}

struct ItineraryDay: Identifiable {
    let id = UUID()
    let dayNumber: Int
    let title: String
    let activities: [Activity]
}

struct Activity: Identifiable {
    let id = UUID()
    let time: String
    let title: String
    let description: String
    let emoji: String
}
