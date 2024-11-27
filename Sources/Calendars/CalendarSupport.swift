//
// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2024 Mattias Holm
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

public enum CalendarId : Codable, Sendable {
  case julian
  case gregorian
  case swedish
  case civilIslamic
  case saka
  case egyptian
  case ethiopian
  case frenchRepublican
  case coptic
  case bahai
  case jewish
  case mesoamericanLongCount
}

extension CalendarId {
  var description : String {
    switch self {
    case .gregorian:
      return "Gregorian"
    case .julian:
      return "Julian"
    case .swedish:
      return "Swedish Transitional"
    case .frenchRepublican:
      return "French Revolutionary"
    case .jewish:
      return "Jewish"
    case .civilIslamic:
      return "Civil Islamic"
    case .saka:
      return "Saka"
    case .egyptian:
      return "Egyptian"
    case .coptic:
      return "Coptic"
    case .ethiopian:
      return "Ethiopian"
    case .bahai:
      return "Bahai"
    case .mesoamericanLongCount:
      return "Mesoamerican Long Count"
    }
  }
}


extension CalendarId {
  func toJDN(Y: Int, M: Int, D: Int) -> Int {
    switch self {
    case .gregorian:
      return GregorianCalendar.toJDN(Y: Y, M: M, D: D)
    case .julian:
      return JulianCalendar.toJDN(Y: Y, M: M, D: D)
    case .swedish:
      return SwedishCalendar.toJDN(Y: Y, M: M, D: D)
    case .frenchRepublican:
      return FrenchRepublicanCalendar.toJDN(Y: Y, M: M, D: D)
    case .jewish:
      return JewishCalendar.toJDN(Y: Y, M: M, D: D)
    case .civilIslamic:
      return CivilIslamicCalendar.toJDN(Y: Y, M: M, D: D)
    case .saka:
      return SakaCalendar.toJDN(Y: Y, M: M, D: D)
    case .egyptian:
      return EgyptianCalendar.toJDN(Y: Y, M: M, D: D)
    case .coptic:
      return CopticCalendar.toJDN(Y: Y, M: M, D: D)
    case .ethiopian:
      return EthiopianCalendar.toJDN(Y: Y, M: M, D: D)
    case .bahai:
      return BahaiCalendar.toJDN(Y: Y, M: M, D: D)
    case .mesoamericanLongCount:
      return 0
    }
  }

  func toDate(J: Int) -> (Int, Int, Int) {
    switch self {
    case .gregorian:
      return GregorianCalendar.toDate(J: J)
    case .julian:
      return JulianCalendar.toDate(J: J)
    case .swedish:
      return SwedishCalendar.toDate(J: J)
    case .frenchRepublican:
      return FrenchRepublicanCalendar.toDate(J: J)
    case .jewish:
      return JewishCalendar.toDate(J: J)
    case .civilIslamic:
      return CivilIslamicCalendar.toDate(J: J)
    case .saka:
      return SakaCalendar.toDate(J: J)
    case .egyptian:
      return EgyptianCalendar.toDate(J: J)
    case .coptic:
      return CopticCalendar.toDate(J: J)
    case .ethiopian:
      return EthiopianCalendar.toDate(J: J)
    case .bahai:
      return BahaiCalendar.toDate(J: J)
    case .mesoamericanLongCount:
      return (0, 0, 0)
    }
  }

  func isProleptic(J: Int) -> Bool {
    switch self {
    case .gregorian:
      return GregorianCalendar.isProleptic(J)
    case .julian:
      return JulianCalendar.isProleptic(J)
    case .swedish:
      return SwedishCalendar.isProleptic(J)
    case .frenchRepublican:
      return FrenchRepublicanCalendar.isProleptic(J)
    case .jewish:
      return JewishCalendar.isProleptic(J)
    case .civilIslamic:
      return CivilIslamicCalendar.isProleptic(J)
    case .saka:
      return SakaCalendar.isProleptic(J)
    case .egyptian:
      return EgyptianCalendar.isProleptic(J)
    case .coptic:
      return CopticCalendar.isProleptic(J)
    case .ethiopian:
      return EthiopianCalendar.isProleptic(J)
    case .bahai:
      return BahaiCalendar.isProleptic(J)
    case .mesoamericanLongCount:
      return MesoamericanLongCountCalendar.isProleptic(J)
    }
  }
}
extension CalendarId {
  func isValidDate(Y: Int, M: Int, D: Int) -> Bool {
    switch self {
    case .gregorian:
      return GregorianCalendar.isValidDate(Y: Y, M: M, D: D)
    case .julian:
      return JulianCalendar.isValidDate(Y: Y, M: M, D: D)
    case .swedish:
      return SwedishCalendar.isValidDate(Y: Y, M: M, D: D)
    case .frenchRepublican:
      return FrenchRepublicanCalendar.isValidDate(Y: Y, M: M, D: D)
    case .jewish:
      return JewishCalendar.isValidDate(Y: Y, M: M, D: D)
    case .civilIslamic:
      return CivilIslamicCalendar.isValidDate(Y: Y, M: M, D: D)
    case .saka:
      return SakaCalendar.isValidDate(Y: Y, M: M, D: D)
    case .egyptian:
      return EgyptianCalendar.isValidDate(Y: Y, M: M, D: D)
    case .coptic:
      return CopticCalendar.isValidDate(Y: Y, M: M, D: D)
    case .ethiopian:
      return EthiopianCalendar.isValidDate(Y: Y, M: M, D: D)
    case .bahai:
      return BahaiCalendar.isValidDate(Y: Y, M: M, D: D)
    case .mesoamericanLongCount:
      return false
    }
  }
}


extension CalendarId {
  func numberOfMonth(_ m: String) -> Int? {
    switch self {
    case .gregorian:
      return GregorianCalendar.numberOfMonth(m)
    case .julian:
      return JulianCalendar.numberOfMonth(m)
    case .swedish:
      return SwedishCalendar.numberOfMonth(m)
    case .frenchRepublican:
      return FrenchRepublicanCalendar.numberOfMonth(m)
    case .jewish:
      return JewishCalendar.numberOfMonth(m)
    case .civilIslamic:
      return CivilIslamicCalendar.numberOfMonth(m)
    case .saka:
      return SakaCalendar.numberOfMonth(m)
    case .egyptian:
      return EgyptianCalendar.numberOfMonth(m)
    case .coptic:
      return CopticCalendar.numberOfMonth(m)
    case .ethiopian:
      return EthiopianCalendar.numberOfMonth(m)
    case .bahai:
      return BahaiCalendar.numberOfMonth(m)

    case .mesoamericanLongCount:
      return nil
    }
  }
}

extension CalendarId {
  func nameOfMonth(_ y: Int, _ m: Int) -> String? {
    switch self {
    case .gregorian:
      return GregorianCalendar.nameOfMonth(m)
    case .julian:
      return JulianCalendar.nameOfMonth(m)
    case .swedish:
      return SwedishCalendar.nameOfMonth(m)
    case .frenchRepublican:
      return FrenchRepublicanCalendar.nameOfMonth(m)
    case .jewish:
      return JewishCalendar.nameOfMonth(year: y, month: m)
    case .civilIslamic:
      return CivilIslamicCalendar.nameOfMonth(m)
    case .saka:
      return SakaCalendar.nameOfMonth(m)
    case .egyptian:
      return EgyptianCalendar.nameOfMonth(m)
    case .coptic:
      return CopticCalendar.nameOfMonth(m)
    case .ethiopian:
      return EthiopianCalendar.nameOfMonth(m)
    case .bahai:
      return BahaiCalendar.nameOfMonth(m)

    case .mesoamericanLongCount:
      return nil
    }
  }
}
