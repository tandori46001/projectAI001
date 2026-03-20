import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@Observable
final class CatalogViewModel {
    private var modelContext: ModelContext

    var products: [Product] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchProducts()
    }

    var isEmpty: Bool { products.isEmpty }

    func fetchProducts() {
        let descriptor = FetchDescriptor<Product>(sortBy: [SortDescriptor(\.sortOrder)])
        products = (try? modelContext.fetch(descriptor)) ?? []
    }

    func addProduct(name: String = "", price: Double = 0) {
        let maxOrder = products.map(\.sortOrder).max() ?? -1
        let product = Product(name: name, defaultPrice: price, sortOrder: maxOrder + 1)
        modelContext.insert(product)
        save()
        fetchProducts()
    }

    func deleteProduct(_ product: Product) {
        modelContext.delete(product)
        save()
        fetchProducts()
    }

    func updateProduct(_ product: Product, name: String, price: Double) {
        product.name = name
        product.defaultPrice = price
        save()
        fetchProducts()
    }

    func moveUp(_ product: Product) {
        guard let index = products.firstIndex(where: { $0.id == product.id }), index > 0 else { return }
        let neighbor = products[index - 1]
        let tmp = product.sortOrder
        product.sortOrder = neighbor.sortOrder
        neighbor.sortOrder = tmp
        save()
        fetchProducts()
    }

    func moveDown(_ product: Product) {
        guard let index = products.firstIndex(where: { $0.id == product.id }),
              index < products.count - 1 else { return }
        let neighbor = products[index + 1]
        let tmp = product.sortOrder
        product.sortOrder = neighbor.sortOrder
        neighbor.sortOrder = tmp
        save()
        fetchProducts()
    }

    func sortAlphabetically() {
        let sorted = products.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        for (i, p) in sorted.enumerated() {
            p.sortOrder = i
        }
        save()
        fetchProducts()
    }

    // MARK: - JSON Export/Import

    struct CatalogEntry: Codable {
        let nombre: String
        let precio: Double
    }

    func exportJSON() -> Data? {
        let entries = products.map { CatalogEntry(nombre: $0.name, precio: $0.defaultPrice) }
        return try? JSONEncoder().encode(entries)
    }

    func importJSON(data: Data) throws {
        let entries = try JSONDecoder().decode([CatalogEntry].self, from: data)
        guard !entries.isEmpty else {
            throw NSError(domain: "CatalogImport", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "El archivo no contiene productos."])
        }

        // Delete all existing products
        for product in products {
            modelContext.delete(product)
        }

        // Insert imported products
        for (i, entry) in entries.enumerated() {
            let product = Product(name: entry.nombre, defaultPrice: entry.precio, sortOrder: i)
            modelContext.insert(product)
        }

        save()
        fetchProducts()
    }

    func exportJSONFileURL() -> URL? {
        guard let data = exportJSON() else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("catalogo.json")
        try? data.write(to: url)
        return url
    }

    // MARK: - Helpers

    private func save() {
        try? modelContext.save()
    }
}
