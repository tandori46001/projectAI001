import SwiftUI

struct MainView: View {
    @Environment(DataStore.self) private var store

    @State private var showCatalog = false
    @State private var showHistorial = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var showSaveAlert = false
    @State private var showBackupReminder = false
    @State private var showClearAlert = false
    @State private var showNewTableAlert = false
    @State private var showRenameTableAlert = false
    @State private var showDeleteTableAlert = false
    @State private var newTableName = ""
    @State private var renameTableName = ""
    @State private var showImporteDetail = false
    @State private var showDiscrepanciaDetail = false

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // a) Table selector
                    tableSelector

                    // b) Historical editing banner
                    if store.isEditingHistorical {
                        editBanner
                    }

                    // c) Date picker
                    datePicker

                    // d) Product cards
                    entriesSection

                    // e) Add product button
                    addProductButton

                    Divider().padding(.horizontal)

                    // f) Summary
                    summarySection

                    Divider().padding(.horizontal)

                    // g) Action buttons
                    actionButtons

                    Divider().padding(.horizontal)

                    // h) History preview
                    historyPreview
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Inventario")
            .onChange(of: store.entries) { _, _ in
                store.saveCurrentSession()
            }
            .onChange(of: store.currentFecha) { _, _ in
                store.saveCurrentSession()
            }
        }
        .sheet(isPresented: $showCatalog) {
            CatalogView()
        }
        .sheet(isPresented: $showHistorial) {
            HistorialView()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
        .alert("Guardar jornada", isPresented: $showSaveAlert) {
            Button("Guardar", role: .destructive) {
                let needsBackup = store.guardarJornada()
                if needsBackup {
                    showBackupReminder = true
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Se guardará la jornada del \(store.fechaString) en la tabla \"\(store.activeTable)\". Si ya existe una jornada con la misma fecha y tabla, se reemplazará.")
        }
        .alert("Recordatorio de backup", isPresented: $showBackupReminder) {
            Button("Exportar CSV") { exportCSV() }
            Button("Más tarde", role: .cancel) {}
        } message: {
            Text("Llevas varios guardados. Te recomendamos exportar un CSV como respaldo.")
        }
        .alert("Limpiar sesión", isPresented: $showClearAlert) {
            Button("Limpiar", role: .destructive) {
                store.resetEntries()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Se restablecerán todos los campos con los productos del catálogo y valores vacíos.")
        }
        .alert("Nueva tabla", isPresented: $showNewTableAlert) {
            TextField("Nombre", text: $newTableName)
            Button("Crear") {
                store.addTable(name: newTableName.trimmingCharacters(in: .whitespaces))
                newTableName = ""
            }
            Button("Cancelar", role: .cancel) { newTableName = "" }
        }
        .alert("Renombrar tabla", isPresented: $showRenameTableAlert) {
            TextField("Nuevo nombre", text: $renameTableName)
            Button("Renombrar") {
                store.renameTable(from: store.activeTable, to: renameTableName.trimmingCharacters(in: .whitespaces))
                renameTableName = ""
            }
            Button("Cancelar", role: .cancel) { renameTableName = "" }
        }
        .alert("Eliminar tabla", isPresented: $showDeleteTableAlert) {
            Button("Eliminar", role: .destructive) {
                store.deleteTable(store.activeTable)
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Se eliminará la tabla \"\(store.activeTable)\" y su sesión actual. Las jornadas del historial no se eliminarán.")
        }
    }

    // MARK: - Table Selector
    private var tableSelector: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Tabla:")
                    .font(.headline)
                Picker("Tabla", selection: Binding(
                    get: { store.activeTable },
                    set: { store.switchTable(to: $0) }
                )) {
                    ForEach(store.tables, id: \.self) { table in
                        Text(table).tag(table)
                    }
                }
                .pickerStyle(.menu)
                Spacer()
            }
            HStack(spacing: 8) {
                Button {
                    showNewTableAlert = true
                } label: {
                    Label("Nueva", systemImage: "plus")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button {
                    renameTableName = store.activeTable
                    showRenameTableAlert = true
                } label: {
                    Label("Renombrar", systemImage: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button {
                    showDeleteTableAlert = true
                } label: {
                    Label("Eliminar", systemImage: "trash")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(store.tables.count <= 1)

                Spacer()
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Edit Banner
    private var editBanner: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text("Editando jornada del historial")
                .font(.subheadline.bold())
            Spacer()
            Button("Cancelar") {
                store.cancelEditing()
            }
            .font(.subheadline)
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }

    // MARK: - Date Picker
    private var datePicker: some View {
        @Bindable var store = store
        return DatePicker("Fecha", selection: $store.currentFecha, displayedComponents: .date)
            .datePickerStyle(.compact)
            .padding(.horizontal)
    }

    // MARK: - Entries
    private var entriesSection: some View {
        @Bindable var store = store
        return LazyVStack(spacing: 12) {
            ForEach($store.entries) { $entry in
                EntryCard(entry: $entry) {
                    if let idx = store.entries.firstIndex(where: { $0.id == entry.id }) {
                        store.entries.remove(at: idx)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Add Product
    private var addProductButton: some View {
        Button {
            store.entries.append(JornadaEntry(
                nombre: "",
                inicial: "",
                venta: "",
                precio: "",
                finalVal: ""
            ))
        } label: {
            Label("Agregar producto", systemImage: "plus.circle")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .padding(.horizontal)
    }

    // MARK: - Summary
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Total Importe:")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f €", store.totalImporte))
                    .font(.title2.bold())
                    .foregroundStyle(.green)
            }

            // Detalle importe
            DisclosureGroup("Detalle Importe (\(store.entriesConVenta.count))", isExpanded: $showImporteDetail) {
                ForEach(store.entriesConVenta) { entry in
                    HStack {
                        Text(entry.nombre)
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "%.2f €", entry.importe))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Discrepancias
            if !store.entriesConDiscrepancia.isEmpty {
                DisclosureGroup(isExpanded: $showDiscrepanciaDetail) {
                    ForEach(store.entriesConDiscrepancia) { entry in
                        HStack {
                            Text(entry.nombre)
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "%+.2f", entry.discrepancia ?? 0))
                                .font(.subheadline.bold())
                                .foregroundStyle(.red)
                        }
                    }
                } label: {
                    Text("Discrepancias (\(store.entriesConDiscrepancia.count))")
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                showSaveAlert = true
            } label: {
                Label("Guardar día", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            HStack(spacing: 10) {
                Button {
                    exportCSV()
                } label: {
                    Label("CSV", systemImage: "doc.text")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    exportPDF()
                } label: {
                    Label("PDF", systemImage: "doc.richtext")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 10) {
                Button {
                    showCatalog = true
                } label: {
                    Label("Catálogo", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    showHistorial = true
                } label: {
                    Label("Historial", systemImage: "clock")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Button(role: .destructive) {
                showClearAlert = true
            } label: {
                Label("Limpiar", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
    }

    // MARK: - History Preview
    private var historyPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Últimas jornadas")
                .font(.headline)
                .padding(.horizontal)

            let recent = store.historial.sorted { $0.fecha > $1.fecha }.prefix(5)
            if recent.isEmpty {
                Text("Sin jornadas guardadas")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(Array(recent)) { jornada in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(jornada.fecha)
                                .font(.subheadline.bold())
                            Text(jornada.tabla)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(String(format: "%.2f €", jornada.totalImporte))
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                }

                if store.historial.count > 5 {
                    Button("Ver todo") {
                        showHistorial = true
                    }
                    .font(.subheadline)
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Export
    private func exportCSV() {
        let csv = store.generateCSV()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("inventario_\(store.fechaString).csv")
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        shareItems = [url]
        showShareSheet = true
    }

    private func exportPDF() {
        let html = store.generatePDFHTML()
        generatePDFFromHTML(html) { url in
            if let url {
                shareItems = [url]
                showShareSheet = true
            }
        }
    }
}

// MARK: - Entry Card
struct EntryCard: View {
    @Binding var entry: JornadaEntry
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if entry.nombre.isEmpty {
                    TextField("Nombre producto", text: $entry.nombre)
                        .font(.headline)
                } else {
                    Text(entry.nombre)
                        .font(.headline)
                }
                Spacer()
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red.opacity(0.7))
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Inicial").font(.caption2).foregroundStyle(.secondary)
                    TextField("0", text: $entry.inicial)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Venta").font(.caption2).foregroundStyle(.secondary)
                    TextField("0", text: $entry.venta)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Final").font(.caption2).foregroundStyle(.secondary)
                    TextField("—", text: $entry.finalVal)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Precio").font(.caption2).foregroundStyle(.secondary)
                    TextField("0.00", text: $entry.precio)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Importe").font(.caption2).foregroundStyle(.secondary)
                    Text(String(format: "%.2f €", entry.importe))
                        .font(.body.bold())
                        .foregroundStyle(.green)
                }
                if let disc = entry.discrepancia {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Discrepancia").font(.caption2).foregroundStyle(.red)
                        Text(String(format: "%+.2f", disc))
                            .font(.body.bold())
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
