import UIKit

enum Exporters {

    // MARK: - PDF Generation
    static func generatePDF(store: DataStore) -> URL? {
        let html = buildPDFHTML(store: store)

        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(fmt, startingAtPageAt: 0)

        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        let printableRect = pageRect.insetBy(dx: 28, dy: 28)
        renderer.setValue(NSValue(cgRect: pageRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()

        let filename = "inventario_\(store.activeTable)_\(store.currentFecha).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        pdfData.write(to: url, atomically: true)
        return url
    }

    // MARK: - HTML for PDF
    private static func buildPDFHTML(store: DataStore) -> String {
        let rows = store.entries
            .filter { (Double($0.venta) ?? 0) > 0 || (Double($0.inicial) ?? 0) > 0 }
            .map { e -> String in
                let imp = e.importe
                let impStr = imp > 0 ? String(format: "%.2f", imp) : ""
                return """
                <tr>
                    <td style="text-align:left">\(esc(e.nombre))</td>
                    <td>\(esc(e.inicial))</td>
                    <td>\(esc(e.venta))</td>
                    <td>\(esc(e.precio))</td>
                    <td>\(impStr)</td>
                    <td>\(esc(e.finalVal))</td>
                </tr>
                """
            }
            .joined()

        let total = String(format: "%.2f", store.totalImporte)

        return """
        <!DOCTYPE html>
        <html lang="es">
        <head><meta charset="UTF-8">
        <style>
            body { font-family: -apple-system, Helvetica, Arial, sans-serif; padding: 16px; font-size: 11px; }
            h2 { margin-bottom: 4px; font-size: 16px; }
            .meta { margin-bottom: 10px; color: #555; font-size: 11px; }
            table { border-collapse: collapse; width: 100%; }
            th, td { border: 1px solid #aaa; padding: 4px 6px; text-align: center; font-size: 10px; }
            th { background: #ddd; }
            .total { margin-top: 8px; font-weight: bold; font-size: 12px; }
        </style>
        </head>
        <body>
            <h2>Inventario — \(esc(store.activeTable))</h2>
            <p class="meta">Fecha: \(esc(store.currentFecha))</p>
            <table>
                <thead>
                    <tr><th>Producto</th><th>Inicial</th><th>Venta</th><th>Precio</th><th>Importe</th><th>Final</th></tr>
                </thead>
                <tbody>\(rows)</tbody>
            </table>
            <p class="total">Total Importe: \(total)</p>
        </body>
        </html>
        """
    }

    private static func esc(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
         .replacingOccurrences(of: "<", with: "&lt;")
         .replacingOccurrences(of: ">", with: "&gt;")
         .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
