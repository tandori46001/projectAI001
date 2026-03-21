import SwiftUI

struct HistorialView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var selectedJornada: Jornada? = nil
    @State private var showDeleteAlert = false
    @State private var jornadaToDelete: Jornada? = nil

    var sortedHistorial: [Jornada] {
        store.historial.sorted { $0.fecha > $1.fecha }
    }

    var body: some View {
        NavigationStack {
            List {
                if sortedHistorial.isEmpty {
                    Text("Sin jornadas guardadas")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedHistorial) { jornada in
                        Button {
                            selectedJornada = jornada
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(jornada.fecha)
                                        .font(.body.bold())
                                        .foregroundStyle(.primary)
                                    Text(jornada.tabla)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(String(format: "%.2f €", jornada.totalImporte))
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                jornadaToDelete = jornada
                                showDeleteAlert = true
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedJornada) { jornada in
                JornadaDetailView(jornada: jornada) {
                    selectedJornada = nil
                    dismiss()
                }
            }
            .alert("Eliminar jornada", isPresented: $showDeleteAlert) {
                Button("Eliminar", role: .destructive) {
                    if let jornada = jornadaToDelete {
                        store.deleteJornada(jornada)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                if let j = jornadaToDelete {
                    Text("Se eliminará la jornada del \(j.fecha) de la tabla \"\(j.tabla)\".")
                }
            }
        }
    }
}

struct JornadaDetailView: View {
    @Environment(DataStore.self) private var store
    let jornada: Jornada
    var onEdit: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showImporteDetail = false
    @State private var showDiscrepanciaDetail = false

    var entriesConVenta: [JornadaEntry] {
        jornada.filas.filter { (Double($0.venta) ?? 0) > 0 }
    }

    var entriesConDiscrepancia: [JornadaEntry] {
        jornada.filas.filter { $0.discrepancia != nil }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(jornada.fecha)
                                .font(.title2.bold())
                            Text(jornada.tabla)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(String(format: "%.2f €", jornada.totalImporte))
                            .font(.title.bold())
                            .foregroundStyle(.green)
                    }
                    .padding(.horizontal)

                    // Table of entries
                    VStack(spacing: 0) {
                        // Header row
                        HStack {
                            Text("Producto").font(.caption.bold()).frame(maxWidth: .infinity, alignment: .leading)
                            Text("Ini").font(.caption.bold()).frame(width: 35)
                            Text("Vta").font(.caption.bold()).frame(width: 35)
                            Text("Precio").font(.caption.bold()).frame(width: 50)
                            Text("Importe").font(.caption.bold()).frame(width: 55)
                            Text("Fin").font(.caption.bold()).frame(width: 35)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))

                        ForEach(jornada.filas) { entry in
                            HStack {
                                Text(entry.nombre).font(.caption).frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
                                Text(entry.inicial).font(.caption).frame(width: 35)
                                Text(entry.venta).font(.caption).frame(width: 35)
                                Text(entry.precio).font(.caption).frame(width: 50)
                                Text(String(format: "%.2f", entry.importe)).font(.caption).frame(width: 55)
                                Text(entry.finalVal).font(.caption).frame(width: 35)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)

                    // Detalle importe
                    DisclosureGroup("Detalle Importe (\(entriesConVenta.count))", isExpanded: $showImporteDetail) {
                        ForEach(entriesConVenta) { entry in
                            HStack {
                                Text(entry.nombre).font(.subheadline)
                                Spacer()
                                Text(String(format: "%.2f €", entry.importe))
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Discrepancias
                    if !entriesConDiscrepancia.isEmpty {
                        DisclosureGroup(isExpanded: $showDiscrepanciaDetail) {
                            ForEach(entriesConDiscrepancia) { entry in
                                HStack {
                                    Text(entry.nombre).font(.subheadline)
                                    Spacer()
                                    Text(String(format: "%+.2f", entry.discrepancia ?? 0))
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.red)
                                }
                            }
                        } label: {
                            Text("Discrepancias (\(entriesConDiscrepancia.count))")
                                .foregroundStyle(.red)
                        }
                        .padding(.horizontal)
                    }

                    // Edit button
                    Button {
                        store.editJornada(jornada)
                        dismiss()
                        onEdit()
                    } label: {
                        Label("Editar esta jornada", systemImage: "pencil")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Detalle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
