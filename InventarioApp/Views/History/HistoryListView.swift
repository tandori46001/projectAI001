import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var vm: JornadaViewModel

    @State private var historyVM: HistoryViewModel?
    @State private var selectedJornada: Jornada?
    @State private var showDeleteConfirm = false
    @State private var jornadaToDelete: Jornada?
    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.top, 8)

            DisclosureGroup(isExpanded: $isExpanded) {
                if let historyVM {
                    if historyVM.savedJornadas.isEmpty {
                        Text(Strings.noHistory)
                            .font(.subheadline)
                            .foregroundColor(AppColors.mutedText)
                            .padding(.vertical, 12)
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(historyVM.savedJornadas, id: \.id) { jornada in
                                historyRow(jornada)
                            }
                        }
                    }
                }
            } label: {
                Text(Strings.history)
                    .font(.headline)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .onAppear {
            if historyVM == nil {
                historyVM = HistoryViewModel(modelContext: modelContext)
            }
        }
        .onChange(of: vm.showSavedAlert) { _, _ in
            historyVM?.fetchHistory()
        }
        .sheet(item: $selectedJornada) { jornada in
            HistoryDetailView(
                jornada: jornada,
                onEdit: {
                    selectedJornada = nil
                    vm.startEditingHistorical(jornada)
                }
            )
        }
        .confirmationDialog(
            Strings.deleteConfirmTitle,
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(Strings.delete, role: .destructive) {
                if let jornada = jornadaToDelete {
                    historyVM?.deleteJornada(jornada)
                }
            }
        }
    }

    private func historyRow(_ jornada: Jornada) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(jornada.dateString)
                    .font(.subheadline.bold())
                Text(jornada.table?.name ?? "—")
                    .font(.caption)
                    .foregroundColor(AppColors.mutedText)
            }

            Spacer()

            Text("\(Strings.total): \(Fmt.currency(jornada.totalImporte))")
                .font(.subheadline)

            // View/Edit button
            Button(Strings.viewEdit) {
                selectedJornada = jornada
            }
            .font(.caption)
            .buttonStyle(.bordered)
            .controlSize(.small)

            // Delete button
            Button {
                jornadaToDelete = jornada
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(AppColors.danger)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

// Make Jornada identifiable for sheet(item:)
extension Jornada: @retroactive Identifiable {}
