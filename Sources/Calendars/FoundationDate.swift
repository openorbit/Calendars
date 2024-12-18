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

fileprivate let epoch1970 = 2440587.5

public struct FoundationDate {
  public static func toDate(_ jd: Double) -> Date {
    return  Date(timeIntervalSince1970: (jd - epoch1970) * 86400)
  }

  public static func toJD(_ date: Date) -> Double {
    return epoch1970 + date.timeIntervalSince1970 / 86400
  }
}
