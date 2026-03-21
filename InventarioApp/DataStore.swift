import Foundation
import Observation

@Observable
class DataStore {
    // MARK: - Keys
    private let kCatalog = "inv2_catalog"
    private let kTables = "inv2_tables"
    private let kActive = "inv2_active"
    private let kHist = "inv2_hist"
    private let kSessions = "inv2_sessions"
    private let kSaveCount = "inv2_save_count"

    // MARK: - State
    var catalog: [CatalogProduct] = []
    var tables: [String] = []
    var activeTable: String = ""
    var historial: [Jornada] = []
    var sessions: [String: SavedSession] = [:]
    var saveCount: Int = 0

    // Current session
    var entries: [JornadaEntry] = []
    var currentFecha: Date = Date()

    // Editing state
    var isEditingHistorical: Bool = false
    var editingJornadaId: UUID? = nil

    init() {
        loadAll()
    }

    // MARK: - Date formatting
    var fechaString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: currentFecha)
    }

    // MARK: - Load
    func loadAll() {
        let ud = UserDefaults.standard
        if let data = ud.data(forKey: kCatalog),
           let decoded = try? JSONDecoder().decode([CatalogProduct].self, from: data) {
            catalog = decoded
        }
        if let data = ud.data(forKey: kTables),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            tables = decoded
        }
        activeTable = ud.string(forKey: kActive) ?? ""
        if let data = ud.data(forKey: kHist),
           let decoded = try? JSONDecoder().decode([Jornada].self, from: data) {
            historial = decoded
        }
        if let data = ud.data(forKey: kSessions),
           let decoded = try? JSONDecoder().decode([String: SavedSession].self, from: data) {
            sessions = decoded
        }
        saveCount = ud.integer(forKey: kSaveCount)

        // Load current session for active table
        if !activeTable.isEmpty {
            loadSession(for: activeTable)
        }
    }

    // MARK: - Save helpers
    func saveCatalog() {
        if let data = try? JSONEncoder().encode(catalog) {
            UserDefaults.standard.set(data, forKey: kCatalog)
        }
    }

    func saveTables() {
        if let data = try? JSONEncoder().encode(tables) {
            UserDefaults.standard.set(data, forKey: kTables)
        }
        UserDefaults.standard.set(activeTable, forKey: kActive)
    }

    func saveHistorial() {
        if let data = try? JSONEncoder().encode(historial) {
            UserDefaults.standard.set(data, forKey: kHist)
        }
    }

    func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: kSessions)
        }
    }

    func saveSaveCount() {
        UserDefaults.standard.set(saveCount, forKey: kSaveCount)
    }

    // MARK: - Session management
    func saveCurrentSession() {
        guard !activeTable.isEmpty else { return }
        let session = SavedSession(fecha: fechaString, filas: entries)
        sessions[activeTable] = session
        saveSessions()
    }

    func loadSession(for table: String) {
        if let session = sessions[table] {
            entries = session.filas
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            if let date = f.date(from: session.fecha) {
                currentFecha = date
            } else {
                currentFecha = Date()
            }
        } else {
            resetEntries()
        }
    }

    func resetEntries() {
        currentFecha = Date()
        entries = catalog.map { product in
            JornadaEntry(
                nombre: product.nombre,
                inicial: "",
                venta: "",
                precio: String(product.precio),
                finalVal: ""
            )
        }
        saveCurrentSession()
    }

    // MARK: - Table management
    func switchTable(to table: String) {
        saveCurrentSession()
        activeTable = table
        UserDefaults.standard.set(activeTable, forKey: kActive)
        loadSession(for: table)
    }

    func addTable(name: String) {
        guard !name.isEmpty, !tables.contains(name) else { return }
        tables.append(name)
        saveTables()
        switchTable(to: name)
    }

    func renameTable(from oldName: String, to newName: String) {
        guard !newName.isEmpty, !tables.contains(newName) else { return }
        if let idx = tables.firstIndex(of: oldName) {
            tables[idx] = newName
        }
        if let session = sessions[oldName] {
            sessions[newName] = session
            sessions.removeValue(forKey: oldName)
        }
        // Update historial
        for i in historial.indices where historial[i].tabla == oldName {
            historial[i].tabla = newName
        }
        if activeTable == oldName {
            activeTable = newName
        }
        saveTables()
        saveSessions()
        saveHistorial()
    }

    func deleteTable(_ name: String) {
        guard tables.count > 1 else { return }
        tables.removeAll { $0 == name }
        sessions.removeValue(forKey: name)
        if activeTable == name {
            activeTable = tables.first ?? ""
            loadSession(for: activeTable)
        }
        saveTables()
        saveSessions()
    }

    // MARK: - Jornada (save day)
    func guardarJornada() -> Bool {
        let total = entries.reduce(0.0) { $0 + $1.importe }
        let jornada = Jornada(
            fecha: fechaString,
            tabla: activeTable,
            totalImporte: total,
            filas: entries
        )

        // Replace if same date + table exists
        if let idx = historial.firstIndex(where: { $0.fecha == fechaString && $0.tabla == activeTable }) {
            historial[idx] = jornada
        } else if let editId = editingJornadaId,
                  let idx = historial.firstIndex(where: { $0.id == editId }) {
            historial[idx] = jornada
        } else {
            historial.append(jornada)
        }

        saveHistorial()
        isEditingHistorical = false
        editingJornadaId = nil

        saveCount += 1
        saveSaveCount()

        return saveCount % 7 == 0
    }

    func deleteJornada(_ jornada: Jornada) {
        historial.removeAll { $0.id == jornada.id }
        saveHistorial()
    }

    func editJornada(_ jornada: Jornada) {
        // Switch to the jornada's table
        if activeTable != jornada.tabla {
            saveCurrentSession()
            if !tables.contains(jornada.tabla) {
                tables.append(jornada.tabla)
                saveTables()
            }
            activeTable = jornada.tabla
            UserDefaults.standard.set(activeTable, forKey: kActive)
        }
        entries = jornada.filas
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        if let date = f.date(from: jornada.fecha) {
            currentFecha = date
        }
        isEditingHistorical = true
        editingJornadaId = jornada.id
        saveCurrentSession()
    }

    func cancelEditing() {
        isEditingHistorical = false
        editingJornadaId = nil
        loadSession(for: activeTable)
    }

    // MARK: - Wizard complete
    func completeWizard(products: [CatalogProduct]) {
        catalog = products
        saveCatalog()
        if tables.isEmpty {
            tables = ["Principal"]
            activeTable = "Principal"
            saveTables()
        }
        resetEntries()
    }

    // MARK: - Computed
    var totalImporte: Double {
        entries.reduce(0.0) { $0 + $1.importe }
    }

    var entriesConVenta: [JornadaEntry] {
        entries.filter { (Double($0.venta) ?? 0) > 0 }
    }

    var entriesConDiscrepancia: [JornadaEntry] {
        entries.filter { $0.discrepancia != nil }
    }

    // MARK: - CSV
    func generateCSV() -> String {
        var csv = "Tabla,Fecha,Producto,Inicial,Venta,Precio,Importe,Final\n"
        for entry in entries {
            let line = "\(activeTable),\(fechaString),\(entry.nombre),\(entry.inicial),\(entry.venta),\(entry.precio),\(String(format: "%.2f", entry.importe)),\(entry.finalVal)"
            csv += line + "\n"
        }
        return csv
    }

    // MARK: - PDF HTML
    func generatePDFHTML() -> String {
        var html = """
        <html><head><meta charset="utf-8">
        <style>
        body { font-family: -apple-system, Helvetica; margin: 20px; }
        h1 { font-size: 18px; }
        h2 { font-size: 14px; color: #666; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 12px; }
        th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; }
        th { background: #f0f0f0; }
        .right { text-align: right; }
        .red { color: red; font-weight: bold; }
        .total { font-weight: bold; background: #e8f5e9; }
        </style></head><body>
        <h1>Inventario - \(activeTable)</h1>
        <h2>Fecha: \(fechaString)</h2>
        <table>
        <tr><th>Producto</th><th class="right">Inicial</th><th class="right">Venta</th><th class="right">Precio</th><th class="right">Importe</th><th class="right">Final</th><th>Discrepancia</th></tr>
        """
        for entry in entries {
            let disc = entry.discrepancia
            let discStr = disc.map { String(format: "%.2f", $0) } ?? ""
            let discClass = disc != nil ? "red" : ""
            html += """
            <tr>
            <td>\(entry.nombre)</td>
            <td class="right">\(entry.inicial)</td>
            <td class="right">\(entry.venta)</td>
            <td class="right">\(entry.precio)</td>
            <td class="right">\(String(format: "%.2f", entry.importe))</td>
            <td class="right">\(entry.finalVal)</td>
            <td class="right \(discClass)">\(discStr)</td>
            </tr>
            """
        }
        html += """
        <tr class="total">
        <td colspan="4">TOTAL</td>
        <td class="right">\(String(format: "%.2f", totalImporte))</td>
        <td colspan="2"></td>
        </tr>
        </table>
        </body></html>
        """
        return html
    }
}
