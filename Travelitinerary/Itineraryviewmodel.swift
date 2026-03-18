
//
//  Itineraryviewmodel.swift
//  TravelItinerary
//
//  Created by Chandan Munjal on 17/03/26.
//

import Foundation
import Combine

@MainActor
class ItineraryViewModel: ObservableObject {
    @Published var itinerary: Itinerary?
    @Published var isGenerating = false
    @Published var errorMessage: String?

    private let geminiService = GeminiService()

    func generateItinerary(location: String, radiusKm: Int, days: Int) async {
        guard !location.isEmpty else {
            errorMessage = "Please enter a location."
            return
        }

        isGenerating = true
        errorMessage = nil
        itinerary = nil

        do {
            let result = try await geminiService.generateItinerary(
                location: location,
                radiusKm: radiusKm,
                days: days
            )
            itinerary = result
        } catch {
            errorMessage = "Failed to generate itinerary. Please check your API key and try again."
        }

        isGenerating = false
    }

    func reset() {
        itinerary = nil
        errorMessage = nil
    }
}
