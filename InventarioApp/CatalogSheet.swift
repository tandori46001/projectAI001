import SwiftUI

struct CatalogSheet: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss

    @State private var products: [CatalogProduct] = []
    @State private var showImporter = false
    @State private var showExportShare = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Toolbar actions
                HStack(spacing: 12) {
                    Button("Ordenar A→Z") {
                        products.sort {
                            $0.nombre.localizedCaseInsensitiveCompare($1.nombre) == .orderedAscending
                        }
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)

                    Button("Exportar JSON") { exportJSON() }
                        .font(.caption)
                        .buttonStyle(.bordered)

                    Button("Importar JSON") { showImporter = true }
                        .font(.caption)
                        .buttonStyle(.bordered)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Product list
                List {
                    ForEach($products) { $product in
                        HStack(spacing: 12) {
                            TextField("Nombre del producto", text: $product.nombre)

                            TextField("Precio", value: $product.precio, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .onDelete { indexSet in
                        products.remove(atOffsets: indexSet)
                    }
                    .onMove { source, destination in
                        products.move(fromOffsets: source, toOffset: destination)
                    }

                    Button {
                        products.append(CatalogProduct())
                    } label: {
                        Label("Agregar producto", systemImage: "plus")
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Catálogo de Productos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { guardar() }
                        .bold()
                }
            }
            .onAppear {
                products = store.catalog
            }
            .fileImporter(isPresented: $showImporter,
                          allowedContentTypes: [.json]) { result in
                importJSON(result: result)
            }
            .sheet(isPresented: $showExportShare) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private func guardar() {
        let valid = products.filter { !$0.nombre.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !valid.isEmpty else { return }
        store.catalog = valid
        store.saveCatalog()
        dismiss()
    }

    private func exportJSON() {
        let data = try? JSONEncoder().encode(products.map {
            ["nombre": $0.nombre, "precio": String($0.precio)]
        })
        guard let data else { return }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("catalogo_inv2.json")
        try? data.write(to: url)
        exportURL = url
        showExportShare = true
    }

    private func importJSON(result: Result<URL, Error>) {
        guard let url = try? result.get(),
              url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        guard let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([[String: String]].self, from: data) else {
            return
        }

        products = items.compactMap { dict in
            guard let nombre = dict["nombre"], !nombre.isEmpty else { return nil }
            let precio = Double(dict["precio"] ?? "0") ?? 0
            return CatalogProduct(nombre: nombre, precio: precio)
        }
    }
}
