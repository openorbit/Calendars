
//
// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2025 Mattias Holm
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public struct WorldEvent: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    /// Date of the event. Currently simplified to YMD, assumed Julian/Gregorian based on context or strictly Julian for older dates.
    /// In this simplified model, we'll store Julian Day Number (JDN) if possible, or ISO-8601 string.
    /// For simplicity with existing JSONs, let's store components and rely on the provider to match.
    public let year: Int
    public let month: Int
    public let day: Int
    
    public let calendar: CalendarId // To know which calendar components apply to
    
    public let title: String
    public let description: String?
    public let wikipediaURL: URL?
    public let category: Category
    
    public enum Category: String, Codable, Sendable {
        case battle
        case treaty
        case political
        case religious
        case cultural
        case birth
        case death
        case other
    }
}

public final class WorldEventProvider: @unchecked Sendable {
    public static let shared = WorldEventProvider()
    
    private var events: [WorldEvent] = []
    
    // Quick lookup optimization to come later if needed. Linear scan fine for small datasets.
    
    private init() {
        loadEvents()
    }
    
    public init(events: [WorldEvent]) {
        self.events = events
    }
    
    private func loadEvents() {
        // Try loading from root of bundle resources first, as .process often flattens
        var url = Bundle.module.url(forResource: "world_events", withExtension: "json")
        
        if url == nil {
             // Fallback to subdir if needed (though unlikely with .process)
             url = Bundle.module.url(forResource: "world_events", withExtension: "json", subdirectory: "Resources")
        }
        
        guard let finalUrl = url else {
            print("WorldEvents: world_events.json not found in bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: finalUrl)
            let decoded = try JSONDecoder().decode([WorldEvent].self, from: data)
            self.events = decoded
        } catch {
            print("WorldEvents: Failed to decode world_events.json: \(error)")
        }
    }
    
    /// Returns events occurring on the given Julian Day Number (approximate matching if needed).
    /// Note: This assumes the event's stored components match the JDN in the event's specific calendar.
    public func events(onJDN jdn: Int) -> [WorldEvent] {
         return events.filter { event in
             // Resolve JDN for the event's definition
             let eventJDN: Int
             switch event.calendar {
             case .julian:
                 eventJDN = JulianCalendar.shared.jdn(forYear: event.year, month: event.month, day: event.day)
             case .gregorian:
                 eventJDN = GregorianCalendar.shared.jdn(forYear: event.year, month: event.month, day: event.day)
             // Add others if needed (e.g. Roman)
             default:
                 // Fallback or complex logic
                  eventJDN = JulianCalendar.shared.jdn(forYear: event.year, month: event.month, day: event.day)
             }
             
             return eventJDN == jdn
         }
    }
}
