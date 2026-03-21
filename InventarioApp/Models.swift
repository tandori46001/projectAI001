import Foundation

struct CatalogProduct: Identifiable, Codable, Equatable {
    var id = UUID()
    var nombre: String
    var precio: Double
}

struct JornadaEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var nombre: String
    var inicial: String
    var venta: String
    var precio: String
    var finalVal: String

    var importe: Double {
        let v = Double(venta) ?? 0
        let p = Double(precio) ?? 0
        return v * p
    }

    var discrepancia: Double? {
        guard !finalVal.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        let i = Double(inicial) ?? 0
        let v = Double(venta) ?? 0
        let f = Double(finalVal) ?? 0
        let diff = f - (i - v)
        return diff != 0 ? diff : nil
    }
}

struct Jornada: Identifiable, Codable, Equatable {
    var id = UUID()
    var fecha: String
    var tabla: String
    var totalImporte: Double
    var filas: [JornadaEntry]
}

struct SavedSession: Codable, Equatable {
    var fecha: String
    var filas: [JornadaEntry]
}
