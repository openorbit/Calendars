import Foundation
import Testing
@testable import Calendars

@Suite("Historical event packs")
struct EventPackTests {
    @Test("Version 1 JSON decodes, validates, and round-trips")
    func roundTrip() throws {
        let json = """
        {
          "format_version": 1,
          "id": "hundred-years-war",
          "version": "1.0.0",
          "title": "Hundred Years' War",
          "summary": "Selected events from the conflict.",
          "author": "Example Author",
          "license": "CC BY 4.0",
          "language": "en",
          "categories": [
            { "id": "battle", "name": "Battle", "icon": "battle", "color": "#A33A32" },
            { "id": "life", "name": "Life event", "icon": "birth" }
          ],
          "events": [
            {
              "id": "agincourt",
              "title": "Battle of Agincourt",
              "time": {
                "start": {
                  "calendar": "julian",
                  "year": 1415,
                  "month": 10,
                  "day": 25,
                  "precision": "day",
                  "qualifier": "exact",
                  "certainty": "certain"
                }
              },
              "category_ids": ["battle"],
              "tags": ["Hundred Years' War"],
              "people": ["Henry V of England"],
              "places": [{ "name": "Azincourt", "latitude": 50.46, "longitude": 2.14 }],
              "links": [{
                "kind": "wikidata",
                "title": "Wikidata",
                "url": "https://www.wikidata.org/wiki/Q173062"
              }]
            },
            {
              "id": "joan-of-arc-life",
              "title": "Life of Joan of Arc",
              "time": {
                "start": {
                  "calendar": "julian",
                  "year": 1412,
                  "precision": "year",
                  "qualifier": "circa",
                  "certainty": "probable",
                  "original_text": "about 1412"
                },
                "end": {
                  "calendar": "julian",
                  "year": 1431,
                  "month": 5,
                  "day": 30,
                  "precision": "day",
                  "qualifier": "exact",
                  "certainty": "certain"
                }
              },
              "category_ids": ["life"],
              "tags": [],
              "people": ["Joan of Arc"],
              "places": [],
              "links": []
            }
          ]
        }
        """

        let pack = try EventPackJSONCodec.decode(Data(json.utf8))
        #expect(pack.events.count == 2)
        #expect(pack.events[0].time.end == nil)
        #expect(pack.events[1].time.start.qualifier == .circa)
        #expect(pack.events[1].time.end?.calendarID == "julian")

        let encoded = try EventPackJSONCodec.encode(pack)
        let decoded = try EventPackJSONCodec.decode(encoded)
        #expect(decoded == pack)
    }

    @Test("Validation reports duplicate and dangling identifiers")
    func invalidIdentifiers() {
        let date = HistoricalDate(calendarID: "julian", year: 1415, precision: .year)
        let event = HistoricalEvent(
            id: "event",
            title: "Event",
            time: .init(start: date),
            categoryIDs: ["missing"]
        )
        let pack = EventPack(
            id: "pack",
            version: "1",
            title: "Pack",
            summary: "Summary",
            categories: [
                .init(id: "battle", name: "Battle"),
                .init(id: "battle", name: "Duplicate")
            ],
            events: [event]
        )

        let paths = Set(EventPackValidator.issues(in: pack).map(\.path))
        #expect(paths.contains("categories[1].id"))
        #expect(paths.contains("events[0].category_ids"))
    }

    @Test("Date precision must match supplied components")
    func invalidDatePrecision() {
        let date = HistoricalDate(
            calendarID: "gregorian",
            year: 1900,
            month: 1,
            precision: .day
        )
        let pack = EventPack(
            id: "pack",
            version: "1",
            title: "Pack",
            summary: "Summary",
            events: [.init(id: "event", title: "Event", time: .init(start: date))]
        )

        #expect(EventPackValidator.issues(in: pack).contains {
            $0.path == "events[0].time.start.precision"
        })
    }
}
