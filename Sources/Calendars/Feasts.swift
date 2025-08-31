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

// FeastRecords.swift

// =====================================================
// DATA: feastRecords (all with MonthDay where fixed)
// =====================================================

public let feastRecords: [FeastRecord] = [

  // ===== Universal fixed =====
  FeastRecord(id:"CANDLEMAS", kind:.fixed, julianFixed: MonthDay(2,2),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:500, validToYear:nil,
              namesByLanguage:["la":["purificatio beatae mariae","in purificatione beatae mariae","praesentatio domini"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.scandinavia,.sweden],
                                  extraNamesByLanguage:["sv_old":["kyndelsmässa","kyndelsmässodagen","kjndilsmæsso dagh"]], replaceNames:false, notes:nil),
                RegionalOverride(regions:[.scandinavia,.denmark],
                                  extraNamesByLanguage:["da_old":["kyndelmisse","kyndelsmesse","kyndelsmessedag"]], replaceNames:false, notes:nil),
                RegionalOverride(regions:[.scandinavia,.norway],
                                  extraNamesByLanguage:["no_old":["kyndelsmesse","maria renselsesdag"],"non":["kyndilsmessa"]], replaceNames:false, notes:nil)
              ]),

  FeastRecord(id:"ANNUNCIATION", kind:.fixed, julianFixed: MonthDay(3,25),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["annuntiatio beatae mariae","annuntiatione beatae mariae","in annuntiatione beatae mariae"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.scandinavia,.sweden], extraNamesByLanguage:["sv_old":["vårfrudagen","vårfrumässa"]], replaceNames:false),
                RegionalOverride(regions:[.scandinavia,.denmark], extraNamesByLanguage:["da_old":["vor frue dag","vor frue messe"]], replaceNames:false),
                RegionalOverride(regions:[.scandinavia,.norway], extraNamesByLanguage:["no_old":["vårfrudagen","vårfrumesse"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_GEORGE", kind:.fixed, julianFixed: MonthDay(4,23),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:700, validToYear:nil,
              namesByLanguage:["la":["sancti georgii","georgii"]], notes:"Common vernacular names added regionally.",
              overrides:[
                RegionalOverride(regions:[.sweden], extraNamesByLanguage:["sv_old":["sankt görans dag","göran","jöran"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["sankt jørgens dag","jørgensdag","jørgen"]], replaceNames:false),
                RegionalOverride(regions:[.norway], extraNamesByLanguage:["no_old":["jørgensdag","sankt jørgens dag"]], replaceNames:false)
              ]),

  FeastRecord(id:"PHILIP_JAMES", kind:.fixed, julianFixed: MonthDay(5,1),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["ss philippi et iacobi","philippi et iacobi"]],
              notes:"Regional ‘Valborg’ mappings via overrides.",
              overrides:[
                RegionalOverride(regions:[.sweden], extraNamesByLanguage:["sv_old":["valborgsmässa","valborgsmäss","valborgsmässoafton","valborg","apostladagen"]], replaceNames:false),
                RegionalOverride(regions:[.norway], extraNamesByLanguage:["no_old":["valborg","valborgsdag","valborgsmesse"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["valborg","valborgsdag","valborgsaften","aposteldag"]], replaceNames:false, notes:"Less prominent than in Sweden.")
              ]),

  FeastRecord(id:"NATIVITY_JOHN_BAPTIST", kind:.fixed, julianFixed: MonthDay(6,24),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["nativitas sancti ioannis baptistae","in nativitate sancti ioannis baptistae"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden], extraNamesByLanguage:["sv_old":["midsommardagen","sankt hans"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["sankthansdag","sankt hans"]], replaceNames:false),
                RegionalOverride(regions:[.norway], extraNamesByLanguage:["no_old":["sankthansdag","jonsokdag"],"non":["jonsvaka","jonsok"]], replaceNames:false)
              ]),

  FeastRecord(id:"PETER_AND_PAUL", kind:.fixed, julianFixed: MonthDay(6,29),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["ss petri et pauli","petri et pauli"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden], extraNamesByLanguage:["sv_old":["petrus och paulus","pädersmässa"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["peter og paulus","petersdag og paulusdag"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_OLAF", kind:.fixed, julianFixed: MonthDay(7,29),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:false, regions:[.scandinavia], validFromYear:1031, validToYear:nil,
              namesByLanguage:["la":["sancti olavi","olavi","s olavi"]],
              notes:"Principal Scandinavian royal saint.",
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["olsmässa","olsmæssa","olsmessa","olavsmässa"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["olufsmæsse","olavsmæsse","olavsmessedag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["olsok","olavsmessa","olavmesse","olsvaka"],"non":["ólafsmessa","olafsmessa"]],
                                 replaceNames:false, notes:"Eve forms included.")
              ]),

  FeastRecord(id:"ST_LAWRENCE", kind:.fixed, julianFixed: MonthDay(8,10),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["sancti laurentii","laurentii"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["larsmässa"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["larsmesse","laurentiusdag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["larsmesse"]], replaceNames:false)
              ]),

  FeastRecord(id:"ASSUMPTION_BVM", kind:.fixed, julianFixed: MonthDay(8,15),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["assumptio beatae mariae virginis","assumptione beatae mariae"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["jungfru marie himmelsfärd","marimesse"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["jomfru marias himmelfart","marimesse"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["jomfru marias himmelfart","marimesse"]], replaceNames:false)
              ]),

  FeastRecord(id:"NATIVITY_BVM", kind:.fixed, julianFixed: MonthDay(9,8),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["nativitas beatae mariae virginis","nativitate beatae mariae"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["jungfru marie födelsedag","lilla marimesse"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["jomfru marias fødselsdag","lille marimesse","lille marie messe"]], replaceNames:false)
              ]),

  FeastRecord(id:"HOLY_CROSS", kind:.fixed, julianFixed: MonthDay(9,14),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["exaltatio sanctae crucis"]],
              notes:"Western calendars also had Invention of the Cross (May 3).",
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["korsmässa","helga korsmässa"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["korsmesse","hellige korsmesse"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_MICHAEL", kind:.fixed, julianFixed: MonthDay(9,29),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["sancti michaelis archangeli","michaelis"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["mickelsmässa","michelsmässa","michaelmas"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["mikkelsdag","mikkelsmesse","michelsmesse"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["mikkelsmesse","mikkelsdag"]], replaceNames:false)
              ]),

  FeastRecord(id:"ALL_SAINTS", kind:.fixed, julianFixed: MonthDay(11,1),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:835, validToYear:nil,
              namesByLanguage:["la":["omnium sanctorum"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["alla helgons dag"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["allehelgensdag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["allehelgensdag"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_MARTIN", kind:.fixed, julianFixed: MonthDay(11,11),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["sancti martini","martini"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["mårtensmässa"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["mortensdag","morten bisp","mortenmesse","mortensmesse"]],
                                 replaceNames:false, notes:"Mortens- forms common."),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["mortensmesse","mortenbisp"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_ANDREW", kind:.fixed, julianFixed: MonthDay(11,30),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["sancti andreae","andreae"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["andersmässa"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["andersdag","andersmesse"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["andersmesse","andersdag"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_NICHOLAS", kind:.fixed, julianFixed: MonthDay(12,6),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["sancti nicolai","nicolai"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["nikolausdagen","sankt nils"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["sankt nikolaj","nikolajsdag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["nilsmesse","sankt nikolas dag"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_LUCY", kind:.fixed, julianFixed: MonthDay(12,13),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["sanctae luciae","luciae"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["luciadagen","lucia"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["luciadag","luciemesse"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["lussimesse","lussinatt"]], replaceNames:false, notes:"Eve form helps parsing.")
              ]),

  FeastRecord(id:"ST_THOMAS_APOSTLE", kind:.fixed, julianFixed: MonthDay(12,21),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:600, validToYear:nil,
              namesByLanguage:["la":["sancti thomae apostoli","thomae"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["tomasmässa"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["thomasdag","tomasmesse"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["tomasmesse","tomasmessedag"]], replaceNames:false)
              ]),

  FeastRecord(id:"CHRISTMAS", kind:.fixed, julianFixed: MonthDay(12,25),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["nativitas domini","natalis domini"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["juldagen","jul"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["juledag","jul"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["juledag","jul"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_STEPHEN", kind:.fixed, julianFixed: MonthDay(12,26),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["sancti stephani","stephani"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["staffansdagen","stefansmässa"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["sankt stefans dag","stefansmesse"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["sankt stefans dag","stefansmesse"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_JOHN_EVANGELIST", kind:.fixed, julianFixed: MonthDay(12,27),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["sancti ioannis evangelistae","ioannis evangelistae"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["johannes evangelistens dag"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["sankt johannes evangelistens dag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["sankt johannes evangelistens dag"]], replaceNames:false)
              ]),

  FeastRecord(id:"HOLY_INNOCENTS", kind:.fixed, julianFixed: MonthDay(12,28),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["sanctorum innocentium","in innocentibus"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["menlösa barns dag"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["de uskyldige børns dag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["de uskyldige barns dag"]], replaceNames:false)
              ]),

  // ===== Movables (unchanged, julianFixed: nil) =====
  FeastRecord(id:"ASH_WEDNESDAY", kind:.movable, julianFixed:nil, relationToEasterDays:-46,
              weekdayConstraint:3, universal:true, regions:[.universal], validFromYear:1000, validToYear:nil,
              namesByLanguage:["la":["feria quarta cinerum","cinerum"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["askonsdag"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["askeonsdag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["oskeonsdag"]], replaceNames:false)
              ]),

  FeastRecord(id:"PALM_SUNDAY", kind:.movable, julianFixed:nil, relationToEasterDays:-7,
              weekdayConstraint:0, universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["dominica palmarum","palmarum"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["palmsöndagen"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["palmesøndag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["palmesøndag"]], replaceNames:false)
              ]),

  FeastRecord(id:"MAUNDY_THURSDAY", kind:.movable, julianFixed:nil, relationToEasterDays:-3,
              weekdayConstraint:4, universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["coena domini","in coena domini"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["skärtorsdagen"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["skærtorsdag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["skjærtorsdag"]], replaceNames:false)
              ]),

  FeastRecord(id:"GOOD_FRIDAY", kind:.movable, julianFixed:nil, relationToEasterDays:-2,
              weekdayConstraint:5, universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["parasceve","feria sexta in parasceve"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["långfredagen"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["langfredag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["langfredag"]], replaceNames:false)
              ]),

  FeastRecord(id:"HOLY_SATURDAY", kind:.movable, julianFixed:nil, relationToEasterDays:-1,
              weekdayConstraint:6, universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["sabbatum sanctum"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["påskafton"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["påskeaften"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["påskeaften"]], replaceNames:false)
              ]),

  FeastRecord(id:"EASTER_SUNDAY", kind:.movable, julianFixed:nil, relationToEasterDays:0,
              weekdayConstraint:0, universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["dominica resurrectionis","pascha","in die paschae"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["påskdagen"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["påskedag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["påskedag"]], replaceNames:false)
              ]),

  FeastRecord(id:"EASTER_MONDAY", kind:.movable, julianFixed:nil, relationToEasterDays:1,
              weekdayConstraint:1, universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["feria secunda paschae"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["annandag påsk"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["2. påskedag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["2. påskedag"]], replaceNames:false)
              ]),

  FeastRecord(id:"ASCENSION", kind:.movable, julianFixed:nil, relationToEasterDays:39,
              weekdayConstraint:4, universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["ascensio domini","ascensio"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["kristi himmelsfärds dag"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["kristi himmelfarts dag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["kristi himmelfartsdag"]], replaceNames:false)
              ]),

  FeastRecord(id:"PENTECOST", kind:.movable, julianFixed:nil, relationToEasterDays:49,
              weekdayConstraint:0, universal:true, regions:[.universal], validFromYear:400, validToYear:nil,
              namesByLanguage:["la":["pentecosten","in pentecoste"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["pingstdagen"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["pinsedag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["pinsedag"]], replaceNames:false)
              ]),

  FeastRecord(id:"TRINITY_SUNDAY", kind:.movable, julianFixed:nil, relationToEasterDays:56,
              weekdayConstraint:0, universal:true, regions:[.universal], validFromYear:1000, validToYear:nil,
              namesByLanguage:["la":["dominica trinitatis","trinitatis"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["trefaldighetssöndagen"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["trinitatis søndag"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["treenighetssøndag"]], replaceNames:false)
              ]),

  FeastRecord(id:"CORPUS_CHRISTI", kind:.movable, julianFixed:nil, relationToEasterDays:60,
              weekdayConstraint:4, universal:true, regions:[.universal], validFromYear:1264, validToYear:nil,
              namesByLanguage:["la":["corpus christi","corporis christi","in festo corporis christi"]],
              notes:"Promulgated 1264; spread 13th–14th c.",
              overrides:[
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["kristi kropps dag"]], replaceNames:false),
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["kristi legemsfest"]], replaceNames:false),
                RegionalOverride(regions:[.norway],  extraNamesByLanguage:["no_old":["kristi legemsfest"]], replaceNames:false)
              ]),

  // ===== Regional Scandinavian saints =====
  FeastRecord(id:"ST_SIGFRID", kind:.fixed, julianFixed: MonthDay(2,15),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:false, regions:[.sweden], validFromYear:1150, validToYear:nil,
              namesByLanguage:["la":["sancti sigfridi"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden], extraNamesByLanguage:["sv_old":["sankt sigfrids dag"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_ERIC", kind:.fixed, julianFixed: MonthDay(5,18),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:false, regions:[.sweden], validFromYear:1160, validToYear:nil,
              namesByLanguage:["la":["sancti erici","erici"]],
              notes:nil,
              overrides:[
                RegionalOverride(regions:[.sweden], extraNamesByLanguage:["sv_old":["eriksmässa"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_BRIDGET", kind:.fixed, julianFixed: MonthDay(10,7),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:false, regions:[.sweden], validFromYear:1391, validToYear:nil,
              namesByLanguage:["la":["sanctae birgittae"]],
              notes:"Canonized 1391; strong Swedish cult.",
              overrides:[
                RegionalOverride(regions:[.sweden], extraNamesByLanguage:["sv_old":["den heliga birgittas dag","brigida"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_CANUTE_JAN7", kind:.fixed, julianFixed: MonthDay(1,7),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:false, regions:[.denmark,.sweden], validFromYear:1170, validToYear:nil,
              namesByLanguage:["la":["sancti canuti"]],
              notes:"Canute Lavard.",
              overrides:[
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["knud lavards dag","knud lavards messe","knudsdag (7. jan)"]],
                                 replaceNames:false, notes:nil),
                RegionalOverride(regions:[.sweden],  extraNamesByLanguage:["sv_old":["knutsmässa","knutsmässa (7 jan)"]],
                                 replaceNames:false, notes:nil)
              ]),

  FeastRecord(id:"ST_CANUTE_IV", kind:.fixed, julianFixed: MonthDay(7,10),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:false, regions:[.denmark], validFromYear:1100, validToYear:nil,
              namesByLanguage:["la":["sancti canuti regis"]],
              notes:"King Canute IV (the Holy).",
              overrides:[
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["knud den hellige","kong knuds dag","knudsdag (10. jul)"]],
                                 replaceNames:false, notes:nil)
              ]),

  FeastRecord(id:"ST_ANSGAR", kind:.fixed, julianFixed: MonthDay(2,3),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:false, regions:[.denmark], validFromYear:865, validToYear:nil,
              namesByLanguage:["la":["sancti anscharii","ansgarii"]],
              notes:"Missionary to Scandinavia.",
              overrides:[
                RegionalOverride(regions:[.denmark], extraNamesByLanguage:["da_old":["ansgarsdag","ansgarsmesse"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_HALLVARD", kind:.fixed, julianFixed: MonthDay(5,15),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:false, regions:[.norway], validFromYear:1130, validToYear:nil,
              namesByLanguage:["la":["sancti hallvardi"]],
              notes:"Patron of Oslo.",
              overrides:[
                RegionalOverride(regions:[.norway], extraNamesByLanguage:["no_old":["hallvardsmesse","sankt hallvards dag"]], replaceNames:false)
              ]),

  FeastRecord(id:"ST_SUNNIVA", kind:.fixed, julianFixed: MonthDay(7,8),
              relationToEasterDays:nil, weekdayConstraint:nil,
              universal:false, regions:[.norway], validFromYear:1200, validToYear:nil,
              namesByLanguage:["la":["sanctae sunnivae"]],
              notes:"Regional cult (Selja).",
              overrides:[
                RegionalOverride(regions:[.norway], extraNamesByLanguage:["no_old":["sunnivamesse","sankta sunniva"]], replaceNames:false)
              ])
]

public struct SwedishFeasts {
  public let feasts = FeastRecordProvider(
    records: feastRecords,
    config: .init(activeRegions: [.universal, .scandinavia, .sweden])
  )
  public let parser: MedievalFeastParser
  public let resolver: FeastDateResolver
  public init() {
    // Parser + resolver as before
    parser = MedievalFeastParser(feastProvider: feasts,
                                lexiconProvider: StaticLexiconProvider())
    resolver = FeastDateResolver(feastProvider: feasts)
  }

  public func resolve(_ year: Int, _ phrase: String) -> FeastDateResolver.Response? {
    guard let p = parser.parse(phrase) else { return nil }
    let req = FeastDateResolver.Request(year: year, feastID: p.anchorFeastID, offsetDays: p.offsetDays, weekday: p.weekday)
    return resolver.resolve(req)
  }
}
