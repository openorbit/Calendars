import XCTest
@testable import Calendars

final class RegnalCalendarTests: XCTestCase {
    
    func testLoading() {
        let rc = RegnalCalendar.shared
        
        // Check tenures loaded
        XCTAssertFalse(rc.tenures.isEmpty, "Tenures should not be empty")
        
        // Check persons loaded
        XCTAssertFalse(rc.persons.isEmpty, "Persons should not be empty")
        
        // Check specific known person: Henry VIII
        let henry8 = rc.persons["PERSON_HENRY_VIII"]
        XCTAssertNotNil(henry8)
        XCTAssertEqual(henry8?.name.normalized, "Henry VIII")
    }
    
    func testTenureLookup() {
        let rc = RegnalCalendar.shared
        // "Edward III"
        let tenures = rc.findTenures(forMonarch: "Edward III")
        XCTAssertFalse(tenures.isEmpty)
        
        let ed3 = tenures.first
        XCTAssertEqual(ed3?.personID, "PERSON_EDWARD_III")
    }
    
    func testRegnalYearCalculation() {
        let rc = RegnalCalendar.shared
        
        guard let tenure = rc.findTenures(forMonarch: "Henry VIII").first else {
            XCTFail("Henry VIII tenure not found")
            return
        }
        
        // Henry VIII accession: April 22, 1509 (Julian)
        // 1st year: Apr 22, 1509 -> Apr 21, 1510
        
        if let range = rc.julianDateRange(forRegnalYear: 1, tenure: tenure) {
            XCTAssertEqual(range.0, JulianDate(year: 1509, month: 4, day: 22))
            XCTAssertEqual(range.1, JulianDate(year: 1510, month: 4, day: 21))
        } else {
            XCTFail("Failed to calc regnal year 1")
        }
        
        // 5th year: Apr 22, 1513 -> Apr 21, 1514
        // (1509 + 4 = 1513)
        
        if let range5 = rc.julianDateRange(forRegnalYear: 5, tenure: tenure) {
            XCTAssertEqual(range5.0, JulianDate(year: 1513, month: 4, day: 22))
            XCTAssertEqual(range5.1, JulianDate(year: 1514, month: 4, day: 21))
        } else {
            XCTFail("Failed to calc regnal year 5")
        }
    }
}
