import SwiftUI

struct ActionButtonsView: View {
    @Bindable var vm: JornadaViewModel

    let onShowCatalog: () -> Void
    let onExportCSV: () -> Void
    let onExportPDF: () -> Void

    @State private var showClearConfirm = false

    var body: some View {
        VStack(spacing: 8) {
            // Primary row
            HStack(spacing: 8) {
                Button {
                    vm.guardarDia()
                } label: {
                    Text(Strings.saveDay)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppColors.primary)
                        .cornerRadius(6)
                }

                Button {
                    onShowCatalog()
                } label: {
                    Text(Strings.catalog)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.lightGray)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AppColors.borderGray, lineWidth: 1)
                        )
                }

                Spacer()

                Button {
                    showClearConfirm = true
                } label: {
                    Text(Strings.clear)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.danger)
                        .cornerRadius(6)
                }
            }

            // Export row
            HStack(spacing: 8) {
                Button {
                    onExportCSV()
                } label: {
                    Text(Strings.exportCSV)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.lightGray)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AppColors.borderGray, lineWidth: 1)
                        )
                }

                Button {
                    onExportPDF()
                } label: {
                    Text(Strings.exportPDF)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.lightGray)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AppColors.borderGray, lineWidth: 1)
                        )
                }

                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .confirmationDialog(
            Strings.clearConfirmTitle,
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button(Strings.clear, role: .destructive) {
                vm.limpiar()
            }
        } message: {
            Text(Strings.clearConfirmMessage)
        }
    }
}
