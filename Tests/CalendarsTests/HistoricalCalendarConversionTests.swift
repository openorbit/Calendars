import Testing
@testable import Calendars

@Test("Livy's 190 BCE eclipse aligns the displaced Roman Republican calendar")
func livySolarEclipseRomanRepublicanConversion() {
  // Livy 37.4.4 records a solar eclipse on 11 Quintilis in 564 AUC.
  // Astronomical calculation identifies it as 14 March 190 BCE (Julian).
  // https://academic.oup.com/book/27201/chapter-abstract/196653306
  // In the reconstruction table, the AUC year has a leading March fragment;
  // numbered slot 1 is April, making Quintilis slot 4.
  let roman = RomanCalendar.shared.jdn(forYear: 564, month: 4, day: 11)
  let julian = JulianCalendar.toJDN(Y: -189, M: 3, D: 14)

  #expect(roman == julian)
}

@Test("The Pydna eclipse aligns Roman September with Julian June")
func pydnaEclipseRomanRepublicanConversion() {
  // Livy 44.37 records the eclipse as 3 September 586 AUC; astronomy places
  // it on 21 June 168 BCE (Julian), the night before the battle.
  // https://academic.oup.com/book/27201/chapter-abstract/196653306
  // With the leading March fragment, September occupies numbered slot 6.
  let roman = RomanCalendar.shared.jdn(forYear: 586, month: 6, day: 3)
  let julian = JulianCalendar.toJDN(Y: -167, M: 6, D: 21)

  #expect(roman == julian)
}

@Test("Israel's declaration carries matching Hebrew and Gregorian dates")
func israelDeclarationHebrewConversion() throws {
  // The official record gives 5 Iyar 5708 and 14 May 1948.
  // https://m.knesset.gov.il/en/about/pages/independence.aspx
  let iyar = try #require(JewishCalendar.numberOfMonth(year: 5708, month: "Iyar"))
  let hebrew = JewishCalendar.toJDN(Y: 5708, M: iyar, D: 5)
  let gregorian = GregorianCalendar.toJDN(Y: 1948, M: 5, D: 14)

  #expect(hebrew == gregorian)
}

@Test("The formal Islamic epoch matches its Julian anchor")
func civilIslamicEpochConversion() {
  // Explanatory Supplement to the Astronomical Almanac, section 15.6.3.
  // https://aa.usno.navy.mil/downloads/c15_usb_online.pdf
  let islamic = CivilIslamicCalendar.toJDN(Y: 1, M: 1, D: 1)
  let julian = JulianCalendar.toJDN(Y: 622, M: 7, D: 16)

  #expect(islamic == 1_948_440)
  #expect(islamic == julian)
}

@Test("PERF 558 aligns Coptic, Islamic, and Julian dating")
func perf558CalendarConversion() {
  // PERF 558 is dated 30 Pharmouthi/Paremoude in the first indiction and only
  // to the month Jumada I 22 AH in Arabic; the corresponding Julian date is
  // 25 April 643. The Arabic text supplies no day, so test month containment.
  // https://www.onb.ac.at/museen/papyrusmuseum/programm/dauerausstellung/
  // die-themenbereiche-der-ausstellung/default-5dde8d6f61ec4f920ccf42225842908f
  let coptic = CopticCalendar.toJDN(Y: 359, M: 8, D: 30)
  let julian = JulianCalendar.toJDN(Y: 643, M: 4, D: 25)
  let islamic = CivilIslamicCalendar.toDate(J: julian)

  #expect(coptic == julian)
  #expect(islamic.0 == 22)
  #expect(islamic.1 == 5)
}

@Test("The Coptic Era of the Martyrs epoch matches the Julian date")
func copticEpochConversion() {
  let coptic = CopticCalendar.toJDN(Y: 1, M: 1, D: 1)
  let julian = JulianCalendar.toJDN(Y: 284, M: 8, D: 29)

  #expect(coptic == 1_825_030)
  #expect(coptic == julian)
}

@Test("The Nabonassar Egyptian epoch matches its Julian date")
func egyptianNabonassarEpochConversion() {
  // Ptolemy's era begins at 1 Thoth 1, 26 February 747 BCE.
  // https://www.perseus.tufts.edu/hopper/text?doc=Perseus:text:1999.04.0104:
  // alphabetic+letter=N:entry+group=1:entry=nabonassar-bio-1
  let egyptian = EgyptianCalendar.toJDN(Y: 1, M: 1, D: 1)
  let julian = JulianCalendar.toJDN(Y: -746, M: 2, D: 26)

  #expect(egyptian == 1_448_638)
  #expect(egyptian == julian)
}
