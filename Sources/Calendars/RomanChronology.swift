/// Named Roman year-numbering epochs. These convert labels for the same
/// historical year; they do not change the underlying Roman-calendar date.
public enum RomanAUCSystem: String, Codable, Sendable, CaseIterable {
    /// Foundation in 753 BCE.
    case varronian
    /// Foundation in 752 BCE.
    case cato
    /// Foundation in 750 BCE.
    case polybius

    fileprivate var offsetFromVarronian: Int {
        switch self {
        case .varronian: 0
        case .cato: -1
        case .polybius: -3
        }
    }
}

public enum RomanChronology {
    /// Converts an A.U.C. label between named foundation-era systems.
    public static func convert(
        auc: Int,
        from source: RomanAUCSystem,
        to destination: RomanAUCSystem
    ) -> Int {
        auc - source.offsetFromVarronian + destination.offsetFromVarronian
    }

    /// Converts the Varronian A.U.C. used by the fasti to A.L.C.
    /// A.L.C. 1 is the traditional first year of the Republic, A.U.C. 245.
    public static func alc(fromVarronianAUC auc: Int) -> Int {
        auc - 244
    }

    public static func varronianAUC(fromALC alc: Int) -> Int {
        alc + 244
    }
}
