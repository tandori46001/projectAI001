import SwiftUI

struct JornadaEntryRow: View {
    @Bindable var entry: JornadaEntry
    let onUpdate: () -> Void
    let onDelete: () -> Void

    @State private var nameText: String = ""
    @State private var initialText: String = ""
    @State private var salesText: String = ""
    @State private var priceText: String = ""
    @State private var finalText: String = ""

    var body: some View {
        HStack(spacing: 4) {
            // Product name
            TextField(Strings.productName, text: $nameText)
                .frame(minWidth: 90)
                .font(.subheadline)
                .onChange(of: nameText) { _, val in
                    entry.productName = val
                    onUpdate()
                }

            Divider()

            // Initial stock
            TextField(Strings.initial, text: $initialText)
                .keyboardType(.decimalPad)
                .frame(width: 52)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .onChange(of: initialText) { _, val in
                    entry.initialStock = Double(val)
                    onUpdate()
                }

            Divider()

            // Sales
            TextField(Strings.sales, text: $salesText)
                .keyboardType(.decimalPad)
                .frame(width: 52)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .onChange(of: salesText) { _, val in
                    entry.sales = Double(val)
                    onUpdate()
                }

            Divider()

            // Price
            TextField(Strings.price, text: $priceText)
                .keyboardType(.decimalPad)
                .frame(width: 56)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .onChange(of: priceText) { _, val in
                    entry.price = Double(val) ?? 0
                    onUpdate()
                }

            Divider()

            // Importe (read-only)
            Text(entry.importe > 0 ? Fmt.currency(entry.importe) : "")
                .frame(width: 58)
                .font(.subheadline)
                .foregroundColor(AppColors.mutedText)
                .multilineTextAlignment(.center)

            Divider()

            // Final stock
            TextField(Strings.finalStock, text: $finalText)
                .keyboardType(.decimalPad)
                .frame(width: 52)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .onChange(of: finalText) { _, val in
                    entry.finalStock = val.isEmpty ? nil : Double(val)
                    onUpdate()
                }

            // Delete button
            Button { onDelete() } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(AppColors.danger)
            }
            .buttonStyle(.plain)
            .frame(width: 24)
        }
        .padding(.vertical, 4)
        .onAppear {
            nameText = entry.productName
            initialText = entry.initialStock.map { formatOptionalNum($0) } ?? ""
            salesText = entry.sales.map { formatOptionalNum($0) } ?? ""
            priceText = entry.price > 0 ? formatOptionalNum(entry.price) : ""
            finalText = entry.finalStock.map { formatOptionalNum($0) } ?? ""
        }
    }

    private func formatOptionalNum(_ val: Double) -> String {
        if val == val.rounded() && val < 1_000_000 {
            return String(format: "%.0f", val)
        }
        return Fmt.currency(val)
    }
}
