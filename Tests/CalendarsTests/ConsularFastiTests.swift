import Testing
@testable import Calendars

@Suite("Republican consular fasti")
struct ConsularFastiTests {
    private let calendar = RegnalCalendar.shared

    @Test("Roman chronology conversions preserve the historical year")
    func romanChronologyConversions() {
        #expect(RomanChronology.alc(fromVarronianAUC: 245) == 1)
        #expect(RomanChronology.varronianAUC(fromALC: 1) == 245)
        #expect(
            RomanChronology.convert(auc: 245, from: .varronian, to: .cato) == 244
        )
        #expect(
            RomanChronology.convert(auc: 245, from: .varronian, to: .polybius) == 242
        )
        #expect(
            RomanChronology.convert(auc: 242, from: .polybius, to: .varronian) == 245
        )
    }

    @Test("Consular year bounds come from the Roman calendar")
    func consularYearUsesRomanCalendarBounds() throws {
        let year = try #require(calendar.consularYear(auc: 245))

        #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: 245))
        #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: 245))
        #expect(year.startJDN != nil)
        #expect(year.endJDN != nil)
    }

    @Test("Eponymous year is derived from ordinary tenures only")
    func eponymousYearExcludesSuffects() throws {
        let year = try #require(calendar.consularYear(auc: 245))

        #expect(year.consulList.map(\.personID) == [
            "P_LUCIUS_IUNIUS_BRUTUS",
            "P_LUCIUS_TARQUINIUS_COLLATINUS"
        ])
        #expect(year.suffectList.map(\.personID) == [
            "P_PUBLIUS_VALERIUS_POPLICOLA",
            "P_SPURIUS_LUCRETIUS_TRICIPITINUS",
            "P_MARCUS_HORATIUS_PULVILLUS"
        ])
    }

    @Test("Consulship number is independent of the annual seat")
    func consulshipNumberIsNotSeat() throws {
        let year = try #require(calendar.consularYear(auc: 247))
        let poplicola = try #require(
            year.consulList.first { $0.personID == "P_PUBLIUS_VALERIUS_POPLICOLA" }
        )
        let pulvillus = try #require(
            year.consulList.first { $0.personID == "P_MARCUS_HORATIUS_PULVILLUS" }
        )

        #expect(poplicola.seat == 1)
        #expect(poplicola.consulshipNumber == 3)
        #expect(pulvillus.seat == 2)
        #expect(pulvillus.consulshipNumber == 2)
    }

    @Test("Early Republican records retain tradition and source provenance")
    func earlyRecordsAreExplicitlyTraditionalAndSourced() throws {
        let tenure = try #require(
            calendar.tenures.first { $0.id == "TENURE_AUC_245_CONSUL_1" }
        )
        let consular = try #require(tenure.consular)

        #expect(tenure.ordinal == nil)
        #expect(tenure.certainty == "low")
        #expect(consular.dataset == .republican)
        #expect(consular.tradition == .traditional)
        #expect(consular.sources.count == 2)
        #expect(consular.sources.allSatisfy { $0.url.hasPrefix("https://") })
    }

    @Test("The sourced starter table contains no heuristic genitives")
    func starterTableDoesNotInventGenitives() throws {
        let brutus = try #require(calendar.person(forID: "P_LUCIUS_IUNIUS_BRUTUS"))
        #expect(!brutus.variants.contains { $0.casus == "gen" })
    }

    @Test("The sourced opening sequence is continuous through 451 BCE")
    func openingSequenceIsContinuous() throws {
        for auc in 245...303 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
        }
    }

    @Test("Repeated consulships continue independently of seat")
    func repeatedConsulshipsContinueThrough504BCE() throws {
        let year = try #require(calendar.consularYear(auc: 250))
        let poplicola = try #require(
            year.consulList.first { $0.personID == "P_PUBLIUS_VALERIUS_POPLICOLA" }
        )
        let tricipitinus = try #require(
            year.consulList.first { $0.personID == "P_TITUS_LUCRETIUS_TRICIPITINUS" }
        )

        #expect(poplicola.seat == 1)
        #expect(poplicola.consulshipNumber == 4)
        #expect(tricipitinus.seat == 2)
        #expect(tricipitinus.consulshipNumber == 2)
    }

    @Test("Uncertain source claims are not silently resolved")
    func uncertainClaimsRemainExplicit() throws {
        let larcius = try #require(
            calendar.tenures.first { $0.id == "TENURE_AUC_248_CONSUL_1" }
        )
        let metadata = try #require(larcius.consular)

        #expect(metadata.tradition == .disputed)
        #expect(metadata.consulshipNumber == nil)
        #expect(larcius.notes?.contains("Rufus/Flavus") == true)
    }

    @Test("Alternative praenomina remain explicit source claims")
    func alternativePraenomenIsPreserved() throws {
        let veturius = try #require(
            calendar.tenures.first { $0.id == "TENURE_AUC_255_CONSUL_2" }
        )
        let metadata = try #require(veturius.consular)
        let person = try #require(calendar.person(forID: veturius.personID))

        #expect(metadata.tradition == .alternative)
        #expect(veturius.status == "disputed")
        #expect(person.variants.contains { $0.form == "C. (P.?) Veturius Geminus Cicurinus" })
    }

    @Test("Titus Larcius has a separately numbered second consulship")
    func larciusSecondConsulshipIsNumbered() throws {
        let year = try #require(calendar.consularYear(auc: 256))
        let larcius = try #require(
            year.consulList.first { $0.personID == "P_TITUS_LARCIUS_FLAVUS" }
        )

        #expect(larcius.seat == 2)
        #expect(larcius.consulshipNumber == 2)
    }

    @Test("The 478 BCE boundary retains its uncertain suffect")
    func year478RetainsUncertainSuffect() throws {
        let year = try #require(calendar.consularYear(auc: 276))
        let suffect = try #require(year.suffectList.first)
        let tenure = try #require(
            calendar.tenures.first { $0.id == "TENURE_AUC_276_SUFFECT_1" }
        )

        #expect(year.consulList.count == 2)
        #expect(suffect.personID == "P_OPITER_VERGINIUS_ESQUILINUS")
        #expect(tenure.consular?.tradition == .disputed)
        #expect(tenure.consular?.consulshipNumber == nil)
    }

    @Test("Alternative 473 BCE tradition remains available without enlarging the primary pair")
    func year473ProjectsPrimaryPairAndRetainsAlternative() throws {
        let year = try #require(calendar.consularYear(auc: 281))
        let alternative = try #require(
            calendar.tenures.first { $0.id == "TENURE_AUC_281_CONSUL_2_ALTERNATIVE" }
        )

        #expect(year.consulList.count == 2)
        #expect(year.consulList[1].personID == "P_VOPISCUS_IULIUS_IULLUS")
        #expect(alternative.personID == "P_OPITER_VERGINIUS_473")
        #expect(alternative.consular?.seat == 2)
        #expect(alternative.consular?.tradition == .alternative)
        #expect(alternative.consular?.alternativeToTenureID == "TENURE_AUC_281_CONSUL_2")
    }

    @Test("Later homonymous Fabius has a distinct consulship sequence")
    func laterFabiusSequenceIsNotConflated() throws {
        let first = try #require(calendar.consularYear(auc: 287))
        let second = try #require(calendar.consularYear(auc: 289))

        #expect(first.consulList[1].personID == "P_QUINTUS_FABIUS_VIBULANUS_467")
        #expect(first.consulList[1].consulshipNumber == 1)
        #expect(second.consulList[0].personID == "P_QUINTUS_FABIUS_VIBULANUS_467")
        #expect(second.consulList[0].consulshipNumber == 2)
    }

    @Test("The 460 BCE boundary retains its uncertain suffect")
    func year460RetainsUncertainSuffect() throws {
        let year = try #require(calendar.consularYear(auc: 294))
        let suffect = try #require(year.suffectList.first)

        #expect(year.consulList.count == 2)
        #expect(suffect.personID == "P_LUCIUS_QUINCTIUS_CINCINNATUS")
        #expect(suffect.consulshipNumber == nil)
    }

    @Test("The fragmentary 458 BCE colleague remains unresolved")
    func year458RetainsFragmentaryColleague() throws {
        let year = try #require(calendar.consularYear(auc: 296))
        let fragment = try #require(
            calendar.tenures.first { $0.id == "TENURE_AUC_296_CONSUL_2" }
        )

        #expect(year.consulList[1].personID == "P_UNKNOWN_CARVETUS_458")
        #expect(fragment.consular?.tradition == .reconstructed)
        #expect(fragment.consular?.consulshipNumber == nil)
    }

    @Test("The competing 457 colleges remain paired alternatives")
    func year457RetainsCompetingColleges() throws {
        let year = try #require(calendar.consularYear(auc: 297))
        let alternatives = calendar.tenures.filter {
            $0.start.first?.ymd?.year == 297 && $0.consular?.alternativeToTenureID != nil
        }

        #expect(year.consulList.map(\.personID) == [
            "P_GAIUS_HORATIUS_PULVILLUS_457",
            "P_QUINTUS_MINUCIUS_ESQUILINUS"
        ])
        #expect(alternatives.count == 2)
        #expect(Set(alternatives.compactMap { $0.consular?.seat }) == [1, 2])
    }

    @Test("The 450 BCE decemvirs remain an extraordinary college")
    func year450IsNotProjectedAsAnOrdinaryConsularYear() throws {
        let decemvirs = calendar.tenures(forOffice: "OFFICE_DECEMVIR_LEGIBUS_SCRIBUNDIS").filter {
            $0.start.first?.ymd?.year == 304
        }

        #expect(calendar.consularYear(auc: 304) == nil)
        #expect(decemvirs.count == 10)
        #expect(decemvirs.allSatisfy { $0.consular?.role == .decemvir })
        #expect(Set(decemvirs.compactMap { $0.consular?.seat }) == Set(1...10))
    }

    @Test("Ordinary consular dating resumes after the decemvirate")
    func ordinarySequenceResumesThrough445BCE() throws {
        for auc in 305...309 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
        }
    }

    @Test("The first consular tribunes do not become an ordinary consular pair")
    func year444RetainsItsThreeMemberConsularTribunate() throws {
        let tribunes = calendar.tenures(forOffice: "OFFICE_CONSULAR_TRIBUNE").filter {
            $0.start.first?.ymd?.year == 310
        }

        #expect(calendar.consularYear(auc: 310) == nil)
        #expect(tribunes.count == 3)
        #expect(tribunes.allSatisfy { $0.consular?.role == .consularTribune })
        #expect(Set(tribunes.compactMap { $0.consular?.seat }) == Set(1...3))
    }

    @Test("The mixed sequence through 426 BCE projects only ordinary colleges")
    func mixedSequenceThrough426BCE() throws {
        let ordinaryYears = Array(311...315) + Array(317...320) + Array(323...327)
        let consularTribuneYears = [316, 321, 322, 328]

        for auc in ordinaryYears {
            #expect(calendar.consularYear(auc: auc)?.consulList.count == 2)
        }
        for auc in consularTribuneYears {
            #expect(calendar.consularYear(auc: auc) == nil)
        }
    }

    @Test("The three competing traditions for 434 BCE remain distinguishable")
    func year434RetainsCompetingConstitutionalTraditions() throws {
        let year = try #require(calendar.consularYear(auc: 320))
        let alternativeConsuls = calendar.tenures.filter {
            $0.start.first?.ymd?.year == 320 &&
                $0.consular?.role == .ordinaryConsul &&
                $0.consular?.alternativeToTenureID != nil
        }
        let alternativeTribunes = calendar.tenures.filter {
            $0.start.first?.ymd?.year == 320 &&
                $0.consular?.role == .consularTribune
        }

        #expect(year.consulList.count == 2)
        #expect(alternativeConsuls.count == 2)
        #expect(alternativeTribunes.count == 3)
        #expect(alternativeTribunes.allSatisfy { $0.consular?.tradition == .alternative })
    }

    @Test("The alternative 428 BCE college does not enlarge its primary pair")
    func year428RetainsAlternativeCollege() throws {
        let year = try #require(calendar.consularYear(auc: 326))
        let alternatives = calendar.tenures.filter {
            $0.start.first?.ymd?.year == 326 && $0.consular?.alternativeToTenureID != nil
        }

        #expect(year.consulList.count == 2)
        #expect(alternatives.count == 2)
        #expect(Set(alternatives.compactMap { $0.consular?.seat }) == Set(1...2))
    }

    @Test("The corrected 425 BCE ALC value is documented in provenance")
    func year425CorrectsDuplicatedALCNumber() throws {
        let tenures = calendar.tenures(forOffice: "OFFICE_CONSULAR_TRIBUNE").filter {
            $0.start.first?.ymd?.year == 329
        }

        #expect(tenures.count == 4)
        #expect(tenures.allSatisfy {
            $0.consular?.sources.first?.note?.contains("corrected here") == true
        })
    }

    @Test("The mixed sequence through 409 BCE projects only ordinary colleges")
    func mixedSequenceThrough409BCE() throws {
        let ordinaryYears = [331, 333] + Array(341...345)
        let consularTribuneYears = [329, 330, 332] + Array(334...340)

        for auc in ordinaryYears {
            #expect(calendar.consularYear(auc: auc)?.consulList.count == 2)
        }
        for auc in consularTribuneYears {
            #expect(calendar.consularYear(auc: auc) == nil)
        }
    }

    @Test("Alternative members in 420 and 417 BCE remain linked to their seats")
    func alternativeTribunesRemainLinked() throws {
        let alternatives = calendar.tenures.filter {
            [334, 337].contains($0.start.first?.ymd?.year ?? 0) &&
                $0.consular?.alternativeToTenureID != nil
        }

        #expect(alternatives.count == 2)
        #expect(Set(alternatives.compactMap { $0.consular?.seat }) == Set([1, 3]))
        #expect(alternatives.allSatisfy { $0.consular?.tradition == .alternative })
    }

    @Test("The consular-tribune sequence through 394 BCE stays outside eponymous projection")
    func consularTribuneSequenceThrough394BCE() throws {
        for auc in 346...360 {
            #expect(calendar.consularYear(auc: auc) == nil)
            #expect(
                calendar.tenures(forOffice: "OFFICE_CONSULAR_TRIBUNE").contains {
                    $0.start.first?.ymd?.year == auc
                }
            )
        }
    }

    @Test("The enlarged 403 BCE college preserves conjectural members")
    func year403PreservesConjecturalAdditionalMembers() {
        let college = calendar.tenures(forOffice: "OFFICE_CONSULAR_TRIBUNE").filter {
            $0.start.first?.ymd?.year == 351
        }
        let reconstructed = college.filter { $0.consular?.tradition == .reconstructed }

        #expect(college.count == 9)
        #expect(reconstructed.count == 3)
        #expect(Set(reconstructed.compactMap { $0.consular?.seat }) == Set(7...9))
    }

    @Test("The 393 BCE ordinary pair and suffects remain separate")
    func year393SeparatesOrdinaryAndSuffectConsuls() throws {
        let year = try #require(calendar.consularYear(auc: 361))

        #expect(year.consulList.count == 2)
        #expect(year.suffectList.count == 2)
        #expect(year.consulList[0].consulshipNumber == 1)
        #expect(year.suffectList.map(\.seat) == [1, 2])
    }

    @Test("Ordinary consuls yield again to tribunes from 391 through 386 BCE")
    func sequenceThrough386BCE() throws {
        #expect(calendar.consularYear(auc: 362)?.consulList.count == 2)

        for auc in 363...368 {
            #expect(calendar.consularYear(auc: auc) == nil)
            #expect(
                calendar.tenures(forOffice: "OFFICE_CONSULAR_TRIBUNE").filter {
                    $0.start.first?.ymd?.year == auc
                }.count == 6
            )
        }
    }

    @Test("The consular-tribune sequence continues through 376 BCE")
    func sequenceThrough376BCE() {
        for auc in 369...378 {
            let college = calendar.tenures(forOffice: "OFFICE_CONSULAR_TRIBUNE").filter {
                $0.start.first?.ymd?.year == auc
            }

            #expect(calendar.consularYear(auc: auc) == nil)
            #expect(!college.isEmpty)
        }
    }

    @Test("The confused 380 BCE tradition remains explicitly disputed")
    func year380IsExplicitlyConfused() {
        let college = calendar.tenures(forOffice: "OFFICE_CONSULAR_TRIBUNE").filter {
            $0.start.first?.ymd?.year == 374
        }

        #expect(college.count == 9)
        #expect(college.allSatisfy { $0.consular?.tradition == .disputed })
        #expect(college.allSatisfy { $0.notes?.contains("confused") == true })
    }

    @Test("The five traditional anarchy years are sourced absence assertions")
    func anarchyYearsAreNotFictitiousTenures() throws {
        for auc in 379...383 {
            let gap = try #require(calendar.magistracyGap(auc: auc))

            #expect(gap.kind == .noCuruleMagistrates)
            #expect(gap.tradition == .fabricatedVarronian)
            #expect(calendar.consularYear(auc: auc) == nil)
            #expect(!calendar.tenures.contains {
                $0.start.first?.calendar == "AUC" &&
                    $0.start.first?.ymd?.year == auc &&
                    calendar.offices[$0.officeID]?.polityID == "POLITY_ROMAN_REPUBLIC"
            })
        }
    }

    @Test("Magistracies resume after the anarchy tradition")
    func sequenceResumesThrough360BCE() {
        for auc in 384...387 {
            #expect(calendar.consularYear(auc: auc) == nil)
            #expect(
                calendar.tenures(forOffice: "OFFICE_CONSULAR_TRIBUNE").contains {
                    $0.start.first?.ymd?.year == auc
                }
            )
        }

        for auc in 388...394 {
            #expect(calendar.consularYear(auc: auc)?.consulList.count == 2)
        }
    }

    @Test("The ordinary sequence continues through 350 BCE")
    func ordinarySequenceThrough350BCE() throws {
        for auc in 395...404 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }

        let year354 = try #require(calendar.consularYear(auc: 400))
        #expect(year354.consulList[1].personID == "P_TITUS_QUINCTIUS_POENUS_CAPITOLINUS_CRISPINUS")
        #expect(
            calendar.tenures.contains {
                $0.id == "TENURE_AUC_400_CONSUL_2_ALTERNATIVE" &&
                    $0.consular?.tradition == .alternative
            }
        )
    }

    @Test("The ordinary sequence continues through 334 BCE")
    func ordinarySequenceThrough334BCE() throws {
        for auc in 405...420 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }

        let alternatives = calendar.tenures.filter {
            $0.start.first?.ymd?.year == 405 &&
                $0.consular?.alternativeToTenureID != nil
        }
        #expect(alternatives.count == 2)
    }

    @Test("The 336 BCE ALC correction is explicit")
    func year336CorrectsALCTranscription() {
        let tenures = calendar.tenures.filter {
            $0.start.first?.calendar == "AUC" && $0.start.first?.ymd?.year == 418
        }

        #expect(tenures.count == 2)
        #expect(tenures.allSatisfy {
            $0.consular?.sources.first?.note?.contains("corrected here") == true
        })
        #expect(RomanChronology.alc(fromVarronianAUC: 418) == 174)
    }

    @Test("Fabricated dictator-only years do not become consular years")
    func dictatorOnlyYearsRemainExplicitFabrications() throws {
        for auc in [421, 430] {
            #expect(calendar.consularYear(auc: auc) == nil)
            let dictator = try #require(
                calendar.tenures(forOffice: "OFFICE_DICTATOR").first {
                    $0.start.first?.ymd?.year == auc
                }
            )
            #expect(dictator.consular?.role == .dictator)
            #expect(dictator.consular?.tradition == .fabricatedVarronian)
        }
    }

    @Test("The ordinary sequence between dictator insertions remains intact")
    func ordinarySequenceThrough325BCE() throws {
        for auc in 422...429 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
        }

        let alternatives = calendar.tenures.filter {
            $0.start.first?.ymd?.year == 426 &&
                $0.consular?.alternativeToTenureID != nil
        }
        #expect(alternatives.count == 2)
    }

    @Test("The ordinary sequence continues through 310 BCE")
    func ordinarySequenceThrough310BCE() throws {
        for auc in 431...444 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }
    }

    @Test("The 309 BCE dictator year remains a fabricated non-consular insertion")
    func year309IsFabricatedDictatorYear() throws {
        #expect(calendar.consularYear(auc: 445) == nil)
        let dictator = try #require(
            calendar.tenures(forOffice: "OFFICE_DICTATOR").first {
                $0.start.first?.ymd?.year == 445
            }
        )

        #expect(dictator.personID == "P_LUCIUS_PAPIRIUS_CURSOR_326")
        #expect(dictator.consular?.tradition == .fabricatedVarronian)
    }

    @Test("The sequence reaches 290 BCE around the final dictator insertion")
    func sequenceThrough290BCE() throws {
        for auc in Array(446...452) + Array(454...464) {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
        }

        #expect(calendar.consularYear(auc: 453) == nil)
        #expect(
            calendar.tenures(forOffice: "OFFICE_DICTATOR").contains {
                $0.start.first?.ymd?.year == 453 &&
                    $0.consular?.tradition == .fabricatedVarronian
            }
        )
    }

    @Test("The 299 BCE suffect remains outside the primary pair")
    func year299RetainsSuffect() throws {
        let year = try #require(calendar.consularYear(auc: 455))

        #expect(year.consulList.count == 2)
        #expect(year.suffectList.count == 1)
        #expect(year.suffectList[0].personID == "P_MARCUS_VALERIUS_MAXIMUS_CORVUS")
        #expect(year.suffectList[0].consulshipNumber == 6)
    }

    @Test("The ordinary sequence continues through 270 BCE")
    func ordinarySequenceThrough270BCE() throws {
        for auc in 465...484 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }

        let year274 = try #require(calendar.consularYear(auc: 480))
        #expect(year274.consulList[0].consulshipNumber == 3)
    }

    @Test("Broughton reconciliation restores omitted middle-Republic suffects")
    func broughtonReconciliationRestoresOmittedSuffects() throws {
        #expect(calendar.consularYear(auc: 449)?.suffectList.map(\.personID).contains(
            "P_MARCUS_FULVIUS_CURVUS_PAETINUS_305"
        ) == true)
        #expect(calendar.consularYear(auc: 498)?.suffectList.map(\.personID).contains(
            "P_MARCUS_ATILIUS_REGULUS_256"
        ) == true)
        #expect(calendar.consularYear(auc: 578)?.suffectList.map(\.personID).contains(
            "P_GAIUS_VALERIUS_LAEVINUS_176"
        ) == true)

        let disputedDecius = try #require(calendar.tenures.first {
            $0.personID == "P_DECIUS_MUS_265"
        })
        #expect(disputedDecius.certainty == "low")
        #expect(disputedDecius.status == "disputed")
        #expect(disputedDecius.consular?.tradition == .disputed)
        #expect(disputedDecius.notes?.contains("Degrassi") == true)
    }

    @Test("The ordinary sequence continues through 250 BCE")
    func ordinarySequenceThrough250BCE() throws {
        for auc in 485...504 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }
    }

    @Test("The ordinary sequence continues through 230 BCE")
    func ordinarySequenceThrough230BCE() throws {
        for auc in 505...524 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }
    }

    @Test("The ordinary sequence continues through 210 BCE")
    func ordinarySequenceThrough210BCE() throws {
        for auc in 525...544 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
        }

        #expect(calendar.consularYear(auc: 537)?.suffectList.count == 1)
        #expect(calendar.consularYear(auc: 539)?.suffectList.count == 2)
        #expect(calendar.tenures.filter {
            $0.start.first?.ymd?.year == 534 && $0.consular?.alternativeToTenureID != nil
        }.count == 2)
    }

    @Test("The ordinary sequence continues through 190 BCE")
    func ordinarySequenceThrough190BCE() throws {
        for auc in 545...564 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(RomanChronology.alc(fromVarronianAUC: auc) == auc - 244)
        }
    }

    @Test("The ordinary sequence continues through 170 BCE")
    func ordinarySequenceThrough170BCE() throws {
        for auc in 565...584 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
        }

        #expect(calendar.consularYear(auc: 574)?.suffectList.count == 1)
    }

    @Test("The ordinary sequence continues through 150 BCE")
    func ordinarySequenceThrough150BCE() throws {
        for auc in 585...604 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }

        #expect(calendar.consularYear(auc: 592)?.suffectList.count == 2)

        let year150 = try #require(calendar.consularYear(auc: 604))
        #expect(year150.consulList.map(\.personID) == [
            "P_TITUS_QUINCTIUS_FLAMININUS_150",
            "P_MANIUS_ACILIUS_BALBUS_150"
        ])

        let year154 = try #require(calendar.consularYear(auc: 600))
        #expect(year154.suffectList.map(\.personID) == [
            "P_MANIUS_ACILIUS_GLABRIO_154"
        ])
        #expect(year154.noteText.contains("died on the way to his province"))
    }

    @Test("The ordinary sequence continues through 130 BCE")
    func ordinarySequenceThrough130BCE() throws {
        for auc in 605...624 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }

        let year147 = try #require(calendar.consularYear(auc: 607))
        let year134 = try #require(calendar.consularYear(auc: 620))
        #expect(calendar.consularYear(auc: 605)?.consulList.map(\.personID) == [
            "P_LUCIUS_MARCIUS_CENSORINUS_149",
            "P_MANIUS_MANILIUS_149"
        ])
        #expect(year147.consulList[0].personID == year134.consulList[0].personID)
        #expect(year147.consulList[0].consulshipNumber == 1)
        #expect(year134.consulList[0].consulshipNumber == 2)
        #expect(calendar.consularYear(auc: 624)?.suffectList.map(\.personID) == [
            "P_APPIUS_CLAUDIUS_PULCHER_130"
        ])

        let broughtonTenures = calendar.tenures.filter { tenure in
            guard let auc = tenure.start.first?.ymd?.year else { return false }
            guard (605...624).contains(auc) else { return false }
            return tenure.consular?.role == .ordinaryConsul
                || tenure.consular?.role == .suffectConsul
        }
        #expect(broughtonTenures.count == 41)
        #expect(broughtonTenures.allSatisfy { tenure in
            tenure.consular?.sources.contains { source in
                source.title.contains("Broughton")
            } == true
        })
    }

    @Test("The Broughton sequence continues through 110 BCE")
    func broughtonSequenceThrough110BCE() throws {
        for auc in 625...644 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }

        let scipio = try #require(calendar.consularYear(auc: 643)?.consulList.first)
        #expect(scipio.personID == "P_PUBLIUS_CORNELIUS_SCIPIO_NASICA_SERAPIO_111")
        #expect(calendar.consularYear(auc: 643)?.suffectList.isEmpty == true)

        let broughtonTenures = calendar.tenures.filter { tenure in
            guard let auc = tenure.start.first?.ymd?.year else { return false }
            return (625...644).contains(auc) && tenure.consular?.role == .ordinaryConsul
        }
        #expect(broughtonTenures.count == 40)
        #expect(broughtonTenures.allSatisfy { tenure in
            tenure.consular?.sources.contains { source in
                source.title.contains("Broughton")
            } == true
        })
        #expect(broughtonTenures.first { tenure in
            tenure.personID == "P_PUBLIUS_CORNELIUS_SCIPIO_NASICA_SERAPIO_111"
        }?.notes?.contains("died in office") == true)
    }

    @Test("The Broughton sequence continues through 90 BCE")
    func broughtonSequenceThrough90BCE() throws {
        for auc in 645...664 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }

        #expect(calendar.consularYear(auc: 646)?.suffectList.map(\.personID) == [
            "P_MARCUS_AURELIUS_SCAURUS_108"
        ])

        let mariusAUCs = [647, 650, 651, 652, 653, 654]
        for (index, auc) in mariusAUCs.enumerated() {
            let marius = try #require(calendar.consularYear(auc: auc)?.consulList.first {
                $0.personID == "P_GAIUS_MARIUS"
            })
            #expect(marius.consulshipNumber == index + 1)
        }

        let lateVolumeTenures = calendar.tenures.filter { tenure in
            guard let auc = tenure.start.first?.ymd?.year else { return false }
            return (655...664).contains(auc) && tenure.consular?.role == .ordinaryConsul
        }
        #expect(lateVolumeTenures.count == 20)
        #expect(lateVolumeTenures.allSatisfy { tenure in
            tenure.consular?.sources.allSatisfy { $0.title.hasSuffix("vol. II") } == true
        })
    }

    @Test("The Broughton sequence continues through 70 BCE")
    func broughtonSequenceThrough70BCE() throws {
        for auc in 665...684 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }

        #expect(calendar.consularYear(auc: 667)?.suffectList.map(\.personID) == [
            "P_LUCIUS_CORNELIUS_MERULA_87"
        ])
        #expect(calendar.consularYear(auc: 668)?.suffectList.map(\.personID) == [
            "P_LUCIUS_VALERIUS_FLACCUS_86"
        ])

        for (auc, number) in [(667, 1), (668, 2), (669, 3), (670, 4)] {
            let cinna = try #require(calendar.consularYear(auc: auc)?.consulList.first {
                $0.personID == "P_LUCIUS_CORNELIUS_CINNA"
            })
            #expect(cinna.consulshipNumber == number)
        }
        #expect(calendar.consularYear(auc: 668)?.consulList.first {
            $0.personID == "P_GAIUS_MARIUS"
        }?.consulshipNumber == 7)
        #expect(calendar.consularYear(auc: 674)?.consulList.first {
            $0.personID == "P_LUCIUS_CORNELIUS_SULLA_FELIX"
        }?.consulshipNumber == 2)
    }

    @Test("The Broughton sequence continues through 50 BCE")
    func broughtonSequenceThrough50BCE() throws {
        for auc in 685...704 {
            let year = try #require(calendar.consularYear(auc: auc))
            #expect(year.consulList.count == 2)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }

        let year68 = try #require(calendar.consularYear(auc: 686))
        #expect(year68.suffectList.isEmpty)
        #expect(year68.noteText.contains("died before entering office"))

        let year52 = try #require(calendar.consularYear(auc: 702))
        #expect(year52.consulList.map(\.personID) == [
            "P_GNAEUS_POMPEIUS_MAGNUS",
            "P_QUINTUS_CAECILIUS_METELLUS_PIUS_SCIPIO_NASICA_52"
        ])
        #expect(year52.consulList[0].consulshipNumber == 3)
        #expect(year52.noteText.contains("sole consul"))
        #expect(year52.noteText.contains("final five months"))

        let year55 = try #require(calendar.consularYear(auc: 699))
        #expect(year55.consulList.map(\.consulshipNumber) == [2, 2])
    }

    @Test("The Broughton Republican sequence reaches 31 BCE")
    func broughtonRepublicanSequenceReaches31BCE() throws {
        for auc in 705...723 {
            let year = try #require(calendar.consularYear(auc: auc))
            let expectedOrdinaries = [709, 723].contains(auc) ? 1 : 2
            #expect(year.consulList.count == expectedOrdinaries)
            #expect(year.startJDN == RomanCalendar.shared.startOfYearJDN(year: auc))
            #expect(year.endJDN == RomanCalendar.shared.endOfYearJDN(year: auc))
        }

        #expect(calendar.consularYear(auc: 709)?.suffectList.count == 3)
        #expect(calendar.consularYear(auc: 711)?.suffectList.count == 4)
        #expect(calendar.consularYear(auc: 720)?.suffectList.count == 4)
        #expect(calendar.consularYear(auc: 721)?.suffectList.count == 6)
        #expect(calendar.consularYear(auc: 723)?.suffectList.count == 3)

        let octavianYears = [(711, 1), (721, 2), (723, 3)]
        for (auc, number) in octavianYears {
            let year = try #require(calendar.consularYear(auc: auc))
            let officeholder = try #require((year.consulList + year.suffectList).first {
                ["P_GAIUS_IULIUS_CAESAR_OCTAVIANUS", "P_IMPERATOR_CAESAR_DIVI_FILIUS"]
                    .contains($0.personID)
            })
            #expect(officeholder.consulshipNumber == number)
        }

        let year31 = try #require(calendar.consularYear(auc: 723))
        #expect(year31.consulList.map(\.personID) == ["P_IMPERATOR_CAESAR_DIVI_FILIUS"])
        #expect(year31.noteText.contains("deprived before entering office"))
        #expect(year31.suffectList.map(\.personID) == [
            "P_MARCUS_VALERIUS_MESSALLA_CORVINUS_31",
            "P_MARCUS_TITIUS_31",
            "P_GNAEUS_POMPEIUS_31"
        ])
    }
}
