import SwiftUI

struct MainView: View {
    @EnvironmentObject var store: DataStore

    // Sheet states
    @State private var showCatalog = false
    @State private var showHistory = false

    // Alert states
    @State private var showNewTable = false
    @State private var showRenameTable = false
    @State private var showDeleteTableConfirm = false
    @State private var showLimpiarConfirm = false
    @State private var showSavedAlert = false
    @State private var savedMessage = ""
    @State private var alertInput = ""

    // Export
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // ── 1. TABLE SELECTOR ──
                    tableSelectorSection

                    // ── 2. EDIT BANNER ──
                    if store.isEditingHistorical {
                        editBanner
                    }

                    // ── 3. DATE ──
                    dateSection

                    Divider()

                    // ── 4. INVENTORY ENTRIES ──
                    entriesSection

                    // ── 5. ADD PRODUCT ──
                    Button {
                        store.addEntry()
                    } label: {
                        Label("Agregar producto", systemImage: "plus")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)

                    Divider()

                    // ── 6. SUMMARY ──
                    summarySection

                    Divider()

                    // ── 7. ACTION BUTTONS ──
                    actionsSection

                    Divider()

                    // ── 8. HISTORY ──
                    historySection
                }
                .padding()
            }
            .navigationTitle("Inventario")
            .sheet(isPresented: $showCatalog) {
                CatalogSheet()
            }
            .sheet(isPresented: $showHistory) {
                HistorySheet()
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: shareItems)
            }
            .alert("Nueva tabla", isPresented: $showNewTable) {
                TextField("Nombre", text: $alertInput)
                Button("Crear") {
                    _ = store.addTable(name: alertInput)
                    alertInput = ""
                }
                Button("Cancelar", role: .cancel) { alertInput = "" }
            }
            .alert("Renombrar tabla", isPresented: $showRenameTable) {
                TextField("Nuevo nombre", text: $alertInput)
                Button("Renombrar") {
                    _ = store.renameTable(newName: alertInput)
                    alertInput = ""
                }
                Button("Cancelar", role: .cancel) { alertInput = "" }
            }
            .alert("¿Eliminar tabla?", isPresented: $showDeleteTableConfirm) {
                Button("Eliminar", role: .destructive) {
                    _ = store.deleteTable()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Se eliminará \"\(store.activeTable)\" y sus datos actuales. El historial guardado se conserva.")
            }
            .alert("¿Limpiar?", isPresented: $showLimpiarConfirm) {
                Button("Limpiar", role: .destructive) {
                    store.limpiar()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Se restablecerán los datos de la jornada actual con los productos del catálogo.")
            }
            .alert("Guardado", isPresented: $showSavedAlert) {
                Button("OK") {}
            } message: {
                Text(savedMessage)
            }
            .alert("Exportar CSV", isPresented: $showBackupBinding) {
                Button("Exportar CSV") { exportCSV() }
                Button("Entendido", role: .cancel) {}
            } message: {
                Text("Recordatorio: exporta tu historial periódicamente para no perder datos.")
            }
            .onChange(of: store.entries) { _, _ in
                store.saveCurrentSession()
            }
            .onChange(of: store.currentFecha) { _, _ in
                store.saveCurrentSession()
            }
        }
    }

    private var showBackupBinding: Binding<Bool> {
        $store.showBackupReminder
    }

    // MARK: - Table Selector
    private var tableSelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Tabla:")
                    .font(.subheadline.bold())

                Picker("Tabla", selection: Binding(
                    get: { store.activeTable },
                    set: { store.switchTable(to: $0) }
                )) {
                    ForEach(store.tables, id: \.self) { t in
                        Text(t).tag(t)
                    }
                }
                .pickerStyle(.menu)

                Spacer()
            }

            HStack(spacing: 8) {
                Button("+ Nueva") {
                    alertInput = ""
                    showNewTable = true
                }
                .font(.caption)
                .buttonStyle(.bordered)

                Button("Renombrar") {
                    alertInput = store.activeTable
                    showRenameTable = true
                }
                .font(.caption)
                .buttonStyle(.bordered)

                Button("Eliminar") {
                    showDeleteTableConfirm = true
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(store.tables.count <= 1)
            }
        }
    }

    // MARK: - Edit Banner
    private var editBanner: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text("Editando jornada histórica")
                .font(.caption)
            Spacer()
            Button("Cancelar") {
                store.cancelarEdicion()
                store.loadCurrentSession()
            }
            .font(.caption)
            .buttonStyle(.bordered)
        }
        .padding(10)
        .background(Color.yellow.opacity(0.15))
        .cornerRadius(8)
    }

    // MARK: - Date
    private var dateSection: some View {
        DatePicker(
            "Fecha:",
            selection: fechaBinding,
            displayedComponents: .date
        )
        .datePickerStyle(.compact)
        .font(.subheadline.bold())
    }

    private var fechaBinding: Binding<Date> {
        Binding(
            get: { DataStore.dateFromString(store.currentFecha) },
            set: { store.currentFecha = DataStore.stringFromDate($0) }
        )
    }

    // MARK: - Entries
    private var entriesSection: some View {
        VStack(spacing: 12) {
            if store.entries.isEmpty {
                Text("No hay productos. Agrega uno o configura el catálogo.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach($store.entries) { $entry in
                    EntryCard(entry: $entry) {
                        store.removeEntry(id: entry.id)
                    }
                }
            }
        }
    }

    // MARK: - Summary
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Total Importe:")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f", store.totalImporte))
                    .font(.headline.monospacedDigit())
            }

            if !store.detalleImporte.isEmpty {
                DisclosureGroup("Detalle Importe") {
                    ForEach(store.detalleImporte, id: \.0) { nombre, importe in
                        HStack {
                            Text(nombre)
                                .font(.caption)
                            Spacer()
                            Text(String(format: "%.2f", importe))
                                .font(.caption.monospacedDigit())
                        }
                    }
                }
                .font(.subheadline)
            }

            if !store.discrepancias.isEmpty {
                DisclosureGroup("Discrepancias") {
                    ForEach(store.discrepancias, id: \.0) { nombre, diff in
                        HStack {
                            Text("Atención: \(diff > 0 ? "+" : "")\(String(format: "%.2f", diff)) \(nombre)")
                                .font(.caption)
                                .foregroundStyle(.red)
                            Spacer()
                        }
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Actions
    private var actionsSection: some View {
        VStack(spacing: 10) {
            // Primary action
            Button {
                guardarDia()
            } label: {
                Label("Guardar día", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            // Secondary actions grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 8) {
                Button { exportCSV() } label: {
                    Label("CSV", systemImage: "doc.text")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button { exportPDF() } label: {
                    Label("PDF", systemImage: "doc.richtext")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button { showCatalog = true } label: {
                    Label("Catálogo", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button { showHistory = true } label: {
                    Label("Historial", systemImage: "clock")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Button {
                showLimpiarConfirm = true
            } label: {
                Label("Limpiar", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
    }

    // MARK: - History (inline preview)
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Historial de jornadas")
                    .font(.headline)
                Spacer()
                Button("Ver todo") { showHistory = true }
                    .font(.caption)
            }

            if store.historial.isEmpty {
                Text("Sin jornadas registradas.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.historial.prefix(5)) { jornada in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(jornada.fecha)
                                .font(.subheadline.bold())
                            Text(jornada.tabla)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(String(format: "%.2f", jornada.totalImporte))
                            .font(.subheadline.monospacedDigit())
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Actions
    private func guardarDia() {
        if let error = store.guardarDia() {
            savedMessage = error
        } else {
            savedMessage = "Jornada del \(store.currentFecha) (\(store.activeTable)) guardada."
        }
        showSavedAlert = true
    }

    private func exportCSV() {
        let csv = store.generateCSV()
        let filename = "inventario_\(store.activeTable)_\(store.currentFecha).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        shareItems = [url]
        showShareSheet = true
    }

    private func exportPDF() {
        if let url = Exporters.generatePDF(store: store) {
            shareItems = [url]
            showShareSheet = true
        }
    }
}

// MARK: - Entry Card
struct EntryCard: View {
    @Binding var entry: JornadaEntry
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: product name + delete
            HStack {
                if entry.nombre.isEmpty {
                    TextField("Producto", text: $entry.nombre)
                        .font(.subheadline.bold())
                } else {
                    Text(entry.nombre)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                }
                Spacer()
                Button(role: .destructive) { onDelete() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red.opacity(0.7))
                }
                .buttonStyle(.plain)
            }

            // Fields row 1: Inicial, Venta, Final
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Inicial").font(.caption2).foregroundStyle(.secondary)
                    TextField("0", text: $entry.inicial)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline.monospacedDigit())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Venta").font(.caption2).foregroundStyle(.secondary)
                    TextField("0", text: $entry.venta)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline.monospacedDigit())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Final").font(.caption2).foregroundStyle(.secondary)
                    TextField("—", text: $entry.finalVal)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline.monospacedDigit())
                }
            }

            // Fields row 2: Precio, Importe
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Precio").font(.caption2).foregroundStyle(.secondary)
                    TextField("0", text: $entry.precio)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline.monospacedDigit())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Importe").font(.caption2).foregroundStyle(.secondary)
                    Text(entry.importe > 0 ? String(format: "%.2f", entry.importe) : "—")
                        .font(.subheadline.bold().monospacedDigit())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                }

                // Discrepancy indicator
                if let disc = entry.discrepancia {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Discr.").font(.caption2).foregroundStyle(.red)
                        Text("\(disc > 0 ? "+" : "")\(String(format: "%.2f", disc))")
                            .font(.subheadline.bold().monospacedDigit())
                            .foregroundStyle(.red)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Share Sheet (UIKit wrapper)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
