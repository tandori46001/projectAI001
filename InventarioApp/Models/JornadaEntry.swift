import Foundation
import SwiftData

@Model
final class JornadaEntry {
    @Attribute(.unique) var id: UUID
    var productName: String
    var productId: UUID?
    var sortOrder: Int
    var initialStock: Double?
    var sales: Double?
    var price: Double
    var finalStock: Double?

    var jornada: Jornada?

    var importe: Double {
        (sales ?? 0) * price
    }

    var expectedStock: Double? {
        guard let initial = initialStock else { return nil }
        return initial - (sales ?? 0)
    }

    var discrepancy: Double? {
        guard let fin = finalStock, let expected = expectedStock else { return nil }
        let diff = fin - expected
        return abs(diff) < 0.001 ? nil : diff
    }

    init(productName: String, sortOrder: Int, price: Double, productId: UUID?) {
        self.id = UUID()
        self.productName = productName
        self.sortOrder = sortOrder
        self.price = price
        self.productId = productId
    }
}
