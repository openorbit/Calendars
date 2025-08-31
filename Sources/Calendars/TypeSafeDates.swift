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

public struct JulianDate: Equatable, CustomStringConvertible, Hashable, Sendable {
  public let year: Int, month: Int, day: Int
  public var description: String { String(format: "Julian %04d-%02d-%02d", year, month, day) }

  public init(year: Int, month: Int, day: Int) {
    self.year = year
    self.month = month
    self.day = day
  }
  public init(jdn: Int) {
    (year, month, day) = JulianCalendar.toDate(J: jdn)
  }

  public init(gregorian: GregorianDate) {
    let jd = GregorianCalendar.toJDN(Y: gregorian.year, M: gregorian.month, D: gregorian.day)
    (year, month, day) = JulianCalendar.toDate(J: jd)
  }

  public var isProleptic : Bool {
    get { JulianCalendar.isProleptic(JulianCalendar.toJDN(Y: year, M: month, D: day)) }
  }

  public var jdn : Int {
    get {
      JulianCalendar.toJDN(Y: year, M: month, D: day)
    }
  }

  public var daysSinceEaster : Int {
    get {
      let jdn = JulianCalendar.toJDN(Y: year, M: month, D: day)
      let (easterYear, easterMonth, easterDay) = JulianCalendar.dayOfEaster(Y: year)
      return jdn - JulianCalendar.toJDN(Y: easterYear, M: easterMonth, D: easterDay)
    }
  }

  public static func dayOfEaster(year: Int) -> JulianDate {
    let (easterYear, easterMonth, easterDay) = JulianCalendar.dayOfEaster(Y: year)
    return JulianDate(year: easterYear, month: easterMonth, day: easterDay)
  }

  // returns 1 for sunday, 7 for saturday
  public var dayOfWeek : Int {
    get {
      JulianCalendar.dayOfWeek(Y: year, M: month, D: day)
    }
  }

  // Returns zero for sunday, 6 for saturday
  public var dayOfWeekIndex : Int {
    get {
      JulianCalendar.dayOfWeek(Y: year, M: month, D: day) - 1
    }
  }


  public func dateAdding(days: Int) -> JulianDate {
    let newJDN = jdn + days
    return JulianDate(jdn: newJDN)
  }
}


public struct GregorianDate: Equatable, CustomStringConvertible, Sendable {
  public let year: Int, month: Int, day: Int
  public var description: String { String(format: "Gregorian %04d-%02d-%02d", year, month, day) }

  public init(year: Int, month: Int, day: Int) {
    self.year = year
    self.month = month
    self.day = day
  }

  public init(jdn: Int) {
    (year, month, day) = GregorianCalendar.toDate(J: jdn)
  }

  public init(julian: JulianDate) {
    let jd = JulianCalendar.toJDN(Y: julian.year, M: julian.month, D: julian.day)
    (year, month, day) = GregorianCalendar.toDate(J: jd)
  }

  public var isProleptic : Bool {
    get { GregorianCalendar.isProleptic(GregorianCalendar.toJDN(Y: year, M: month, D: day)) }
  }

  public var jdn : Int {
    get {
      GregorianCalendar.toJDN(Y: year, M: month, D: day)
    }
  }
  public var daysSinceEaster : Int {
    get {
      let jdn = GregorianCalendar.toJDN(Y: year, M: month, D: day)
      let (easterYear, easterMonth, easterDay) = GregorianCalendar.dayOfEaster(Y: year)
      return jdn - GregorianCalendar.toJDN(Y: easterYear, M: easterMonth, D: easterDay)
    }
  }

  public static func dayOfEaster(year: Int) -> GregorianDate {
    let (easterYear, easterMonth, easterDay) = GregorianCalendar.dayOfEaster(Y: year)
    return GregorianDate(year: easterYear, month: easterMonth, day: easterDay)
  }

  public var dayOfWeek : Int {
    get {
      GregorianCalendar.dayOfWeek(Y: year, M: month, D: day)
    }
  }

  public func dateAdding(days: Int) -> GregorianDate {
    let newJDN = jdn + days
    return GregorianDate(jdn: newJDN)
  }
}
