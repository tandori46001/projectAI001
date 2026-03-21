import Foundation

// MARK: - Catalog Product
struct CatalogProduct: Codable, Identifiable, Equatable {
    var id = UUID()
    var nombre: String
    var precio: Double

    init(id: UUID = UUID(), nombre: String = "", precio: Double = 0) {
        self.id = id
        self.nombre = nombre
        self.precio = precio
    }
}

// MARK: - Jornada Entry (one row in the daily inventory)
struct JornadaEntry: Codable, Identifiable, Equatable {
    var id = UUID()
    var nombre: String
    var inicial: String
    var venta: String
    var precio: String
    var finalVal: String

    init(id: UUID = UUID(), nombre: String = "", inicial: String = "",
         venta: String = "", precio: String = "0", finalVal: String = "") {
        self.id = id
        self.nombre = nombre
        self.inicial = inicial
        self.venta = venta
        self.precio = precio
        self.finalVal = finalVal
    }

    var importe: Double {
        (Double(venta) ?? 0) * (Double(precio) ?? 0)
    }

    var discrepancia: Double? {
        let f = finalVal.trimmingCharacters(in: .whitespaces)
        guard !f.isEmpty, let finalNum = Double(f) else { return nil }
        let i = Double(inicial) ?? 0
        let v = Double(venta) ?? 0
        let diff = ((finalNum - (i - v)) * 100).rounded() / 100
        return diff != 0 ? diff : nil
    }

    enum CodingKeys: String, CodingKey {
        case id, nombre, inicial, venta, precio
        case finalVal = "final"
    }
}

// MARK: - Saved Jornada (history entry)
struct Jornada: Codable, Identifiable, Equatable {
    var id = UUID()
    var fecha: String
    var tabla: String
    var totalImporte: Double
    var filas: [JornadaEntry]
}

// MARK: - Current Session (auto-saved per table)
struct SavedSession: Codable {
    var fecha: String
    var filas: [JornadaEntry]
}
