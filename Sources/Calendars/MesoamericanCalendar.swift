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

public struct MesoamericanDate : Equatable {
  public var hablatun: Int = 0
  public var alautun: Int = 0
  public var kinchiltun: Int = 0
  public var kalabtun: Int = 0
  public var piktun: Int = 0
  public var baktun: Int
  public var katun: Int
  public var tun: Int
  public var winal: Int
  public var kin: Int
  public init() {
    hablatun = 0
    alautun = 0
    kinchiltun = 0
    kalabtun = 0
    piktun = 0
    baktun = 0
    katun = 0
    tun = 0
    winal = 0
    kin = 0
  }

  public init(comps: [Int]) {
    self.init()
    if comps.count == 5 {
      baktun = comps[0]
      katun = comps[1]
      tun = comps[2]
      winal = comps[3]
      kin = comps[4]
    } else if comps.count == 6 {
      piktun = comps[0]
      baktun = comps[1]
      katun = comps[2]
      tun = comps[3]
      winal = comps[4]
      kin = comps[5]
    }
  }
}

public struct MesoamericanLongCountCalendar {
  static let epoch = 584283

  static let gmtCorrection = 584283
  static let cycleSize = [460800000000, 23040000000, 1152000000, 57600000,
                          2880000,
                          144000, 7200, 360, 20, 1]

  public static func isProleptic(_ d: Int) -> Bool {
    return d < epoch
  }

  public static func toJDN(hablatun: Int = 0,
                           alautun: Int = 0,
                           kinchiltun: Int = 0,
                           kalabtun: Int = 0,
                           piktun: Int = 0,
                           baktun: Int,
                           katun: Int,
                           tun: Int,
                           winal: Int,
                           kin: Int) -> Int {

    return hablatun * cycleSize[0] +
    alautun * cycleSize[1] +
    kinchiltun * cycleSize[2] +
    kalabtun * cycleSize[3] +
    piktun * cycleSize[4] +
    baktun * cycleSize[5] +
    katun * cycleSize[6] +
    tun * cycleSize[7] +
    winal * cycleSize[8] +
    kin * cycleSize[9] +
    gmtCorrection
  }

  public static func toDate(J: Int) -> MesoamericanDate {
    let t = J - gmtCorrection
    var date = MesoamericanDate()
    date.hablatun = (t / 460800000000) % 20
    date.alautun = (t / 23040000000) % 20
    date.kinchiltun = (t / 1152000000) % 20
    date.kalabtun = (t / 57600000) % 20
    date.piktun = (t / 2880000) % 20
    date.baktun = (t / 144000) % 20
    date.katun = (t / 7200) % 20
    date.tun = (t / 360) % 20
    date.winal = (t / 20) % 18
    date.kin = t % 20

    return date
  }

  public static func isValidDate(d: [Int]) -> Bool {
    for i in d {
      if i < 0 || 20 <= i {
        return false
      }
    }
    if d[d.endIndex - 2] >= 18 {
      return false
    }
    return true
  }
}
