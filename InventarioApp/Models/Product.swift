import Foundation
import SwiftData

@Model
final class Product {
    @Attribute(.unique) var id: UUID
    var name: String
    var defaultPrice: Double
    var sortOrder: Int
    var createdAt: Date

    init(name: String, defaultPrice: Double, sortOrder: Int) {
        self.id = UUID()
        self.name = name
        self.defaultPrice = defaultPrice
        self.sortOrder = sortOrder
        self.createdAt = Date()
    }
}
