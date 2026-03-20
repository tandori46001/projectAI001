import SwiftUI
import UniformTypeIdentifiers

struct CatalogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var vm: CatalogViewModel?
    @State private var showImporter = false
    @State private var showExportShare = false
    @State private var exportURL: URL?
    @State private var importError: String?
    @State private var showImportError = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm {
                    catalogContent(vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(Strings.catalog)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.saveCatalog) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if vm == nil {
                vm = CatalogViewModel(modelContext: modelContext)
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
            handleImport(result)
        }
        .sheet(isPresented: $showExportShare) {
            if let exportURL {
                ShareSheet(items: [exportURL])
            }
        }
        .alert("Error de importación", isPresented: $showImportError) {
            Button("OK") {}
        } message: {
            Text(importError ?? "Error desconocido")
        }
    }

    @ViewBuilder
    private func catalogContent(_ vm: CatalogViewModel) -> some View {
        VStack(spacing: 0) {
            // Action buttons
            HStack(spacing: 12) {
                Button(Strings.sortAZ) {
                    vm.sortAlphabetically()
                }
                .font(.subheadline)

                Spacer()

                Button(Strings.exportJSON) {
                    exportURL = vm.exportJSONFileURL()
                    if exportURL != nil { showExportShare = true }
                }
                .font(.subheadline)

                Button(Strings.importJSON) {
                    showImporter = true
                }
                .font(.subheadline)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Product list
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
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let data = try Data(contentsOf: url)
                try vm?.importJSON(data: data)
            } catch {
                importError = error.localizedDescription
                showImportError = true
            }
        case .failure(let error):
            importError = error.localizedDescription
            showImportError = true
        }
    }
}

// MARK: - CatalogProductRow

struct CatalogProductRow: View {
    let product: Product
    let isFirst: Bool
    let isLast: Bool
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let onDelete: () -> Void
    let onUpdate: (String, Double) -> Void

    @State private var name: String = ""
    @State private var priceText: String = ""
    @FocusState private var focusedField: Field?

    enum Field { case name, price }

    var body: some View {
        HStack(spacing: 8) {
            // Reorder buttons
            VStack(spacing: 2) {
                Button { onMoveUp() } label: {
                    Image(systemName: "chevron.up")
                        .font(.caption2)
                }
                .disabled(isFirst)
                .buttonStyle(.bordered)
                .controlSize(.mini)

                Button { onMoveDown() } label: {
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .disabled(isLast)
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }

            // Name
            TextField(Strings.productName, text: $name)
                .focused($focusedField, equals: .name)
                .textFieldStyle(.roundedBorder)
                .onChange(of: name) { _, newVal in
                    onUpdate(newVal, Double(priceText) ?? product.defaultPrice)
                }

            // Price
            TextField(Strings.productPrice, text: $priceText)
                .focused($focusedField, equals: .price)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .frame(width: 80)
                .onChange(of: priceText) { _, newVal in
                    onUpdate(name, Double(newVal) ?? 0)
                }

            // Delete
            Button { onDelete() } label: {
                Image(systemName: "trash")
                    .foregroundColor(AppColors.danger)
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            name = product.name
            priceText = product.defaultPrice > 0 ? Fmt.currency(product.defaultPrice) : ""
        }
    }
}

// MARK: - ShareSheet (UIKit wrapper)

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
