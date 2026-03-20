import SwiftUI

struct TableSelectorBar: View {
    @Bindable var vm: JornadaViewModel

    @State private var showNewTableAlert = false
    @State private var showRenameAlert = false
    @State private var showDeleteConfirm = false
    @State private var newTableName = ""

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(Strings.table + ":")
                    .font(.subheadline.bold())

                if !vm.tables.isEmpty {
                    Picker("", selection: Binding(
                        get: { vm.activeTable?.id ?? UUID() },
                        set: { newId in
                            if let table = vm.tables.first(where: { $0.id == newId }) {
                                vm.switchTable(to: table)
                            }
                        }
                    )) {
                        ForEach(vm.tables, id: \.id) { table in
                            Text(table.name).tag(table.id)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Spacer()

                // New table
                Button {
                    newTableName = ""
                    showNewTableAlert = true
                } label: {
                    Text(Strings.newTable)
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            HStack(spacing: 8) {
                // Rename
                Button {
                    newTableName = vm.activeTable?.name ?? ""
                    showRenameAlert = true
                } label: {
                    Text(Strings.renameTable)
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                // Delete
                Button {
                    showDeleteConfirm = true
                } label: {
                    Text(Strings.deleteTable)
                        .font(.caption)
                        .foregroundColor(AppColors.danger)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(vm.tables.count <= 1)

                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(AppColors.lightGray)
        // New table alert
        .alert("Nueva tabla", isPresented: $showNewTableAlert) {
            TextField("Nombre", text: $newTableName)
            Button(Strings.cancel, role: .cancel) {}
            Button("Crear") {
                let name = newTableName.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty {
                    vm.createTable(name: name)
                }
            }
        }
        // Rename alert
        .alert(Strings.renameTable, isPresented: $showRenameAlert) {
            TextField("Nombre", text: $newTableName)
            Button(Strings.cancel, role: .cancel) {}
            Button("Guardar") {
                let name = newTableName.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty, let table = vm.activeTable {
                    vm.renameTable(table, newName: name)
                }
            }
        }
        // Delete confirmation
        .confirmationDialog(
            "¿Eliminar la tabla \"\(vm.activeTable?.name ?? "")\"?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(Strings.delete, role: .destructive) {
                if let table = vm.activeTable {
                    vm.deleteTable(table)
                }
            }
        } message: {
            Text("Se eliminarán todas las jornadas de esta tabla.")
        }
    }
}
