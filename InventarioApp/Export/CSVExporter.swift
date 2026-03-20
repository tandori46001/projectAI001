import Foundation

enum CSVExporter {
    static func export(jornada: Jornada, tableName: String) -> URL? {
        let dateStr = jornada.dateString
        let entries = (jornada.entries).sorted { $0.sortOrder < $1.sortOrder }

        var csv = "Tabla,Fecha,Producto,Inicial,Venta,Precio,Importe,Final\n"

        var total = 0.0
        for entry in entries {
            let imp = entry.importe
            total += imp
            let inicial = entry.initialStock.map { formatNum($0) } ?? ""
            let venta = entry.sales.map { formatNum($0) } ?? ""
            let precio = formatNum(entry.price)
            let importe = Fmt.currency(imp)
            let final_ = entry.finalStock.map { formatNum($0) } ?? ""

            csv += "\"\(tableName)\",\(dateStr),\"\(entry.productName)\",\(inicial),\(venta),\(precio),\(importe),\(final_)\n"
        }

        csv += "\n,,,,,Total,\(Fmt.currency(Fmt.round2(total))),\n"

        // Write to temp file with BOM for Excel compatibility
        let bom = "\u{FEFF}"
        let content = bom + csv
        let filename = "inventario_\(tableName)_\(dateStr).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private static func formatNum(_ val: Double) -> String {
        if val == val.rounded() && val < 1_000_000 {
            return String(format: "%.0f", val)
        }
        return Fmt.currency(val)
    }
}
