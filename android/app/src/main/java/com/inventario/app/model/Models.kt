package com.inventario.app.model

import java.util.UUID

data class CatalogProduct(
    val id: String = UUID.randomUUID().toString(),
    val nombre: String = "",
    val precio: Double = 0.0
)

data class JornadaEntry(
    val id: String = UUID.randomUUID().toString(),
    val nombre: String = "",
    val inicial: String = "",
    val venta: String = "",
    val precio: String = "0",
    val finalVal: String = ""
) {
    val importe: Double
        get() = (venta.toDoubleOrNull() ?: 0.0) * (precio.toDoubleOrNull() ?: 0.0)

    val discrepancia: Double?
        get() {
            val f = finalVal.trim()
            if (f.isEmpty()) return null
            val finalNum = f.toDoubleOrNull() ?: return null
            val i = inicial.toDoubleOrNull() ?: 0.0
            val v = venta.toDoubleOrNull() ?: 0.0
            val diff = Math.round((finalNum - (i - v)) * 100.0) / 100.0
            return if (diff != 0.0) diff else null
        }
}

data class Jornada(
    val id: String = UUID.randomUUID().toString(),
    val fecha: String,
    val tabla: String,
    val totalImporte: Double,
    val filas: List<JornadaEntry>
)

data class SavedSession(
    val fecha: String,
    val filas: List<JornadaEntry>
)
