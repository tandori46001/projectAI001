import Foundation
import SwiftData

@Model
final class InventoryTable {
    @Attribute(.unique) var id: UUID
    var name: String
    var sortOrder: Int
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Jornada.table)
    var jornadas: [Jornada] = []

    init(name: String, sortOrder: Int) {
        self.id = UUID()
        self.name = name
        self.sortOrder = sortOrder
        self.createdAt = Date()
    }
}
