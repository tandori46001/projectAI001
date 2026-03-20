import Foundation
import SwiftData

@Model
final class Jornada {
    @Attribute(.unique) var id: UUID
    var date: Date
    var dateString: String
    var isSaved: Bool
    var totalImporte: Double
    var createdAt: Date
    var updatedAt: Date

    var table: InventoryTable?

    @Relationship(deleteRule: .cascade, inverse: \JornadaEntry.jornada)
    var entries: [JornadaEntry] = []

    init(date: Date, dateString: String, table: InventoryTable) {
        self.id = UUID()
        self.date = date
        self.dateString = dateString
        self.isSaved = false
        self.totalImporte = 0
        self.createdAt = Date()
        self.updatedAt = Date()
        self.table = table
    }
}
