import SwiftUI

struct WizardView: View {
    @EnvironmentObject var store: DataStore
    @State private var products: [CatalogProduct] = [CatalogProduct()]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Configura tu catálogo de productos")
                    .font(.headline)

                Text("Ingresa todos los productos con su nombre y precio. Podrás editarlos en cualquier momento desde el botón Catálogo.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                List {
                    ForEach($products) { $product in
                        HStack(spacing: 12) {
                            TextField("Nombre del producto", text: $product.nombre)
                                .textContentType(.name)

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
                }
                .listStyle(.plain)

                Button {
                    products.append(CatalogProduct())
                } label: {
                    Label("Agregar producto", systemImage: "plus")
                }

                HStack {
                    Button {
                        guardar()
                    } label: {
                        Text("Comenzar")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Text("Al menos un producto es necesario.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .navigationTitle("Bienvenido")
            .toolbar {
                EditButton()
            }
        }
    }

    private func guardar() {
        let valid = products.filter { !$0.nombre.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !valid.isEmpty else { return }
        store.catalog = valid
        store.saveCatalog()
        store.loadCurrentSession()
    }
}
