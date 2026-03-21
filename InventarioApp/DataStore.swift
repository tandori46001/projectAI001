import SwiftUI

class DataStore: ObservableObject {
    // MARK: - Published State
    @Published var catalog: [CatalogProduct] = []
    @Published var tables: [String] = []
    @Published var activeTable: String = ""
    @Published var currentFecha: String = ""
    @Published var entries: [JornadaEntry] = []
    @Published var historial: [Jornada] = []
    @Published var isEditingHistorical = false
    @Published var showBackupReminder = false

    private var sessions: [String: SavedSession] = [:]
    private var saveCount: Int = 0

    // UserDefaults keys
    private let kCatalog   = "inv2_catalog"
    private let kTables    = "inv2_tables"
    private let kActive    = "inv2_active"
    private let kHist      = "inv2_hist"
    private let kSessions  = "inv2_sessions"
    private let kSaveCount = "inv2_save_count"

    var catalogIsEmpty: Bool { catalog.isEmpty }

    var totalImporte: Double {
        entries.reduce(0) { $0 + $1.importe }
    }

    var detalleImporte: [(String, Double)] {
        entries.compactMap { e in
            e.importe > 0 ? (e.nombre, e.importe) : nil
        }
    }

    var discrepancias: [(String, Double)] {
        entries.compactMap { e in
            if let d = e.discrepancia { return (e.nombre, d) }
            return nil
        }
    }

    var filteredHistorial: [Jornada] {
        historial
    }

    // MARK: - Init
    init() {
        loadAll()
    }

    // MARK: - Load All
    func loadAll() {
        catalog = load(kCatalog) ?? []
        tables = load(kTables) ?? []
        if tables.isEmpty { tables = ["Tabla 1"] }

        activeTable = UserDefaults.standard.string(forKey: kActive) ?? tables.first ?? "Tabla 1"
        if !tables.contains(activeTable) { activeTable = tables.first ?? "Tabla 1" }

        historial = load(kHist) ?? []
        sessions = load(kSessions) ?? [:]
        saveCount = UserDefaults.standard.integer(forKey: kSaveCount)

        loadCurrentSession()
    }

    // MARK: - Session Management
    func loadCurrentSession() {
        if let session = sessions[activeTable] {
            currentFecha = session.fecha
            entries = session.filas
        } else {
            currentFecha = Self.todayString()
            entries = catalog.map { p in
                JornadaEntry(nombre: p.nombre, precio: String(p.precio))
            }
        }
    }

    func saveCurrentSession() {
        sessions[activeTable] = SavedSession(fecha: currentFecha, filas: entries)
        save(sessions, kSessions)
    }

    // MARK: - Catalog
    func saveCatalog() {
        save(catalog, kCatalog)
    }

    // MARK: - Table Management
    func switchTable(to name: String) {
        saveCurrentSession()
        activeTable = name
        UserDefaults.standard.set(name, forKey: kActive)
        isEditingHistorical = false
        loadCurrentSession()
    }

    func addTable(name: String) -> Bool {
        let n = name.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty, !tables.contains(n) else { return false }
        saveCurrentSession()
        tables.append(n)
        activeTable = n
        saveTables()
        isEditingHistorical = false
        loadCurrentSession()
        return true
    }

    func renameTable(newName: String) -> Bool {
        let n = newName.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty, n != activeTable, !tables.contains(n) else { return false }

        if let session = sessions[activeTable] {
            sessions[n] = session
            sessions.removeValue(forKey: activeTable)
        }

        historial = historial.map { j in
            if j.tabla == activeTable {
                return Jornada(id: j.id, fecha: j.fecha, tabla: n,
                               totalImporte: j.totalImporte, filas: j.filas)
            }
            return j
        }
        saveHistorial()

        if let idx = tables.firstIndex(of: activeTable) {
            tables[idx] = n
        }
        activeTable = n
        saveTables()
        save(sessions, kSessions)
        return true
    }

    func deleteTable() -> Bool {
        guard tables.count > 1 else { return false }
        sessions.removeValue(forKey: activeTable)
        tables.removeAll { $0 == activeTable }
        activeTable = tables.first ?? "Tabla 1"
        saveTables()
        save(sessions, kSessions)
        isEditingHistorical = false
        loadCurrentSession()
        return true
    }

    private func saveTables() {
        save(tables, kTables)
        UserDefaults.standard.set(activeTable, forKey: kActive)
    }

    // MARK: - Entry Management
    func addEntry(_ entry: JornadaEntry? = nil) {
        entries.append(entry ?? JornadaEntry())
        saveCurrentSession()
    }

    func removeEntry(id: UUID) {
        entries.removeAll { $0.id == id }
        saveCurrentSession()
    }

    func moveEntry(from source: IndexSet, to destination: Int) {
        entries.move(fromOffsets: source, toOffset: destination)
        saveCurrentSession()
    }

    // MARK: - Guardar Día
    func guardarDia() -> String? {
        guard !currentFecha.isEmpty else {
            return "Indica la fecha de la jornada."
        }

        let total = ((totalImporte * 100).rounded() / 100)
        let jornada = Jornada(fecha: currentFecha, tabla: activeTable,
                              totalImporte: total, filas: entries)

        historial.removeAll { $0.fecha == currentFecha && $0.tabla == activeTable }
        historial.insert(jornada, at: 0)
        historial.sort { ($0.fecha, $0.tabla) > ($1.fecha, $1.tabla) }

        saveHistorial()
        isEditingHistorical = false

        saveCount += 1
        UserDefaults.standard.set(saveCount, forKey: kSaveCount)
        if saveCount % 7 == 0 {
            showBackupReminder = true
        }

        return nil
    }

    func saveHistorial() {
        save(historial, kHist)
    }

    // MARK: - History Actions
    func editJornada(_ jornada: Jornada) {
        saveCurrentSession()

        if jornada.tabla != activeTable {
            if !tables.contains(jornada.tabla) {
                tables.append(jornada.tabla)
                saveTables()
            }
            activeTable = jornada.tabla
            UserDefaults.standard.set(activeTable, forKey: kActive)
        }

        currentFecha = jornada.fecha
        entries = jornada.filas
        isEditingHistorical = true
        saveCurrentSession()
    }

    func deleteJornada(_ jornada: Jornada) {
        historial.removeAll { $0.id == jornada.id }
        saveHistorial()
    }

    func cancelarEdicion() {
        isEditingHistorical = false
    }

    // MARK: - Limpiar
    func limpiar() {
        currentFecha = Self.todayString()
        entries = catalog.map { p in
            JornadaEntry(nombre: p.nombre, precio: String(p.precio))
        }
        sessions.removeValue(forKey: activeTable)
        save(sessions, kSessions)
        isEditingHistorical = false
    }

    // MARK: - CSV Generation
    func generateCSV() -> String {
        var csv = "Tabla,Fecha,Producto,Inicial,Venta,Precio,Importe,Final\n"
        for e in entries {
            let imp = String(format: "%.2f", e.importe)
            csv += "\"\(activeTable)\",\(currentFecha),\"\(e.nombre)\",\(e.inicial),\(e.venta),\(e.precio),\(imp),\(e.finalVal)\n"
        }
        let total = String(format: "%.2f", totalImporte)
        csv += "\n,,,,,Total,\(total),\n"
        return csv
    }

    // MARK: - Helpers
    static func todayString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Date())
    }

    static func dateFromString(_ s: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: s) ?? Date()
    }

    static func stringFromDate(_ d: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: d)
    }

    private func load<T: Decodable>(_ key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func save<T: Encodable>(_ value: T, _ key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
