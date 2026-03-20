import SwiftUI

enum AppColors {
    static let primary = Color(red: 0x28 / 255, green: 0xA7 / 255, blue: 0x45 / 255)
    static let primaryDark = Color(red: 0x21 / 255, green: 0x88 / 255, blue: 0x38 / 255)
    static let danger = Color(red: 0xDC / 255, green: 0x35 / 255, blue: 0x45 / 255)
    static let dangerDark = Color(red: 0xC8 / 255, green: 0x23 / 255, blue: 0x33 / 255)
    static let warning = Color(red: 0xFF / 255, green: 0xC1 / 255, blue: 0x07 / 255)
    static let warningBackground = Color(red: 0xFF / 255, green: 0xF3 / 255, blue: 0xCD / 255)
    static let warningText = Color(red: 0x85 / 255, green: 0x64 / 255, blue: 0x04 / 255)
    static let discrepancy = Color(red: 0xCC / 255, green: 0x00 / 255, blue: 0x00 / 255)
    static let lightGray = Color(red: 0xF5 / 255, green: 0xF5 / 255, blue: 0xF5 / 255)
    static let borderGray = Color(red: 0xCC / 255, green: 0xCC / 255, blue: 0xCC / 255)
    static let mutedText = Color(red: 0x66 / 255, green: 0x66 / 255, blue: 0x66 / 255)
}

enum Strings {
    // App
    static let appTitle = "Inventario"

    // Wizard
    static let wizardTitle = "Bienvenido"
    static let wizardSubtitle = "Configura tu catálogo de productos para comenzar."
    static let wizardHint = "Agrega al menos un producto con nombre para continuar."
    static let wizardStart = "Comenzar"

    // Catalog
    static let catalog = "Catálogo"
    static let addProduct = "+ Agregar producto"
    static let sortAZ = "Ordenar A→Z"
    static let exportJSON = "Exportar JSON"
    static let importJSON = "Importar JSON"
    static let saveCatalog = "Guardar catálogo"
    static let productName = "Nombre"
    static let productPrice = "Precio"

    // Tables
    static let table = "Tabla"
    static let newTable = "+ Nueva tabla"
    static let renameTable = "Renombrar"
    static let deleteTable = "Eliminar tabla"
    static let defaultTableName = "Tabla 1"

    // Jornada
    static let date = "Fecha"
    static let initial = "Inicial"
    static let sales = "Venta"
    static let price = "Precio"
    static let amount = "Importe"
    static let finalStock = "Final"
    static let addRow = "+ Agregar"
    static let totalAmount = "Total Importe"
    static let salesDetail = "Detalle Importe"
    static let discrepancies = "Discrepancias"
    static let discrepancyWarning = "Atención"

    // Actions
    static let saveDay = "Guardar día"
    static let clear = "Limpiar"
    static let exportCSV = "Exportar CSV"
    static let exportPDF = "Exportar PDF"

    // History
    static let history = "Historial"
    static let viewEdit = "Ver / Editar"
    static let editThisDay = "Editar esta jornada"
    static let noHistory = "Sin jornadas registradas."
    static let total = "Total"

    // Edit banner
    static let editingBanner = "Editando jornada histórica"
    static let cancelEdit = "Cancelar"

    // Alerts
    static let confirm = "Confirmar"
    static let cancel = "Cancelar"
    static let delete = "Eliminar"
    static let clearConfirmTitle = "¿Limpiar la jornada actual?"
    static let clearConfirmMessage = "El catálogo e historial no se borran."
    static let deleteConfirmTitle = "¿Eliminar esta jornada del historial?"
    static let savedMessage = "Jornada guardada."
    static let done = "Listo"

    // Backup reminder
    static let backupReminder = "Recuerda exportar tus datos periódicamente como respaldo."
    static let backupDismiss = "Entendido"
}
