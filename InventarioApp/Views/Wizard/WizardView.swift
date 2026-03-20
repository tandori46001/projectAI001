import SwiftUI
import SwiftData

struct WizardView: View {
    @Environment(\.modelContext) private var modelContext

    let onComplete: () -> Void

    @State private var vm: CatalogViewModel?
    @State private var showValidationError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text(Strings.wizardTitle)
                        .font(.largeTitle.bold())
                    Text(Strings.wizardSubtitle)
                        .font(.subheadline)
                        .foregroundColor(AppColors.mutedText)
                    Text(Strings.wizardHint)
                        .font(.caption)
                        .foregroundColor(AppColors.mutedText)
                        .padding(.top, 4)
                }
                .padding(.vertical, 20)
                .padding(.horizontal)

                // Product list
                if let vm {
                    List {
                        ForEach(vm.products, id: \.id) { product in
                            CatalogProductRow(
                                product: product,
                                isFirst: product.id == vm.products.first?.id,
                                isLast: product.id == vm.products.last?.id,
                                onMoveUp: { vm.moveUp(product) },
                                onMoveDown: { vm.moveDown(product) },
                                onDelete: { vm.deleteProduct(product) },
                                onUpdate: { name, price in vm.updateProduct(product, name: name, price: price) }
                            )
                        }

                        Button(Strings.addProduct) {
                            vm.addProduct()
                        }
                        .foregroundColor(AppColors.primary)
                    }
                    .listStyle(.plain)
                }

                // Start button
                Button {
                    attemptStart()
                } label: {
                    Text(Strings.wizardStart)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.primary)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            if vm == nil {
                vm = CatalogViewModel(modelContext: modelContext)
                if vm?.isEmpty == true {
                    vm?.addProduct()
                }
            }
        }
        .alert("Catálogo vacío", isPresented: $showValidationError) {
            Button("OK") {}
        } message: {
            Text(Strings.wizardHint)
        }
    }

    private func attemptStart() {
        guard let vm else { return }
        vm.fetchProducts()

        let validProducts = vm.products.filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
        if validProducts.isEmpty {
            showValidationError = true
            return
        }

        // Remove empty-named products
        for product in vm.products {
            if product.name.trimmingCharacters(in: .whitespaces).isEmpty {
                vm.deleteProduct(product)
            }
        }

        // Create default table if none exists
        let tableDescriptor = FetchDescriptor<InventoryTable>()
        let tables = (try? modelContext.fetch(tableDescriptor)) ?? []
        if tables.isEmpty {
            let table = InventoryTable(name: Strings.defaultTableName, sortOrder: 0)
            modelContext.insert(table)
            try? modelContext.save()
        }

        onComplete()
    }
}
