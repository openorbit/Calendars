import Testing
@testable import Calendars

@Suite("Regnal calendars")
struct RegnalCalendarTests {
    private let calendar = RegnalCalendar.shared

    @Test("All supported polities load")
    func allSupportedPolitiesLoad() {
        let expectedIDs: Set<String> = [
            "POLITY_AUSTRASIA",
            "POLITY_BURGUNDY_FRANKISH",
            "POLITY_CAROLINGIAN_EMPIRE",
            "POLITY_DENMARK_KINGDOM",
            "POLITY_DENMARK_NORWAY_UNION",
            "POLITY_EAST_ANGLIA",
            "POLITY_EAST_FRANCIA",
            "POLITY_ENGLAND",
            "POLITY_ESSEX",
            "POLITY_EU",
            "POLITY_FRANCE",
            "POLITY_GERMANY",
            "POLITY_HOLY_ROMAN_EMPIRE",
            "POLITY_HRE",
            "POLITY_KALMAR_UNION",
            "POLITY_KENT",
            "POLITY_KINGDOM_ITALY",
            "POLITY_KINGDOM_LOMBARDS",
            "POLITY_MERCIA",
            "POLITY_MIDDLE_FRANCIA",
            "POLITY_NEUSTRIA",
            "POLITY_NORTHUMBRIA",
            "POLITY_NORWAY_KINGDOM",
            "POLITY_NORWAY_SWEDEN_UNION",
            "POLITY_OSTROGOTHIC_KINGDOM",
            "POLITY_PAPACY",
            "POLITY_REGNUM_FRANCORUM",
            "POLITY_ROMAN_REPUBLIC",
            "POLITY_SUSSEX",
            "POLITY_SWEDEN",
            "POLITY_UNITED_STATES",
            "POLITY_VISIGOTHIC_KINGDOM",
            "POLITY_WESSEX",
            "POLITY_WEST_FRANCIA"
        ]

        #expect(Set(calendar.polities.keys) == expectedIDs)
    }

    @Test("Polity has regnal tenures", arguments: [
        "POLITY_CAROLINGIAN_EMPIRE",
        "POLITY_DENMARK_KINGDOM",
        "POLITY_EAST_ANGLIA",
        "POLITY_EAST_FRANCIA",
        "POLITY_ENGLAND",
        "POLITY_ESSEX",
        "POLITY_EU",
        "POLITY_FRANCE",
        "POLITY_GERMANY",
        "POLITY_HOLY_ROMAN_EMPIRE",
        "POLITY_HRE",
        "POLITY_KENT",
        "POLITY_KINGDOM_ITALY",
        "POLITY_KINGDOM_LOMBARDS",
        "POLITY_MERCIA",
        "POLITY_MIDDLE_FRANCIA",
        "POLITY_NORTHUMBRIA",
        "POLITY_NORWAY_KINGDOM",
        "POLITY_OSTROGOTHIC_KINGDOM",
        "POLITY_PAPACY",
        "POLITY_REGNUM_FRANCORUM",
        "POLITY_ROMAN_REPUBLIC",
        "POLITY_SUSSEX",
        "POLITY_SWEDEN",
        "POLITY_UNITED_STATES",
        "POLITY_VISIGOTHIC_KINGDOM",
        "POLITY_WESSEX",
        "POLITY_WEST_FRANCIA"
    ])
    func polityHasRegnalTenures(polityID: String) throws {
        let polity = try #require(calendar.polities[polityID])
        let offices = calendar.offices(forPolity: polity.id)
        let tenures = offices.flatMap { calendar.tenures(forOffice: $0.id) }

        #expect(!offices.isEmpty, "No offices loaded for \(polity.label)")
        #expect(!tenures.isEmpty, "No tenures loaded for \(polity.label)")
        #expect(tenures.allSatisfy { calendar.person(forID: $0.personID) != nil })
    }

    @Test("Every office belongs to a loaded polity")
    func everyOfficeBelongsToLoadedPolity() {
        for office in calendar.offices.values {
            #expect(
                calendar.polities[office.polityID] != nil,
                "Office \(office.id) references missing polity \(office.polityID)"
            )
        }
    }

    @Test("Every tenure has a loaded office and person")
    func everyTenureHasLoadedRelationships() {
        for tenure in calendar.tenures {
            #expect(
                calendar.offices[tenure.officeID] != nil,
                "Tenure \(tenure.id) references missing office \(tenure.officeID)"
            )
            #expect(
                calendar.persons[tenure.personID] != nil,
                "Tenure \(tenure.id) references missing person \(tenure.personID)"
            )
        }
    }

    @Test("European Council presidency transitions to António Costa")
    func europeanCouncilPresidencyTransitionsToAntonioCosta() throws {
        let councilTenures = calendar.tenures(
            forOffice: "OFFICE_EU_COUNCIL_PRESIDENT"
        )
        let michel = try #require(
            councilTenures.first { $0.personID == "P_MICHEL" }
        )
        let costa = try #require(
            councilTenures.first { $0.personID == "P_ANTONIO_COSTA" }
        )

        #expect(michel.end.first?.ymd?.year == 2024)
        #expect(michel.end.first?.ymd?.month == 11)
        #expect(michel.end.first?.ymd?.day == 30)
        #expect(costa.start.first?.ymd?.year == 2024)
        #expect(costa.start.first?.ymd?.month == 12)
        #expect(costa.start.first?.ymd?.day == 1)
        #expect(costa.end.first?.ymd?.year == 2027)
        #expect(costa.end.first?.ymd?.month == 5)
        #expect(costa.end.first?.ymd?.day == 31)
        #expect(costa.status == "incumbent")
    }

    @Test("French medieval and early-modern successions share one polity")
    func frenchSuccessionsShareOnePolity() {
        let tenures = calendar.tenures(forOffice: "OFFICE_FRANCE_KING")

        #expect(tenures.contains { $0.personID == "PERSON_HENRY_III_FR" })
        #expect(tenures.contains { $0.personID == "PERSON_HENRY_IV_FR" })
        #expect(calendar.offices["OFFICE_FRANCE_KING"]?.polityID == "POLITY_FRANCE")
    }

    @Test("Papal succession includes all recognized pontiffs")
    func papalSuccessionIncludesAllRecognizedPontiffs() throws {
        let tenures = calendar.tenures(forOffice: "OFFICE_POPE")
        let francis = try #require(tenures.first { $0.personID == "P_POPE_266" })
        let leo = try #require(tenures.first { $0.personID == "P_POPE_267" })
        let earlyAlternative = try #require(tenures.first { $0.personID == "P_POPE_005" })

        #expect(tenures.count == 267)
        #expect(Set(tenures.map(\.personID)).count == 267)
        #expect(tenures.allSatisfy { tenure in
            calendar.person(forID: tenure.personID)?.variants.contains {
                $0.lang == "la" && $0.kind == "papal"
            } == true
        })
        #expect(
            calendar.person(forID: "P_POPE_001")?.variants.contains {
                $0.form == "Petrus" && $0.lang == "la"
            } == true
        )
        #expect(
            calendar.person(forID: "P_POPE_267")?.variants.contains {
                $0.form == "Leo XIV" && $0.lang == "la"
            } == true
        )
        #expect(francis.end.first?.ymd?.year == 2025)
        #expect(francis.end.first?.ymd?.month == 4)
        #expect(francis.end.first?.ymd?.day == 21)
        #expect(leo.ordinal == 14)
        #expect(leo.start.first?.ymd?.year == 2025)
        #expect(leo.start.first?.ymd?.month == 5)
        #expect(leo.start.first?.ymd?.day == 8)
        #expect(leo.status == "incumbent")
        #expect(earlyAlternative.start.count == 2)
        #expect(earlyAlternative.certainty == "low")
    }

    @Test("United States presidential succession is complete")
    func unitedStatesPresidentialSuccessionIsComplete() throws {
        let tenures = calendar.tenures(forOffice: "OFFICE_US_PRESIDENT")
        let personIDs = Set(tenures.map(\.personID))
        let cleveland = tenures.filter { $0.personID == "P_US_GROVER_CLEVELAND" }
        let trump = tenures.filter { $0.personID == "P_US_DONALD_TRUMP" }
        let incumbent = try #require(tenures.first { $0.ordinal == 47 })

        #expect(tenures.count == 47)
        #expect(personIDs.count == 45)
        #expect(Set(cleveland.compactMap(\.ordinal)) == [22, 24])
        #expect(Set(trump.compactMap(\.ordinal)) == [45, 47])
        #expect(incumbent.status == "incumbent")
        #expect(incumbent.start.first?.ymd?.year == 2025)
        #expect(incumbent.start.first?.ymd?.month == 1)
        #expect(incumbent.start.first?.ymd?.day == 20)
        #expect(incumbent.end.first?.ymd?.year == 2029)
        #expect(incumbent.end.first?.ymd?.month == 1)
        #expect(incumbent.end.first?.ymd?.day == 20)
    }

    @Test("English regnal year uses the accession anniversary")
    func englishRegnalYearUsesAccessionAnniversary() throws {
        let tenure = try #require(
            calendar.findTenures(forMonarch: "Henry VIII")
                .first { $0.officeID == "OFFICE_ENGLAND_KING" }
        )
        let firstYear = try #require(calendar.julianDateRange(forRegnalYear: 1, tenure: tenure))
        let fifthYear = try #require(calendar.julianDateRange(forRegnalYear: 5, tenure: tenure))

        #expect(firstYear.0 == JulianDate(year: 1509, month: 4, day: 22))
        #expect(firstYear.1 == JulianDate(year: 1510, month: 4, day: 21))
        #expect(fifthYear.0 == JulianDate(year: 1513, month: 4, day: 22))
        #expect(fifthYear.1 == JulianDate(year: 1514, month: 4, day: 21))
    }

    @Test("Roman AUC tenure converts to the package year representation")
    func romanAUCTenureConvertsToPackageYear() throws {
        let tenure = try #require(
            calendar.findTenures(forMonarch: "Lucius Iunius Brutus")
                .first { $0.officeID == "OFFICE_CONSUL_ORDINARIUS" }
        )
        let firstYear = try #require(calendar.julianDateRange(forRegnalYear: 1, tenure: tenure))

        #expect(firstYear.0 == JulianDate(year: -508, month: 1, day: 1))
    }

    @Test("Name lookup accepts common regnal abbreviations and Arabic ordinals")
    func nameLookupNormalizesRegnalNames() {
        let matches = calendar.findTenures(forMonarch: "Hen. 8")

        #expect(matches.contains { $0.personID == "PERSON_HENRY_VIII" })
    }
}
