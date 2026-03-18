
////
////  LocationService.swift
////  TravelItinerary
////
////  Created by Chandan Munjal on 17/03/26.
////
//
//import Foundation
//import Combine
//
//class LocationService: ObservableObject {
//    @Published var suggestions: [PlaceSuggestion] = []
//    @Published var isLoading = false
//
//    private var searchTask: Task<Void, Never>?
//
//    func searchPlaces(query: String) {
//        guard !query.isEmpty else {
//            suggestions = []
//            return
//        }
//
//        searchTask?.cancel()
//        searchTask = Task {
//            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
//            guard !Task.isCancelled else { return }
//
//            await MainActor.run { self.isLoading = true }
//
//            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//            let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(encoded)&types=(cities)&key=\(APIKeys.googlePlaces)"
//
//            guard let url = URL(string: urlString) else { return }
//
//            do {
//                let (data, _) = try await URLSession.shared.data(from: url)
//                let response = try JSONDecoder().decode(PlacesAutocompleteResponse.self, from: data)
//
//                let results = response.predictions.map {
//                    PlaceSuggestion(
//                        placeID: $0.place_id,
//                        name: $0.structured_formatting.main_text,
//                        address: $0.structured_formatting.secondary_text ?? $0.description
//                    )
//                }
//
//                await MainActor.run {
//                    self.suggestions = results
//                    self.isLoading = false
//                }
//            } catch {
//                await MainActor.run {
//                    self.suggestions = []
//                    self.isLoading = false
//                }
//            }
//        }
//    }
//
//    func clearSuggestions() {
//        suggestions = []
//    }
//}
