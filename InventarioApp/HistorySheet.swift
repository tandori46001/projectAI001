import SwiftUI

struct HistorySheet: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedJornada: Jornada?
    @State private var showDetail = false
    @State private var jornadaToDelete: Jornada?
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if store.historial.isEmpty {
                    ContentUnavailableView(
                        "Sin jornadas",
                        systemImage: "clock",
                        description: Text("Las jornadas guardadas aparecerán aquí.")
                    )
                } else {
                    List {
                        ForEach(store.historial) { jornada in
                            Button {
                                selectedJornada = jornada
                                showDetail = true
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(jornada.fecha)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.primary)
                                        Text(jornada.tabla)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("Total: \(String(format: "%.2f", jornada.totalImporte))")
                                        .font(.subheadline.monospacedDigit())
                                        .foregroundStyle(.primary)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    jornadaToDelete = jornada
                                    showDeleteConfirm = true
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .sheet(isPresented: $showDetail) {
                if let jornada = selectedJornada {
                    HistoryDetailView(jornada: jornada)
                }
            }
            .alert("¿Eliminar jornada?", isPresented: $showDeleteConfirm) {
                Button("Eliminar", role: .destructive) {
                    if let j = jornadaToDelete {
                        store.deleteJornada(j)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                if let j = jornadaToDelete {
                    Text("Se eliminará la jornada del \(j.fecha) (\(j.tabla)) del historial.")
                }
            }
        }
    }
}

// MARK: - History Detail View
struct HistoryDetailView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss
    let jornada: Jornada

    // To dismiss both this sheet and the parent HistorySheet
    @State private var shouldDismissAll = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    Group {
                        HStack {
                            Text("Tabla:")
                                .font(.subheadline.bold())
                            Text(jornada.tabla)
                                .font(.subheadline)
                            Spacer()
                            Text("Total:")
                                .font(.subheadline.bold())
                            Text(String(format: "%.2f", jornada.totalImporte))
                                .font(.subheadline.monospacedDigit())
                        }
                    }

                    Divider()

                    // Detail and discrepancies
                    detailSection
                    discrepancySection

                    // Entries table
                    entriesTable

                    // Edit button
                    Button {
                        store.editJornada(jornada)
                        shouldDismissAll = true
                    } label: {
                        Label("Editar esta jornada", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding()
            }
            .navigationTitle("Jornada: \(jornada.fecha)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .onChange(of: shouldDismissAll) { _, val in
                if val { dismiss() }
            }
        }
    }

    private var detailSection: some View {
        let details = jornada.filas.compactMap { e -> (String, Double)? in
            let imp = (Double(e.venta) ?? 0) * (Double(e.precio) ?? 0)
            return imp > 0 ? (e.nombre, imp) : nil
        }
        return Group {
            if !details.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Detalle:")
                        .font(.subheadline.bold())
                    ForEach(details, id: \.0) { nombre, importe in
                        HStack {
                            Text(nombre)
                                .font(.caption)
                            Spacer()
                            Text(String(format: "%.2f", importe))
                                .font(.caption.monospacedDigit())
                        }
                    }
                }
            }
        }
    }

    private var discrepancySection: some View {
        let discs = jornada.filas.compactMap { e -> (String, Double)? in
            let f = e.finalVal.trimmingCharacters(in: .whitespaces)
            guard !f.isEmpty, let finalNum = Double(f) else { return nil }
            let i = Double(e.inicial) ?? 0
            let v = Double(e.venta) ?? 0
            let diff = ((finalNum - (i - v)) * 100).rounded() / 100
            return diff != 0 ? (e.nombre, diff) : nil
        }
        return Group {
            if !discs.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discrepancias:")
                        .font(.subheadline.bold())
                        .foregroundStyle(.red)
                    ForEach(discs, id: \.0) { nombre, diff in
                        Text("Atención: \(diff > 0 ? "+" : "")\(String(format: "%.2f", diff)) \(nombre)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }

    private var entriesTable: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                headerCell("Producto", flex: true)
                headerCell("Inicial", width: 55)
                headerCell("Venta", width: 50)
                headerCell("Precio", width: 55)
                headerCell("Importe", width: 60)
                headerCell("Final", width: 50)
            }
            .background(Color(.systemGray5))

            // Rows
            ForEach(jornada.filas) { entry in
                HStack(spacing: 0) {
                    dataCell(entry.nombre, flex: true, align: .leading)
                    dataCell(entry.inicial, width: 55)
                    dataCell(entry.venta, width: 50)
                    dataCell(entry.precio, width: 55)
                    dataCell(entry.importe > 0 ? String(format: "%.2f", entry.importe) : "", width: 60)
                    dataCell(entry.finalVal, width: 50)
                }
            }
        }
        .border(Color(.systemGray4), width: 1)
        .cornerRadius(4)
    }

    private func headerCell(_ text: String, width: CGFloat? = nil, flex: Bool = false) -> some View {
        Text(text)
            .font(.caption2.bold())
            .padding(4)
            .frame(width: flex ? nil : width, maxWidth: flex ? .infinity : nil)
            .frame(height: 30)
            .border(Color(.systemGray4), width: 0.5)
    }

    private func dataCell(_ text: String, width: CGFloat? = nil, flex: Bool = false, align: Alignment = .center) -> some View {
        Text(text)
            .font(.caption2.monospacedDigit())
            .lineLimit(1)
            .padding(4)
            .frame(width: flex ? nil : width, maxWidth: flex ? .infinity : nil, alignment: align)
            .frame(minHeight: 28)
            .border(Color(.systemGray4), width: 0.5)
    }
}
