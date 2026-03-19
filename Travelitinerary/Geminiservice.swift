
////
////  Geminiservice.swift
////  TravelItinerary
////
////  Created by Chandan Munjal on 17/03/26.
////
//import Foundation
//
//class GeminiService {
//
//    func generateItinerary(location: String, radiusKm: Int, days: Int) async throws -> Itinerary {
//        let prompt = buildPrompt(location: location, radiusKm: radiusKm, days: days)
//        let rawText = try await callGeminiAPI(prompt: prompt)
//        return parseItinerary(from: rawText, location: location, days: days)
//    }
//
//    private func buildPrompt(location: String, radiusKm: Int, days: Int) -> String {
//        return """
//        Create a detailed \(days)-day travel itinerary for \(location) and areas within \(radiusKm) km radius.
//
//        Format your response EXACTLY like this example, using this structure for each day:
//
//        DAY 1: [Day Title]
//        [TIME] | [EMOJI] [Activity Title] | [Brief description of the activity, what to see/do, tips]
//
//        DAY 2: [Day Title]
//        [TIME] | [EMOJI] [Activity Title] | [Brief description]
//
//        Rules:
//        - Use times like "9:00 AM", "12:30 PM", "3:00 PM", "7:00 PM"
//        - Use a single relevant emoji for each activity
//        - Include 4-5 activities per day
//        - Keep descriptions concise (1-2 sentences)
//        - Suggest places within \(radiusKm) km of \(location)
//        - Include mix of: sightseeing, food/dining, culture, nature/outdoor activities
//        - Start each day line with "DAY X:" format
//        - Start each activity line with a time, then pipe |, then emoji, title, pipe |, description
//
//        Generate the itinerary now:
//        """
//    }
//
//    private func callGeminiAPI(prompt: String) async throws -> String {
//        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(APIKeys.gemini)"
//        guard let url = URL(string: urlString) else {
//            throw NSError(domain: "GeminiService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
//        }
//
//        let requestBody: [String: Any] = [
//            "contents": [
//                ["parts": [["text": prompt]]]
//            ],
//            "generationConfig": [
//                "temperature": 0.7,
//                "maxOutputTokens": 2048
//            ]
//        ]
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//            throw NSError(domain: "GeminiService", code: 1, userInfo: [NSLocalizedDescriptionKey: "API request failed"])
//        }
//
//        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//        guard
//            let candidates = json?["candidates"] as? [[String: Any]],
//            let first = candidates.first,
//            let content = first["content"] as? [String: Any],
//            let parts = content["parts"] as? [[String: Any]],
//            let text = parts.first?["text"] as? String
//        else {
//            throw NSError(domain: "GeminiService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
//        }
//
//        return text
//    }
//
//    private func parseItinerary(from text: String, location: String, days: Int) -> Itinerary {
//        var itineraryDays: [ItineraryDay] = []
//        let lines = text.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
//
//        var currentDayNumber = 0
//        var currentDayTitle = ""
//        var currentActivities: [Activity] = []
//
//        for line in lines {
//            guard !line.isEmpty else { continue }
//
//            // Check if this is a day header: "DAY 1: Title"
//            if line.uppercased().hasPrefix("DAY ") {
//                // Save previous day
//                if currentDayNumber > 0 && !currentActivities.isEmpty {
//                    itineraryDays.append(ItineraryDay(
//                        dayNumber: currentDayNumber,
//                        title: currentDayTitle,
//                        activities: currentActivities
//                    ))
//                }
//
//                // Parse new day
//                let parts = line.components(separatedBy: ":")
//                if let dayPart = parts.first {
//                    let numStr = dayPart.replacingOccurrences(of: "DAY ", with: "", options: .caseInsensitive).trimmingCharacters(in: .whitespaces)
//                    currentDayNumber = Int(numStr) ?? (currentDayNumber + 1)
//                }
//                currentDayTitle = parts.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
//                if currentDayTitle.isEmpty { currentDayTitle = "Day \(currentDayNumber)" }
//                currentActivities = []
//
//            } else if line.contains("|") {
//                // Parse activity line: "9:00 AM | 🏛️ Visit Temple | Description here"
//                let parts = line.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
//                guard parts.count >= 3 else { continue }
//
//                let time = parts[0]
//                let titlePart = parts[1]
//                let description = parts[2]
//
//                // Extract emoji from title part
//                let emoji = extractEmoji(from: titlePart) ?? "📍"
//                let title = removeEmoji(from: titlePart).trimmingCharacters(in: .whitespaces)
//
//                currentActivities.append(Activity(
//                    time: time,
//                    title: title,
//                    description: description,
//                    emoji: emoji
//                ))
//            }
//        }
//
//        // Save last day
//        if currentDayNumber > 0 && !currentActivities.isEmpty {
//            itineraryDays.append(ItineraryDay(
//                dayNumber: currentDayNumber,
//                title: currentDayTitle,
//                activities: currentActivities
//            ))
//        }
//
//        // Fallback: if parsing failed, create placeholder days
//        if itineraryDays.isEmpty {
//            for i in 1...days {
//                itineraryDays.append(ItineraryDay(
//                    dayNumber: i,
//                    title: "Day \(i)",
//                    activities: [Activity(time: "", title: "Itinerary content", description: text, emoji: "🗺️")]
//                ))
//            }
//        }
//
//        return Itinerary(location: location, days: itineraryDays)
//    }
//
//    private func extractEmoji(from string: String) -> String? {
//        for scalar in string.unicodeScalars {
//            if scalar.properties.isEmoji && scalar.value > 0x238C {
//                return String(scalar)
//            }
//        }
//        return nil
//    }
//
//    private func removeEmoji(from string: String) -> String {
//        return string.unicodeScalars.filter {
//            !($0.properties.isEmoji && $0.value > 0x238C)
//        }.map { String($0) }.joined()
//    }
//}
import Foundation

class GeminiService {

    func generateItinerary(location: String, radiusKm: Int, days: Int) async throws -> Itinerary {
        let prompt = buildPrompt(location: location, radiusKm: radiusKm, days: days)
        let rawText = try await callGeminiAPI(prompt: prompt, days: days)
        let itinerary = parseItinerary(from: rawText, location: location, days: days)

        // If we got fewer days than requested, retry once with a stricter prompt
        if itinerary.days.count < days {
            let missingFrom = itinerary.days.count + 1
            let retryPrompt = buildRetryPrompt(
                existing: rawText,
                location: location,
                radiusKm: radiusKm,
                from: missingFrom,
                to: days
            )
            let retryText = try await callGeminiAPI(prompt: retryPrompt, days: days - itinerary.days.count)
            let combined = rawText + "\n" + retryText
            return parseItinerary(from: combined, location: location, days: days)
        }

        return itinerary
    }

    // MARK: - Prompt Builder

    private func buildPrompt(location: String, radiusKm: Int, days: Int) -> String {
        return """
        You are an expert travel planner creating a fun, human-like, and non-repetitive itinerary.

        Create a \(days)-day itinerary for \(location), within \(radiusKm) km.

        IMPORTANT:
        - Generate ALL days from DAY 1 to DAY \(days)
        - Each day must feel different in structure, pacing, and vibe
        - Avoid any fixed or repeating patterns

        STRUCTURE:
        - Each day must include EXACTLY 4 activities
        - Each activity must include:
            • A realistic time (but NOT fixed or repeated across days)
            • A place name
            • A short, vivid description (max 12 words)

        TIME RULES:
        - Do NOT use the same time slots every day
        - Vary timings naturally (early morning, late morning, afternoon, evening, night)
        - Times should feel human and realistic, not evenly spaced

        EXPERIENCE RULES:
        - Mix activity types: food, culture, nature, markets, hidden gems, nightlife
        - Some days can be relaxed, others packed
        - Avoid repeating the same sequence of activities each day

        STYLE:
        - Write like a real travel planner, not a template
        - Make it lively, slightly adventurous, and engaging
        - Include unique/local experiences, not just tourist spots

        FORMAT:

        DAY 1: [Catchy title]

        Time | Emoji | Place Name | Description

        DAY 2: [Different title]

        (continue similarly...)

        RULES:
        - Use only real places within \(radiusKm) km of \(location)
        - No intro, no summary, only itinerary
        - Do NOT follow identical structure across days

        FINAL CHECK:
        If the itinerary looks repetitive or templated, rewrite it with more variation.

        Start from DAY 1 and end at DAY \(days)
        """
    }
    
    private func buildRetryPrompt(existing: String, location: String, radiusKm: Int, from: Int, to: Int) -> String {
        return """
        You are continuing a travel itinerary in a natural, engaging way.

        Context:
        - Location: \(location)
        - Continue from Day \(from) to Day \(to)
        - Previous days already exist

        Your goal:
        Extend the itinerary WITHOUT repetition and with increasing variety.

        GUIDELINES:
        - Use only real places within \(radiusKm) km
        - Do NOT repeat places or similar experiences
        - Keep a natural travel flow (group nearby places)
        - Mix experiences: culture, food, nature, markets, relaxation, nightlife
        - Vary time slots and avoid fixed schedules
        - Each day should feel different in vibe (exploration, chill, luxury, local life)

        STYLE:
        - Human-like, not templated
        - Slight variation in formatting is allowed but keep it clean
        - Descriptions: short, vivid, max 12 words

        FORMAT:

        DAY \(from): [Unique title]

        Time | Emoji | Place | Description

        Continue until DAY \(to)

        IMPORTANT:
        - No repetition of structure or timing patterns
        - Keep it engaging and realistic
        - No intro or conclusion

        Start from DAY \(from)
        """
    }

    // MARK: - API Call

    private func callGeminiAPI(prompt: String, days: Int) async throws -> String {
        // Scale tokens generously: 800 per day minimum, floor at 4096
        let maxTokens = max(4096, days * 800)

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(APIKeys.gemini)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "GeminiService", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let requestBody: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": maxTokens
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

        if statusCode != 200 {
            // Surface the real Gemini error message
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw NSError(domain: "GeminiService", code: statusCode,
                              userInfo: [NSLocalizedDescriptionKey: message])
            }
            throw NSError(domain: "GeminiService", code: statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP \(statusCode) — check your API key"])
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard
            let candidates = json?["candidates"] as? [[String: Any]],
            let first = candidates.first,
            let content = first["content"] as? [String: Any],
            let parts = content["parts"] as? [[String: Any]],
            let text = parts.first?["text"] as? String
        else {
            throw NSError(domain: "GeminiService", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Could not parse Gemini response"])
        }

        return text
    }

    // MARK: - Parser

    private func parseItinerary(from text: String, location: String, days: Int) -> Itinerary {
        var itineraryDays: [ItineraryDay] = []
        let lines = text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        var currentDayNumber = 0
        var currentDayTitle = ""
        var currentActivities: [Activity] = []

        for line in lines {
            if line.uppercased().hasPrefix("DAY ") && line.contains(":") {
                // Save previous day before starting a new one
                if currentDayNumber > 0 && !currentActivities.isEmpty {
                    itineraryDays.append(ItineraryDay(
                        dayNumber: currentDayNumber,
                        title: currentDayTitle,
                        activities: currentActivities
                    ))
                }

                // Parse "DAY 3: Versailles & Gardens"
                let colonIdx = line.firstIndex(of: ":") ?? line.endIndex
                let dayPart = String(line[line.startIndex..<colonIdx])
                    .replacingOccurrences(of: "DAY ", with: "", options: .caseInsensitive)
                    .trimmingCharacters(in: .whitespaces)
                currentDayNumber = Int(dayPart) ?? (currentDayNumber + 1)
                currentDayTitle = String(line[line.index(after: colonIdx)...])
                    .trimmingCharacters(in: .whitespaces)
                if currentDayTitle.isEmpty { currentDayTitle = "Day \(currentDayNumber)" }
                currentActivities = []

            } else if line.contains("|") {
                let parts = line.components(separatedBy: "|")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                guard parts.count >= 3 else { continue }

                let time = parts[0]
                let titlePart = parts[1]
                let description = parts[2]
                let emoji = extractEmoji(from: titlePart) ?? "📍"
                let title = removeEmoji(from: titlePart).trimmingCharacters(in: .whitespaces)

                currentActivities.append(Activity(
                    time: time,
                    title: title.isEmpty ? "Activity" : title,
                    description: description,
                    emoji: emoji
                ))
            }
        }

        // Don't forget the last day
        if currentDayNumber > 0 && !currentActivities.isEmpty {
            itineraryDays.append(ItineraryDay(
                dayNumber: currentDayNumber,
                title: currentDayTitle,
                activities: currentActivities
            ))
        }

        return Itinerary(location: location, days: itineraryDays)
    }

    // MARK: - Emoji Helpers

    private func extractEmoji(from string: String) -> String? {
        for scalar in string.unicodeScalars {
            if scalar.properties.isEmoji && scalar.value > 0x238C {
                return String(scalar)
            }
        }
        return nil
    }

    private func removeEmoji(from string: String) -> String {
        string.unicodeScalars
            .filter { !($0.properties.isEmoji && $0.value > 0x238C) }
            .map { String($0) }
            .joined()
    }
}
