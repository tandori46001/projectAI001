import Foundation
import SwiftData
import SwiftUI

@Observable
final class JornadaViewModel {
    private var modelContext: ModelContext

    var activeJornada: Jornada?
    var activeTable: InventoryTable?
    var tables: [InventoryTable] = []
    var entries: [JornadaEntry] = []

    var selectedDate: Date = Fmt.today()
    var isEditingHistorical = false

    var totalImporte: Double = 0
    var salesDetail: [(name: String, importe: Double)] = []
    var discrepancies: [(name: String, diff: Double)] = []

    // Backup reminder
    var showBackupReminder = false
    private let saveCountKey = "inventario_save_count"

    // Alerts
    var showSavedAlert = false
    var savedAlertMessage = ""

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchTables()
        loadActiveTable()
        loadOrCreateActiveJornada()
    }

    // MARK: - Tables

    func fetchTables() {
        let descriptor = FetchDescriptor<InventoryTable>(sortBy: [SortDescriptor(\.sortOrder)])
        tables = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func loadActiveTable() {
        let savedId = UserDefaults.standard.string(forKey: "activeTableId")
        if let savedId, let uuid = UUID(uuidString: savedId) {
            activeTable = tables.first { $0.id == uuid }
        }
        if activeTable == nil {
            activeTable = tables.first
        }
        if let activeTable {
            UserDefaults.standard.set(activeTable.id.uuidString, forKey: "activeTableId")
        }
    }

    func switchTable(to table: InventoryTable) {
        save()
        activeTable = table
        UserDefaults.standard.set(table.id.uuidString, forKey: "activeTableId")
        isEditingHistorical = false
        loadOrCreateActiveJornada()
    }

    func createTable(name: String) {
        let maxOrder = tables.map(\.sortOrder).max() ?? -1
        let table = InventoryTable(name: name, sortOrder: maxOrder + 1)
        modelContext.insert(table)
        save()
        fetchTables()
        switchTable(to: table)
    }

    func renameTable(_ table: InventoryTable, newName: String) {
        table.name = newName
        save()
        fetchTables()
    }

    func deleteTable(_ table: InventoryTable) {
        guard tables.count > 1 else { return }
        let wasActive = table.id == activeTable?.id
        modelContext.delete(table)
        save()
        fetchTables()
        if wasActive {
            activeTable = tables.first
            if let activeTable {
                UserDefaults.standard.set(activeTable.id.uuidString, forKey: "activeTableId")
            }
            loadOrCreateActiveJornada()
        }
    }

    // MARK: - Jornada Lifecycle

    func loadOrCreateActiveJornada() {
        guard let table = activeTable else {
            activeJornada = nil
            entries = []
            recalculate()
            return
        }

        // Find existing draft jornada for this table
        let tableId = table.id
        let descriptor = FetchDescriptor<Jornada>(
            predicate: #Predicate { $0.table?.id == tableId && $0.isSaved == false }
        )
        let drafts = (try? modelContext.fetch(descriptor)) ?? []

        if let draft = drafts.first {
            activeJornada = draft
            selectedDate = draft.date
            entries = (draft.entries).sorted { $0.sortOrder < $1.sortOrder }
        } else {
            createNewJornada(for: table)
        }

        recalculate()
    }

    private func createNewJornada(for table: InventoryTable) {
        let date = Fmt.today()
        let dateString = Fmt.todayString()

        let jornada = Jornada(date: date, dateString: dateString, table: table)
        modelContext.insert(jornada)

        // Populate from catalog
        let catalogDescriptor = FetchDescriptor<Product>(sortBy: [SortDescriptor(\.sortOrder)])
        let products = (try? modelContext.fetch(catalogDescriptor)) ?? []

        for product in products {
            let entry = JornadaEntry(
                productName: product.name,
                sortOrder: product.sortOrder,
                price: product.defaultPrice,
                productId: product.id
            )
            entry.jornada = jornada
            modelContext.insert(entry)
        }

        save()

        activeJornada = jornada
        selectedDate = date
        entries = (jornada.entries).sorted { $0.sortOrder < $1.sortOrder }
    }

    // MARK: - Entry Updates

    func updateDate(_ date: Date) {
        selectedDate = Fmt.startOfDay(date)
        activeJornada?.date = selectedDate
        activeJornada?.dateString = Fmt.dateString(from: selectedDate)
        activeJornada?.updatedAt = Date()
        save()
    }

    func updateEntry(_ entry: JornadaEntry) {
        activeJornada?.updatedAt = Date()
        recalculate()
        save()
    }

    func addEntry() {
        guard let jornada = activeJornada else { return }
        let maxOrder = entries.map(\.sortOrder).max() ?? -1
        let entry = JornadaEntry(productName: "", sortOrder: maxOrder + 1, price: 0, productId: nil)
        entry.jornada = jornada
        modelContext.insert(entry)
        save()
        entries = (jornada.entries).sorted { $0.sortOrder < $1.sortOrder }
        recalculate()
    }

    func deleteEntry(_ entry: JornadaEntry) {
        modelContext.delete(entry)
        save()
        if let jornada = activeJornada {
            entries = (jornada.entries).sorted { $0.sortOrder < $1.sortOrder }
        }
        recalculate()
    }

    // MARK: - Calculations

    func recalculate() {
        var total = 0.0
        var detail: [(String, Double)] = []
        var discs: [(String, Double)] = []

        for entry in entries {
            let imp = entry.importe
            total += imp
            if imp > 0 {
                detail.append((entry.productName, imp))
            }
            if let disc = entry.discrepancy {
                discs.append((entry.productName, disc))
            }
        }

        totalImporte = Fmt.round2(total)
        salesDetail = detail
        discrepancies = discs
    }

    // MARK: - Save Day (Guardar día)

    func guardarDia() {
        guard let jornada = activeJornada, let table = activeTable else { return }

        let dateStr = Fmt.dateString(from: selectedDate)
        let tableId = table.id

        // Update jornada fields
        jornada.date = selectedDate
        jornada.dateString = dateStr
        jornada.totalImporte = totalImporte
        jornada.isSaved = true
        jornada.updatedAt = Date()

        // Find and delete existing saved jornada for same date+table (deduplication)
        let descriptor = FetchDescriptor<Jornada>(
            predicate: #Predicate {
                $0.table?.id == tableId && $0.dateString == dateStr && $0.isSaved == true
            }
        )
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        for old in existing {
            if old.id != jornada.id {
                modelContext.delete(old)
            }
        }

        save()

        // Increment save counter for backup reminder
        incrementSaveCount()

        savedAlertMessage = "Jornada del \(dateStr) (\(table.name)) guardada."
        showSavedAlert = true

        isEditingHistorical = false

        // Create a new active jornada
        createNewJornada(for: table)
        recalculate()
    }

    // MARK: - Clear (Limpiar)

    func limpiar() {
        guard let jornada = activeJornada, let table = activeTable else { return }

        // Delete the draft jornada and all its entries
        modelContext.delete(jornada)
        save()

        // Create fresh from catalog
        createNewJornada(for: table)
        recalculate()
        isEditingHistorical = false
    }

    // MARK: - Edit Historical Jornada

    func startEditingHistorical(_ jornada: Jornada) {
        // If jornada belongs to a different table, switch
        if let jornadaTable = jornada.table, jornadaTable.id != activeTable?.id {
            save()
            activeTable = jornadaTable
            UserDefaults.standard.set(jornadaTable.id.uuidString, forKey: "activeTableId")
        }

        // Delete current draft if exists
        if let current = activeJornada, !current.isSaved {
            modelContext.delete(current)
            save()
        }

        // Mark the saved jornada as draft for editing
        jornada.isSaved = false
        save()

        activeJornada = jornada
        selectedDate = jornada.date
        entries = (jornada.entries).sorted { $0.sortOrder < $1.sortOrder }
        isEditingHistorical = true
        recalculate()
    }

    func cancelEditing() {
        guard isEditingHistorical, let jornada = activeJornada else { return }

        // Re-save the jornada (put it back as saved)
        jornada.isSaved = true
        save()

        isEditingHistorical = false

        // Load or create a new active jornada
        loadOrCreateActiveJornada()
    }

    // MARK: - Backup Reminder

    private func incrementSaveCount() {
        var count = UserDefaults.standard.integer(forKey: saveCountKey)
        count += 1
        UserDefaults.standard.set(count, forKey: saveCountKey)
        if count % 7 == 0 {
            showBackupReminder = true
        }
    }

    // MARK: - Helpers

    private func save() {
        try? modelContext.save()
    }
}
