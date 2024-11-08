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

struct CalendarAlgorithm {
  let y: Int
  let j: Int
  let m: Int
  let n: Int
  let r: Int
  let p: Int
  let q: Int
  let v: Int
  let u: Int
  let s: Int
  let t: Int
  let w: Int


  func toJd(Y: Int, M: Int, D: Int) -> Int {
    let h = M - m
    let g = Y + y - (n - h) / n
    let f = (h - 1 + n) % n // Check if this is same as mod
    let e = (p * g + q) / r + D - 1 - j
    let J = e + (s * f + t) / u
    return J
  }

  func toDate(J: Int) -> (Int,Int,Int) {
    let f = J + j
    let e = r * f + v
    let g = (e % p) / r
    let h = u * g + w
    let D = (h % s) / u + 1
    let M = ((h/s + m) % n) + 1
    let Y = e / p - y + (n + m - M) / n
    return (Y, M, D)
  }
}

struct SwedishCalendarAlgorithm {
  let y: Int
  let j: Int
  let m: Int
  let n: Int
  let r: Int
  let p: Int
  let q: Int
  let v: Int
  let u: Int
  let s: Int
  let t: Int
  let w: Int

  func toJd(Y: Int, M: Int, D: Int) -> Int {
    let h = M - m
    let g = Y + y - (n - h) / n
    let f = (h - 1 + n) % n // Check if this is same as mod
    let e = (p * g + q) / r + D - 1 - j
    let J = e + (s * f + t) / u
    return J - 1
  }

  func toDate(J: Int) -> (Int,Int,Int) {
    if J == 2346425 {
      // This is the magical JDN for the infamous February 30
      return (1712, 2, 30)
    }
    let f = J + j + 1
    let e = r * f + v
    let g = (e % p) / r
    let h = u * g + w
    let D = (h % s) / u + 1
    let M = ((h/s + m) % n) + 1
    let Y = e / p - y + (n + m - M) / n

    return (Y, M, D)
  }
}

struct GregorianStyleCalendarAlgorithm {
  let y: Int
  let j: Int
  let m: Int
  let n: Int
  let r: Int
  let p: Int
  let q: Int
  let v: Int
  let u: Int
  let s: Int
  let t: Int
  let w: Int
  let A: Int
  let B: Int
  let C: Int

  func toJd(Y: Int, M: Int, D: Int) -> Int {
    let h = M - m
    let g = Y + y - (n - h) / n
    let f = (h - 1 + n) % n // Check if this is same as mod
    let e = (p * g + q) / r + D - 1 - j
    var J = e + (s * f + t) / u
    J = J - (3 * ((g + A) / 100)) / 4 - C
    return J
  }

  func toDate(J: Int) -> (Int,Int,Int) {
    var f = J + j
    f = f + ((( 4 * J + B) / 146097) * 3)/4 + C
    let e = r * f + v
    let g = (e % p) / r
    let h = u * g + w
    let D = (h % s) / u + 1
    let M = ((h/s + m) % n) + 1
    let Y = e / p - y + (n + m - M) / n
    return (Y, M, D)
  }

}

struct SakaCalendarAlgorithm {
  let y: Int
  let j: Int
  let m: Int
  let n: Int
  let r: Int
  let p: Int
  let q: Int
  let v: Int
  let u: Int
  let s: Int
  let t: Int
  let w: Int
  let A: Int
  let B: Int
  let C: Int

  func toJd(Y: Int, M: Int, D: Int) -> Int {
    let h = M - m
    let g = Y + y - (n - h) / n
    let f = (h - 1 + n) % n // Check if this is same as mod
    let e = (p * g + q) / r + D - 1 - j
    let Z = f / 6
    var J = e + ((31 - Z) * f + 5 * Z) / u
    J = J - (3 * ((g + A) / 100)) / 4 - C
    return J
  }

  func toDate(J: Int) -> (Int,Int,Int) {
    var f = J + j
    f = f + ((( 4 * J + B) / 146097) * 3)/4 + C
    let e = r * f + v
    let g = (e % p) / r
    let X = g / 365
    let Z = g / 185 - X
    let s = 31 - Z
    let w = -5 * Z
    let h = u * g + w

    let D = (6 * X + h % s) / u + 1
    let M = ((h/s + m) % n) + 1
    let Y = e / p - y + (n + m - M) / n
    return (Y, M, D)
  }
}

