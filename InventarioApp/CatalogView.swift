import SwiftUI
import UniformTypeIdentifiers

struct CatalogView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var editedCatalog: [CatalogProduct] = []
    @State private var isEditing = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var showImportPicker = false

    var body: some View {
        NavigationStack {
            List {
                ForEach($editedCatalog) { $product in
                    HStack {
                        TextField("Nombre", text: $product.nombre)
                        Divider()
                        TextField("Precio", value: $product.precio, format: .number)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .onDelete { indexSet in
                    editedCatalog.remove(atOffsets: indexSet)
                }
                .onMove { from, to in
                    editedCatalog.move(fromOffsets: from, toOffset: to)
                }

                Section {
                    Button {
                        editedCatalog.append(CatalogProduct(nombre: "", precio: 0))
                    } label: {
                        Label("Agregar producto", systemImage: "plus.circle.fill")
                    }
                }

                Section {
                    Button {
                        editedCatalog.sort { $0.nombre.localizedCaseInsensitiveCompare($1.nombre) == .orderedAscending }
                    } label: {
                        Label("Ordenar A→Z", systemImage: "arrow.up.arrow.down")
                    }

                    Button {
                        exportJSON()
                    } label: {
                        Label("Exportar JSON", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showImportPicker = true
                    } label: {
                        Label("Importar JSON", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .navigationTitle("Catálogo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Button(isEditing ? "Listo" : "Reordenar") {
                            isEditing.toggle()
                        }
                        Button("Guardar") {
                            saveCatalog()
                        }
                        .bold()
                    }
                }
            }
            .onAppear {
                editedCatalog = store.catalog
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: shareItems)
            }
            .fileImporter(isPresented: $showImportPicker, allowedContentTypes: [.json]) { result in
                importJSON(result: result)
            }
        }
    }

    private func saveCatalog() {
        let valid = editedCatalog.filter {
            !$0.nombre.trimmingCharacters(in: .whitespaces).isEmpty
        }
        store.catalog = valid
        store.saveCatalog()
        dismiss()
    }

    private func exportJSON() {
        guard let data = try? JSONEncoder().encode(editedCatalog),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("catalogo.json")
        try? jsonString.write(to: url, atomically: true, encoding: .utf8)
        shareItems = [url]
        showShareSheet = true
    }

    private func importJSON(result: Result<URL, Error>) {
        guard case .success(let url) = result else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url),
              let imported = try? JSONDecoder().decode([CatalogProduct].self, from: data) else { return }
        editedCatalog = imported
    }
}
