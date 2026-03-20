import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var vm: JornadaViewModel?
    @State private var showCatalog = false
    @State private var showExportShare = false
    @State private var exportItems: [Any] = []

    var body: some View {
        Group {
            if let vm {
                mainContent(vm)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if vm == nil {
                vm = JornadaViewModel(modelContext: modelContext)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(Strings.done) {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func mainContent(_ vm: JornadaViewModel) -> some View {
        VStack(spacing: 0) {
            // Table selector (fixed at top, not scrollable)
            TableSelectorBar(vm: vm)

            // Edit banner (when editing historical jornada)
            if vm.isEditingHistorical {
                editBanner(vm)
            }

            // Backup reminder
            if vm.showBackupReminder {
                backupBanner(vm)
            }

            // Single ScrollView for all content
            ScrollView {
                VStack(spacing: 0) {
                    // Jornada content (date, entries, summary)
                    JornadaView(vm: vm)

                    // Action buttons (below the jornada data)
                    ActionButtonsView(
                        vm: vm,
                        onShowCatalog: { showCatalog = true },
                        onExportCSV: { exportCSV(vm) },
                        onExportPDF: { exportPDF(vm) }
                    )

                    // History
                    HistoryListView(vm: vm)
                }
            }
        }
        .sheet(isPresented: $showCatalog) {
            CatalogView()
        }
        .sheet(isPresented: $showExportShare) {
            ShareSheet(items: exportItems)
        }
        .alert(Strings.savedMessage, isPresented: $vm.showSavedAlert) {
            Button("OK") {}
        } message: {
            Text(vm.savedAlertMessage)
        }
    }

    // MARK: - Edit Banner

    private func editBanner(_ vm: JornadaViewModel) -> some View {
        HStack {
            Text(Strings.editingBanner)
                .font(.subheadline)
                .foregroundColor(AppColors.warningText)
            Spacer()
            Button(Strings.cancelEdit) {
                vm.cancelEditing()
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(AppColors.borderGray, lineWidth: 1)
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(AppColors.warningBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(AppColors.warning, lineWidth: 1)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    // MARK: - Backup Banner

    private func backupBanner(_ vm: JornadaViewModel) -> some View {
        HStack {
            Text(Strings.backupReminder)
                .font(.caption)
                .foregroundColor(AppColors.warningText)
            Spacer()
            Button(Strings.backupDismiss) {
                vm.showBackupReminder = false
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white)
            .cornerRadius(4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(AppColors.warningBackground)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }

    // MARK: - Export

    private func exportCSV(_ vm: JornadaViewModel) {
        guard let jornada = vm.activeJornada, let table = vm.activeTable else { return }
        let url = CSVExporter.export(jornada: jornada, tableName: table.name)
        if let url {
            exportItems = [url]
            showExportShare = true
        }
    }

    private func exportPDF(_ vm: JornadaViewModel) {
        guard let jornada = vm.activeJornada, let table = vm.activeTable else { return }
        let url = PDFExporter.export(jornada: jornada, tableName: table.name)
        if let url {
            exportItems = [url]
            showExportShare = true
        }
    }
}
