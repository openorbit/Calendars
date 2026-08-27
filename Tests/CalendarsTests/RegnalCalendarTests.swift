import Testing
@testable import Calendars

@Suite("Regnal calendars")
struct RegnalCalendarTests {
    private let calendar = RegnalCalendar.shared

    @Test("All supported polities load")
    func allSupportedPolitiesLoad() {
        let expectedIDs: Set<String> = [
            "POLITY_AUSTRASIA",
            "POLITY_AUSTRIAN_EMPIRE",
            "POLITY_AUSTRIA_HUNGARY",
            "POLITY_BELGIUM",
            "POLITY_CROWN_ARAGON",
            "POLITY_CROWN_CASTILE",
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
            "POLITY_HABSBURG_MONARCHY",
            "POLITY_HOLY_ROMAN_EMPIRE",
            "POLITY_HRE",
            "POLITY_HUNGARY",
            "POLITY_KALMAR_UNION",
            "POLITY_KENT",
            "POLITY_KINGDOM_ITALY",
            "POLITY_KINGDOM_LOMBARDS",
            "POLITY_MERCIA",
            "POLITY_MIDDLE_FRANCIA",
            "POLITY_NAVARRE",
            "POLITY_NEUSTRIA",
            "POLITY_NETHERLANDS",
            "POLITY_NORTHUMBRIA",
            "POLITY_NORWAY_KINGDOM",
            "POLITY_NORWAY_SWEDEN_UNION",
            "POLITY_OSTROGOTHIC_KINGDOM",
            "POLITY_PAPACY",
            "POLITY_PORTUGAL",
            "POLITY_REGNUM_FRANCORUM",
            "POLITY_ROMAN_REPUBLIC",
            "POLITY_SCOTLAND",
            "POLITY_SPAIN",
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
        "POLITY_AUSTRIAN_EMPIRE",
        "POLITY_AUSTRIA_HUNGARY",
        "POLITY_BELGIUM",
        "POLITY_CROWN_ARAGON",
        "POLITY_CROWN_CASTILE",
        "POLITY_CAROLINGIAN_EMPIRE",
        "POLITY_DENMARK_KINGDOM",
        "POLITY_EAST_ANGLIA",
        "POLITY_EAST_FRANCIA",
        "POLITY_ENGLAND",
        "POLITY_ESSEX",
        "POLITY_EU",
        "POLITY_FRANCE",
        "POLITY_GERMANY",
        "POLITY_HABSBURG_MONARCHY",
        "POLITY_HOLY_ROMAN_EMPIRE",
        "POLITY_HRE",
        "POLITY_HUNGARY",
        "POLITY_KENT",
        "POLITY_KINGDOM_ITALY",
        "POLITY_KINGDOM_LOMBARDS",
        "POLITY_MERCIA",
        "POLITY_MIDDLE_FRANCIA",
        "POLITY_NAVARRE",
        "POLITY_NETHERLANDS",
        "POLITY_NORTHUMBRIA",
        "POLITY_NORWAY_KINGDOM",
        "POLITY_OSTROGOTHIC_KINGDOM",
        "POLITY_PAPACY",
        "POLITY_PORTUGAL",
        "POLITY_REGNUM_FRANCORUM",
        "POLITY_ROMAN_REPUBLIC",
        "POLITY_SCOTLAND",
        "POLITY_SPAIN",
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

    @Test("Hungarian succession preserves rival and restored reigns")
    func hungarianSuccessionPreservesRivalAndRestoredReigns() throws {
        let tenures = calendar.tenures(forOffice: "OFFICE_HUNGARY_MONARCH")
        let peter = tenures.filter { $0.personID == "P_HUNGARY_PETER" }
        let mary = tenures.filter { $0.personID == "P_HUNGARY_MARY" }
        let interregnumRivals = tenures.filter {
            ["P_HUNGARY_CHARLES_I", "P_HUNGARY_WENCESLAUS", "P_HUNGARY_OTTO"]
                .contains($0.personID)
        }
        let charlesIV = try #require(
            tenures.first { $0.personID == "P_HUNGARY_CHARLES_IV" }
        )

        #expect(tenures.count == 56)
        #expect(Set(tenures.map(\.personID)).count == 54)
        #expect(peter.count == 2)
        #expect(mary.count == 2)
        #expect(interregnumRivals.count == 3)
        #expect(interregnumRivals.count { $0.status == "disputed" } == 2)
        #expect(charlesIV.end.first?.ymd?.year == 1918)
        #expect(charlesIV.end.first?.ymd?.month == 11)
        #expect(charlesIV.end.first?.ymd?.day == 13)
        #expect(
            calendar.person(forID: "P_HUNGARY_STEPHEN_I")?.variants.contains {
                $0.form == "I. István" && $0.lang == "hu"
            } == true
        )
    }

    @Test("Habsburg realms preserve the 1804 and 1867 state transitions")
    func habsburgRealmsPreserveStateTransitions() throws {
        let monarchy = calendar.tenures(forOffice: "OFFICE_HABSBURG_MONARCH")
        let empire = calendar.tenures(forOffice: "OFFICE_AUSTRIAN_EMPEROR")
        let dualMonarchy = calendar.tenures(forOffice: "OFFICE_AUSTRIA_HUNGARY_MONARCH")
        let francis = try #require(
            empire.first { $0.personID == "P_AUSTRIANEMPIRE_FRANCIS_I" }
        )
        let franzJosephInEmpire = try #require(
            empire.first { $0.personID == "P_AUSTRIANEMPIRE_FRANZ_JOSEPH_I" }
        )
        let franzJosephInDualMonarchy = try #require(
            dualMonarchy.first { $0.personID == "P_AUSTRIAHUNGARY_FRANZ_JOSEPH_I" }
        )
        let karl = try #require(
            dualMonarchy.first { $0.personID == "P_AUSTRIAHUNGARY_CHARLES_I" }
        )

        #expect(monarchy.count == 13)
        #expect(empire.count == 3)
        #expect(dualMonarchy.count == 2)
        #expect(francis.start.first?.ymd?.year == 1804)
        #expect(francis.start.first?.ymd?.month == 8)
        #expect(francis.start.first?.ymd?.day == 11)
        #expect(franzJosephInEmpire.end.first?.ymd?.year == 1867)
        #expect(franzJosephInDualMonarchy.start.first?.ymd?.year == 1867)
        #expect(karl.end.first?.ymd?.year == 1918)
        #expect(karl.end.first?.ymd?.month == 11)
        #expect(karl.end.first?.ymd?.day == 11)
        #expect(calendar.offices["OFFICE_HRE_KING"]?.polityID == "POLITY_HRE")
    }

    @Test("Iberian crowns remain distinct through the dynastic union")
    func iberianCrownsRemainDistinctThroughTheDynasticUnion() throws {
        let aragon = calendar.tenures(forOffice: "OFFICE_ARAGON_MONARCH")
        let castile = calendar.tenures(forOffice: "OFFICE_CASTILE_MONARCH")
        let navarre = calendar.tenures(forOffice: "OFFICE_NAVARRE_MONARCH")
        let spain = calendar.tenures(forOffice: "OFFICE_SPAIN_MONARCH")
        let charles = try #require(spain.first { $0.personID == "P_SPAIN_CHARLES_I" })

        #expect(aragon.count == 14)
        #expect(castile.count == 13)
        #expect(navarre.count == 32)
        #expect(spain.count == 20)
        #expect(charles.start.first?.ymd?.year == 1516)
        #expect(castile.contains { $0.personID == "P_CASTILE_ISABELLA_I" })
        #expect(aragon.contains { $0.personID == "P_ARAGON_FERDINAND_II" })
    }

    @Test("Spanish succession preserves restorations and republic gaps")
    func spanishSuccessionPreservesRestorationsAndRepublicGaps() throws {
        let tenures = calendar.tenures(forOffice: "OFFICE_SPAIN_MONARCH")
        let philipV = tenures.filter { $0.personID == "P_SPAIN_PHILIP_V" }
        let ferdinandVII = tenures.filter { $0.personID == "P_SPAIN_FERDINAND_VII" }
        let felipeVI = try #require(tenures.first { $0.personID == "P_SPAIN_FELIPE_VI" })

        #expect(philipV.count == 2)
        #expect(ferdinandVII.count == 2)
        #expect(!tenures.contains { $0.start.first?.ymd?.year == 1932 })
        #expect(felipeVI.start.first?.ymd?.year == 2014)
        #expect(felipeVI.start.first?.ymd?.month == 6)
        #expect(felipeVI.start.first?.ymd?.day == 19)
        #expect(felipeVI.end.first?.rep == "open")
        #expect(felipeVI.status == "incumbent")
    }

    @Test("Portuguese monarchy ends with the 1910 republic")
    func portugueseMonarchyEndsWithThe1910Republic() throws {
        let tenures = calendar.tenures(forOffice: "OFFICE_PORTUGAL_MONARCH")
        let mariaII = tenures.filter { $0.personID == "P_PORTUGAL_MARIA_II" }
        let manuelII = try #require(tenures.first { $0.personID == "P_PORTUGAL_MANUEL_II" })

        #expect(tenures.count == 36)
        #expect(mariaII.count == 2)
        #expect(manuelII.end.first?.ymd?.year == 1910)
        #expect(manuelII.end.first?.ymd?.month == 10)
        #expect(manuelII.end.first?.ymd?.day == 5)
        #expect(tenures.contains { $0.status == "disputed" })
    }

    @Test("Belgian monarchy follows constitutional oath transitions")
    func belgianMonarchyFollowsConstitutionalOathTransitions() throws {
        let tenures = calendar.tenures(forOffice: "OFFICE_BELGIUM_MONARCH")
        let leopoldI = try #require(
            tenures.first { $0.personID == "P_BELGIUM_LEOPOLD_I" }
        )
        let philippe = try #require(
            tenures.first { $0.personID == "P_BELGIUM_PHILIPPE" }
        )

        #expect(tenures.count == 7)
        #expect(leopoldI.start.first?.ymd?.year == 1831)
        #expect(leopoldI.start.first?.ymd?.month == 7)
        #expect(leopoldI.start.first?.ymd?.day == 21)
        #expect(philippe.start.first?.ymd?.year == 2013)
        #expect(philippe.start.first?.ymd?.month == 7)
        #expect(philippe.start.first?.ymd?.day == 21)
        #expect(philippe.end.first?.rep == "open")
        #expect(philippe.status == "incumbent")
        #expect(
            calendar.person(forID: "P_BELGIUM_BAUDOUIN")?.variants.contains {
                $0.form == "Boudewijn" && $0.lang == "nl"
            } == true
        )
    }

    @Test("Dutch monarchy follows legal succession dates")
    func dutchMonarchyFollowsLegalSuccessionDates() throws {
        let tenures = calendar.tenures(forOffice: "OFFICE_NETHERLANDS_MONARCH")
        let willemI = try #require(
            tenures.first { $0.personID == "P_NETHERLANDS_WILLEM_I" }
        )
        let willemAlexander = try #require(
            tenures.first { $0.personID == "P_NETHERLANDS_WILLEM_ALEXANDER" }
        )

        #expect(tenures.count == 7)
        #expect(willemI.start.first?.ymd?.year == 1815)
        #expect(willemI.start.first?.ymd?.month == 3)
        #expect(willemI.start.first?.ymd?.day == 16)
        #expect(willemAlexander.start.first?.ymd?.year == 2013)
        #expect(willemAlexander.start.first?.ymd?.month == 4)
        #expect(willemAlexander.start.first?.ymd?.day == 30)
        #expect(willemAlexander.end.first?.rep == "open")
        #expect(willemAlexander.status == "incumbent")
        #expect(
            calendar.person(forID: willemI.personID)?.variants.contains {
                $0.form == "William I" && $0.lang == "en"
            } == true
        )
    }

    @Test("Scottish succession preserves restorations and co-monarchs")
    func scottishSuccessionPreservesRestorationsAndCoMonarchs() throws {
        let tenures = calendar.tenures(forOffice: "OFFICE_SCOTLAND_MONARCH")
        let donald = tenures.filter { $0.personID == "P_SCOTLAND_DONALD_III" }
        let charles = tenures.filter { $0.personID == "P_SCOTLAND_CHARLES_II" }
        let mary = try #require(tenures.first { $0.personID == "P_SCOTLAND_MARY_II" })
        let william = try #require(tenures.first { $0.personID == "P_SCOTLAND_WILLIAM_II" })
        let anne = try #require(tenures.first { $0.personID == "P_SCOTLAND_ANNE" })

        #expect(tenures.count == 50)
        #expect(Set(tenures.map(\.personID)).count == 48)
        #expect(donald.count == 2)
        #expect(charles.count == 2)
        #expect(mary.start.first?.ymd?.year == william.start.first?.ymd?.year)
        #expect(mary.start.first?.ymd?.month == william.start.first?.ymd?.month)
        #expect(mary.start.first?.ymd?.day == william.start.first?.ymd?.day)
        #expect(anne.end.first?.ymd?.year == 1707)
        #expect(anne.end.first?.ymd?.month == 5)
        #expect(anne.end.first?.ymd?.day == 1)
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
