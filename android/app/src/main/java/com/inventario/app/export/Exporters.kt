package com.inventario.app.export

import android.graphics.Paint
import android.graphics.pdf.PdfDocument
import com.inventario.app.data.InventarioDataStore

object Exporters {

    fun generatePDF(store: InventarioDataStore): ByteArray? {
        val doc = PdfDocument()
        val pageInfo = PdfDocument.PageInfo.Builder(595, 842, 1).create() // A4
        val page = doc.startPage(pageInfo)
        val canvas = page.canvas

        val paintTitle = Paint().apply { textSize = 18f; isFakeBoldText = true }
        val paintSubtitle = Paint().apply { textSize = 11f; color = 0xFF555555.toInt() }
        val paintHeader = Paint().apply { textSize = 10f; isFakeBoldText = true }
        val paintCell = Paint().apply { textSize = 10f }
        val paintTotal = Paint().apply { textSize = 13f; isFakeBoldText = true }
        val paintLine = Paint().apply { color = 0xFFAAAAAA.toInt(); strokeWidth = 0.5f }

        var y = 40f
        val marginLeft = 28f

        // Title
        canvas.drawText("Inventario — ${store.activeTable}", marginLeft, y, paintTitle)
        y += 20f
        canvas.drawText("Fecha: ${store.currentFecha}", marginLeft, y, paintSubtitle)
        y += 24f

        // Table header
        val cols = floatArrayOf(marginLeft, 180f, 230f, 280f, 330f, 395f, 460f)
        val headers = arrayOf("Producto", "Inicial", "Venta", "Precio", "Importe", "Final")
        canvas.drawLine(marginLeft, y - 12f, 540f, y - 12f, paintLine)
        headers.forEachIndexed { i, h -> canvas.drawText(h, cols[i], y, paintHeader) }
        y += 4f
        canvas.drawLine(marginLeft, y, 540f, y, paintLine)
        y += 14f

        // Rows
        val entries = store.entries.filter {
            (it.venta.toDoubleOrNull() ?: 0.0) > 0 || (it.inicial.toDoubleOrNull() ?: 0.0) > 0
        }

        for (entry in entries) {
            if (y > 800f) break // Simple page overflow guard
            val imp = entry.importe
            val impStr = if (imp > 0) String.format("%.2f", imp) else ""
            canvas.drawText(entry.nombre, cols[0], y, paintCell)
            canvas.drawText(entry.inicial, cols[1], y, paintCell)
            canvas.drawText(entry.venta, cols[2], y, paintCell)
            canvas.drawText(entry.precio, cols[3], y, paintCell)
            canvas.drawText(impStr, cols[4], y, paintCell)
            canvas.drawText(entry.finalVal, cols[5], y, paintCell)
            y += 16f
        }

        // Total
        y += 8f
        canvas.drawLine(marginLeft, y - 6f, 540f, y - 6f, paintLine)
        canvas.drawText("Total Importe: ${String.format("%.2f", store.totalImporte)}", marginLeft, y + 8f, paintTotal)

        doc.finishPage(page)

        val out = java.io.ByteArrayOutputStream()
        doc.writeTo(out)
        doc.close()
        return out.toByteArray()
    }
}
