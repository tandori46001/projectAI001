import SwiftUI

struct HistoryDetailView: View {
    let jornada: Jornada
    let onEdit: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Header info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Jornada: \(jornada.dateString)")
                            .font(.headline)
                        Text(jornada.table?.name ?? "—")
                            .font(.subheadline)
                            .foregroundColor(AppColors.mutedText)
                        Text("Total: \(Fmt.currency(jornada.totalImporte))")
                            .font(.subheadline.bold())
                    }
                    .padding(.horizontal)

                    // Table
                    detailTable

                    // Detail and discrepancies
                    detailSummary
                        .padding(.horizontal)

                    // Edit button
                    Button {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onEdit()
                        }
                    } label: {
                        Text(Strings.editThisDay)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppColors.primary)
                            .cornerRadius(6)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top, 12)
            }
            .navigationTitle("Detalle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    // MARK: - Detail Table

    private var sortedEntries: [JornadaEntry] {
        (jornada.entries).sorted { $0.sortOrder < $1.sortOrder }
    }

    private var detailTable: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                headerCell(Strings.productName, alignment: .leading, flex: true)
                headerCell(Strings.initial, width: 55)
                headerCell(Strings.sales, width: 50)
                headerCell(Strings.price, width: 55)
                headerCell(Strings.amount, width: 58)
                headerCell(Strings.finalStock, width: 50)
            }
            .background(AppColors.lightGray)

            Divider()

            // Rows
            ForEach(sortedEntries, id: \.id) { entry in
                HStack(spacing: 0) {
                    dataCell(entry.productName, alignment: .leading, flex: true)
                    dataCell(formatOpt(entry.initialStock), width: 55)
                    dataCell(formatOpt(entry.sales), width: 50)
                    dataCell(entry.price > 0 ? Fmt.currency(entry.price) : "", width: 55)
                    dataCell(entry.importe > 0 ? Fmt.currency(entry.importe) : "", width: 58)
                    dataCell(formatOpt(entry.finalStock), width: 50)
                }
                Divider()
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(AppColors.borderGray, lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private func headerCell(_ text: String, alignment: Alignment = .center, width: CGFloat? = nil, flex: Bool = false) -> some View {
        Group {
            if flex {
                Text(text)
                    .frame(maxWidth: .infinity, alignment: alignment)
            } else {
                Text(text)
                    .frame(width: width, alignment: alignment)
            }
        }
        .font(.caption.bold())
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
    }

    private func dataCell(_ text: String, alignment: Alignment = .center, width: CGFloat? = nil, flex: Bool = false) -> some View {
        Group {
            if flex {
                Text(text)
                    .frame(maxWidth: .infinity, alignment: alignment)
            } else {
                Text(text)
                    .frame(width: width, alignment: alignment)
            }
        }
        .font(.caption)
        .padding(.vertical, 5)
        .padding(.horizontal, 4)
    }

    // MARK: - Summary

    private var detailSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Detail
            let detail = sortedEntries.filter { $0.importe > 0 }
            if !detail.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Detalle:")
                        .font(.subheadline.bold())
                    ForEach(detail, id: \.id) { entry in
                        Text("\(entry.productName): \(Fmt.currency(entry.importe))")
                            .font(.caption)
                            .foregroundColor(AppColors.mutedText)
                    }
                }
            }

            // Discrepancies
            let discs = sortedEntries.compactMap { entry -> (String, Double)? in
                guard let disc = entry.discrepancy else { return nil }
                return (entry.productName, disc)
            }
            if !discs.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Strings.discrepancies + ":")
                        .font(.subheadline.bold())
                        .foregroundColor(AppColors.discrepancy)
                    ForEach(discs, id: \.0) { name, diff in
                        let sign = diff > 0 ? "+" : ""
                        Text("\(Strings.discrepancyWarning): \(sign)\(Fmt.currency(diff)) \(name)")
                            .font(.caption)
                            .foregroundColor(AppColors.discrepancy)
                    }
                }
            }
        }
    }

    private func formatOpt(_ val: Double?) -> String {
        guard let val else { return "" }
        if val == val.rounded() && val < 1_000_000 {
            return String(format: "%.0f", val)
        }
        return Fmt.currency(val)
    }
}
