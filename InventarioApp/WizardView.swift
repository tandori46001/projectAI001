import SwiftUI

struct WizardView: View {
    @Environment(DataStore.self) private var store
    @State private var products: [CatalogProduct] = [
        CatalogProduct(nombre: "", precio: 0)
    ]
    @State private var isEditing = false

    var canContinue: Bool {
        products.contains { !$0.nombre.trimmingCharacters(in: .whitespaces).isEmpty && $0.precio > 0 }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        Text("Introduce los productos de tu inventario con su precio unitario.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Section("Productos") {
                        ForEach($products) { $product in
                            HStack {
                                TextField("Nombre", text: $product.nombre)
                                    .textContentType(.name)
                                Divider()
                                TextField("Precio", value: $product.precio, format: .number)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 80)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .onDelete { indexSet in
                            products.remove(atOffsets: indexSet)
                        }
                        .onMove { from, to in
                            products.move(fromOffsets: from, toOffset: to)
                        }
                    }

                    Section {
                        Button {
                            products.append(CatalogProduct(nombre: "", precio: 0))
                        } label: {
                            Label("Agregar producto", systemImage: "plus.circle.fill")
                        }
                    }
                }
                .environment(\.editMode, .constant(isEditing ? .active : .inactive))

                VStack(spacing: 12) {
                    Button {
                        isEditing.toggle()
                    } label: {
                        Label(isEditing ? "Listo" : "Reordenar", systemImage: isEditing ? "checkmark" : "arrow.up.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        let valid = products.filter {
                            !$0.nombre.trimmingCharacters(in: .whitespaces).isEmpty && $0.precio > 0
                        }
                        store.completeWizard(products: valid)
                    } label: {
                        Text("Comenzar")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canContinue)
                }
                .padding()
            }
            .navigationTitle("Configurar Inventario")
        }
    }
}
