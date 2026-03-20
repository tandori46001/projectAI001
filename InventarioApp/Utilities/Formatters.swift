import Foundation

enum Fmt {
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "es_MX")
        return f
    }()

    private static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale(identifier: "es_MX")
        return f
    }()

    static func dateString(from date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func date(from string: String) -> Date? {
        dateFormatter.date(from: string)
    }

    static func displayDate(_ date: Date) -> String {
        displayDateFormatter.string(from: date)
    }

    static func currency(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    static func round2(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }

    static func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    static func today() -> Date {
        startOfDay(Date())
    }

    static func todayString() -> String {
        dateString(from: Date())
    }
}
