import UIKit

enum PDFExporter {
    static func export(jornada: Jornada, tableName: String) -> URL? {
        let dateStr = jornada.dateString
        let entries = (jornada.entries)
            .sorted { $0.sortOrder < $1.sortOrder }
            .filter { ($0.sales ?? 0) > 0 || ($0.initialStock ?? 0) > 0 }

        let total = Fmt.round2(entries.reduce(0.0) { $0 + $1.importe })

        let pageWidth: CGFloat = 595.0  // A4
        let pageHeight: CGFloat = 842.0
        let margin: CGFloat = 40.0
        let contentWidth = pageWidth - margin * 2

        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight),
            format: format
        )

        let data = renderer.pdfData { context in
            context.beginPage()
            var y = margin

            // Title
            let titleFont = UIFont.boldSystemFont(ofSize: 18)
            let title = "Inventario — \(tableName)" as NSString
            title.draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: titleFont])
            y += 28

            // Date
            let metaFont = UIFont.systemFont(ofSize: 12)
            let metaBold = UIFont.boldSystemFont(ofSize: 12)
            let dateLabel = "Fecha: " as NSString
            dateLabel.draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: metaFont])
            let dateLabelWidth = dateLabel.size(withAttributes: [.font: metaFont]).width
            let dateVal = dateStr as NSString
            dateVal.draw(at: CGPoint(x: margin + dateLabelWidth, y: y), withAttributes: [.font: metaBold])
            y += 24

            // Table header
            let columns: [(String, CGFloat)] = [
                ("Producto", 0.30),
                ("Inicial", 0.12),
                ("Venta", 0.12),
                ("Precio", 0.14),
                ("Importe", 0.16),
                ("Final", 0.16)
            ]

            let headerFont = UIFont.boldSystemFont(ofSize: 10)
            let cellFont = UIFont.systemFont(ofSize: 10)
            let rowHeight: CGFloat = 22

            // Draw header row
            let headerBg = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1)
            headerBg.setFill()
            UIRectFill(CGRect(x: margin, y: y, width: contentWidth, height: rowHeight))

            var colX = margin
            for (headerText, widthFraction) in columns {
                let colWidth = contentWidth * widthFraction
                let text = headerText as NSString
                let textSize = text.size(withAttributes: [.font: headerFont])
                let textX = colX + (colWidth - textSize.width) / 2
                let textY = y + (rowHeight - textSize.height) / 2

                // First column left-aligned
                if headerText == "Producto" {
                    text.draw(at: CGPoint(x: colX + 4, y: textY), withAttributes: [.font: headerFont])
                } else {
                    text.draw(at: CGPoint(x: textX, y: textY), withAttributes: [.font: headerFont])
                }
                colX += colWidth
            }

            // Draw header border
            UIColor.gray.setStroke()
            let headerRect = CGRect(x: margin, y: y, width: contentWidth, height: rowHeight)
            UIRectFrame(headerRect)
            y += rowHeight

            // Draw data rows
            for entry in entries {
                if y + rowHeight > pageHeight - margin {
                    context.beginPage()
                    y = margin
                }

                let imp = entry.importe
                let rowData: [String] = [
                    entry.productName,
                    formatOpt(entry.initialStock),
                    formatOpt(entry.sales),
                    entry.price > 0 ? Fmt.currency(entry.price) : "",
                    imp > 0 ? Fmt.currency(imp) : "",
                    formatOpt(entry.finalStock)
                ]

                colX = margin
                for (i, (_, widthFraction)) in columns.enumerated() {
                    let colWidth = contentWidth * widthFraction
                    let text = rowData[i] as NSString
                    let textSize = text.size(withAttributes: [.font: cellFont])
                    let textY = y + (rowHeight - textSize.height) / 2

                    if i == 0 {
                        // Left-aligned
                        text.draw(at: CGPoint(x: colX + 4, y: textY), withAttributes: [.font: cellFont])
                    } else {
                        // Center-aligned
                        let textX = colX + (colWidth - textSize.width) / 2
                        text.draw(at: CGPoint(x: textX, y: textY), withAttributes: [.font: cellFont])
                    }
                    colX += colWidth
                }

                // Row border
                UIColor.lightGray.setStroke()
                let rowRect = CGRect(x: margin, y: y, width: contentWidth, height: rowHeight)
                UIRectFrame(rowRect)
                y += rowHeight
            }

            y += 16

            // Total
            let totalFont = UIFont.boldSystemFont(ofSize: 14)
            let totalText = "Total Importe: \(Fmt.currency(total))" as NSString
            totalText.draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: totalFont])
        }

        // Save to temp file
        let filename = "inventario_\(tableName)_\(dateStr).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private static func formatOpt(_ val: Double?) -> String {
        guard let val else { return "" }
        if val == val.rounded() && val < 1_000_000 {
            return String(format: "%.0f", val)
        }
        return Fmt.currency(val)
    }
}
