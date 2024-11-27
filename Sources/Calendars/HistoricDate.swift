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

public struct HistoricDate {
  public let jd: Double
}

public enum HistoricDateFormat {
  case ymd
  case dmy
}

public struct HistoricDateFormatter {
  public let calendar: CalendarId
  public let format: HistoricDateFormat
  public let numeric: Bool = false

  public func format(_ date: HistoricDate) -> String {
    let (y, m, d) = calendar.toDate(J: Int(date.jd))
    let nameOfMonth = calendar.nameOfMonth(y, m)

    if !numeric, let nameOfMonth {
      switch format {
      case .dmy:
        return "\(d) \(nameOfMonth), \(y)"
      case .ymd:
        return "\(String(format: "%04d", y))-\(nameOfMonth)-\(String(format: "%02d", d))"
      }
    } else {
      switch format {
      case .dmy:
        return String(format: "%d %d, %04d", d, m, y)
      case .ymd:
        return String(format: "%04d-%02d-%02d", y, m, d)
      }
    }
  }
}
