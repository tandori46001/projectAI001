import SwiftUI

struct JornadaView: View {
    @Bindable var vm: JornadaViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Date picker
            HStack(spacing: 10) {
                Text(Strings.date + ":")
                    .font(.subheadline.bold())
                DatePicker("", selection: $vm.selectedDate, displayedComponents: .date)
                    .labelsHidden()
                    .onChange(of: vm.selectedDate) { _, newDate in
                        vm.updateDate(newDate)
                    }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Column headers
            headerRow
                .padding(.horizontal, 8)

            Divider()

            // Entry rows
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(vm.entries, id: \.id) { entry in
                        VStack(spacing: 0) {
                            JornadaEntryRow(
                                entry: entry,
                                onUpdate: { vm.updateEntry(entry) },
                                onDelete: { vm.deleteEntry(entry) }
                            )
                            .padding(.horizontal, 8)
                            Divider()
                        }
                    }
                }

                // Add row button
                Button(Strings.addRow) {
                    vm.addEntry()
                }
                .font(.subheadline)
                .foregroundColor(AppColors.primary)
                .padding(.vertical, 8)

                // Summary
                summarySection
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(spacing: 4) {
            Text(Strings.productName)
                .frame(minWidth: 90, alignment: .leading)
            Divider().frame(height: 16)
            Text(Strings.initial)
                .frame(width: 52)
            Divider().frame(height: 16)
            Text(Strings.sales)
                .frame(width: 52)
            Divider().frame(height: 16)
            Text(Strings.price)
                .frame(width: 56)
            Divider().frame(height: 16)
            Text(Strings.amount)
                .frame(width: 58)
            Divider().frame(height: 16)
            Text(Strings.finalStock)
                .frame(width: 52)
            Spacer().frame(width: 24)
        }
        .font(.caption.bold())
        .foregroundColor(AppColors.mutedText)
        .padding(.vertical, 6)
        .background(AppColors.lightGray)
        .cornerRadius(4)
    }

    // MARK: - Summary

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Total
            HStack {
                Text(Strings.totalAmount + ":")
                    .font(.headline)
                Spacer()
                Text(Fmt.currency(vm.totalImporte))
                    .font(.headline.monospacedDigit())
            }
            .padding(.top, 8)

            // Sales detail
            if !vm.salesDetail.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.salesDetail + ":")
                        .font(.subheadline.bold())
                    ForEach(vm.salesDetail, id: \.name) { item in
                        Text("\(item.name): \(Fmt.currency(item.importe))")
                            .font(.subheadline)
                            .foregroundColor(AppColors.mutedText)
                    }
                }
            }

            // Discrepancies
            if !vm.discrepancies.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.discrepancies + ":")
                        .font(.subheadline.bold())
                        .foregroundColor(AppColors.discrepancy)
                    ForEach(vm.discrepancies, id: \.name) { item in
                        let sign = item.diff > 0 ? "+" : ""
                        Text("\(Strings.discrepancyWarning): \(sign)\(Fmt.currency(item.diff)) \(item.name)")
                            .font(.subheadline)
                            .foregroundColor(AppColors.discrepancy)
                    }
                }
            }
        }
    }
}
