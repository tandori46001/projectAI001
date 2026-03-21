package com.inventario.app.data

import android.content.Context
import android.content.SharedPreferences
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.inventario.app.model.*
import java.text.SimpleDateFormat
import java.util.*

class InventarioDataStore(context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("inventario", Context.MODE_PRIVATE)
    private val gson = Gson()

    // Keys
    private val kCatalog = "inv2_catalog"
    private val kTables = "inv2_tables"
    private val kActive = "inv2_active"
    private val kHist = "inv2_hist"
    private val kSessions = "inv2_sessions"
    private val kSaveCount = "inv2_save_count"

    // State
    var catalog = mutableStateListOf<CatalogProduct>()
    var tables = mutableStateListOf<String>()
    var activeTable by mutableStateOf("")
    var currentFecha by mutableStateOf(todayString())
    var entries = mutableStateListOf<JornadaEntry>()
    var historial = mutableStateListOf<Jornada>()
    var isEditingHistorical by mutableStateOf(false)
    var showBackupReminder by mutableStateOf(false)

    private var sessions = mutableMapOf<String, SavedSession>()
    private var saveCount = 0

    val catalogIsEmpty: Boolean get() = catalog.isEmpty()

    val totalImporte: Double get() = entries.sumOf { it.importe }

    val detalleImporte: List<Pair<String, Double>>
        get() = entries.filter { it.importe > 0 }.map { it.nombre to it.importe }

    val discrepancias: List<Pair<String, Double>>
        get() = entries.mapNotNull { e -> e.discrepancia?.let { e.nombre to it } }

    init {
        loadAll()
    }

    fun loadAll() {
        catalog.clear()
        catalog.addAll(loadList(kCatalog) ?: emptyList())

        tables.clear()
        val loadedTables: List<String> = loadList(kTables) ?: listOf("Tabla 1")
        tables.addAll(if (loadedTables.isEmpty()) listOf("Tabla 1") else loadedTables)

        activeTable = prefs.getString(kActive, tables.firstOrNull() ?: "Tabla 1") ?: "Tabla 1"
        if (activeTable !in tables) activeTable = tables.firstOrNull() ?: "Tabla 1"

        historial.clear()
        historial.addAll(loadList(kHist) ?: emptyList())

        sessions = loadMap(kSessions) ?: mutableMapOf()
        saveCount = prefs.getInt(kSaveCount, 0)

        loadCurrentSession()
    }

    fun loadCurrentSession() {
        val session = sessions[activeTable]
        entries.clear()
        if (session != null) {
            currentFecha = session.fecha
            entries.addAll(session.filas)
        } else {
            currentFecha = todayString()
            entries.addAll(catalog.map { JornadaEntry(nombre = it.nombre, precio = it.precio.toString()) })
        }
    }

    fun saveCurrentSession() {
        sessions[activeTable] = SavedSession(fecha = currentFecha, filas = entries.toList())
        saveMap(sessions, kSessions)
    }

    fun saveCatalog() {
        saveList(catalog.toList(), kCatalog)
    }

    // Table management
    fun switchTable(name: String) {
        saveCurrentSession()
        activeTable = name
        prefs.edit().putString(kActive, name).apply()
        isEditingHistorical = false
        loadCurrentSession()
    }

    fun addTable(name: String): Boolean {
        val n = name.trim()
        if (n.isEmpty() || n in tables) return false
        saveCurrentSession()
        tables.add(n)
        activeTable = n
        saveTables()
        isEditingHistorical = false
        loadCurrentSession()
        return true
    }

    fun renameTable(newName: String): Boolean {
        val n = newName.trim()
        if (n.isEmpty() || n == activeTable || n in tables) return false

        sessions[n] = sessions.remove(activeTable) ?: SavedSession(todayString(), emptyList())

        val updated = historial.map { j ->
            if (j.tabla == activeTable) j.copy(tabla = n) else j
        }
        historial.clear()
        historial.addAll(updated)
        saveHistorial()

        val idx = tables.indexOf(activeTable)
        if (idx >= 0) tables[idx] = n
        activeTable = n
        saveTables()
        saveMap(sessions, kSessions)
        return true
    }

    fun deleteTable(): Boolean {
        if (tables.size <= 1) return false
        sessions.remove(activeTable)
        tables.remove(activeTable)
        activeTable = tables.firstOrNull() ?: "Tabla 1"
        saveTables()
        saveMap(sessions, kSessions)
        isEditingHistorical = false
        loadCurrentSession()
        return true
    }

    private fun saveTables() {
        saveList(tables.toList(), kTables)
        prefs.edit().putString(kActive, activeTable).apply()
    }

    // Entry management
    fun addEntry(entry: JornadaEntry = JornadaEntry()) {
        entries.add(entry)
        saveCurrentSession()
    }

    fun removeEntry(id: String) {
        entries.removeAll { it.id == id }
        saveCurrentSession()
    }

    fun updateEntry(index: Int, entry: JornadaEntry) {
        if (index in entries.indices) {
            entries[index] = entry
            saveCurrentSession()
        }
    }

    // Guardar día
    fun guardarDia(): String? {
        if (currentFecha.isEmpty()) return "Indica la fecha de la jornada."

        val total = Math.round(totalImporte * 100.0) / 100.0
        val jornada = Jornada(
            fecha = currentFecha,
            tabla = activeTable,
            totalImporte = total,
            filas = entries.toList()
        )

        historial.removeAll { it.fecha == currentFecha && it.tabla == activeTable }
        historial.add(0, jornada)
        historial.sortWith(compareByDescending<Jornada> { it.fecha }.thenBy { it.tabla })
        saveHistorial()
        isEditingHistorical = false

        saveCount++
        prefs.edit().putInt(kSaveCount, saveCount).apply()
        if (saveCount % 7 == 0) showBackupReminder = true

        return null
    }

    fun saveHistorial() {
        saveList(historial.toList(), kHist)
    }

    // History actions
    fun editJornada(jornada: Jornada) {
        saveCurrentSession()
        if (jornada.tabla != activeTable) {
            if (jornada.tabla !in tables) {
                tables.add(jornada.tabla)
                saveTables()
            }
            activeTable = jornada.tabla
            prefs.edit().putString(kActive, activeTable).apply()
        }
        currentFecha = jornada.fecha
        entries.clear()
        entries.addAll(jornada.filas)
        isEditingHistorical = true
        saveCurrentSession()
    }

    fun deleteJornada(jornada: Jornada) {
        historial.removeAll { it.id == jornada.id }
        saveHistorial()
    }

    fun cancelarEdicion() {
        isEditingHistorical = false
    }

    fun limpiar() {
        currentFecha = todayString()
        entries.clear()
        entries.addAll(catalog.map { JornadaEntry(nombre = it.nombre, precio = it.precio.toString()) })
        sessions.remove(activeTable)
        saveMap(sessions, kSessions)
        isEditingHistorical = false
    }

    // CSV
    fun generateCSV(): String {
        val sb = StringBuilder("Tabla,Fecha,Producto,Inicial,Venta,Precio,Importe,Final\n")
        for (e in entries) {
            val imp = String.format("%.2f", e.importe)
            sb.append("\"$activeTable\",$currentFecha,\"${e.nombre}\",${e.inicial},${e.venta},${e.precio},$imp,${e.finalVal}\n")
        }
        sb.append("\n,,,,,Total,${String.format("%.2f", totalImporte)},\n")
        return sb.toString()
    }

    // Helpers
    companion object {
        fun todayString(): String {
            val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
            return sdf.format(Date())
        }
    }

    private inline fun <reified T> loadList(key: String): List<T>? {
        val json = prefs.getString(key, null) ?: return null
        return try {
            gson.fromJson(json, TypeToken.getParameterized(List::class.java, T::class.java).type)
        } catch (e: Exception) { null }
    }

    private fun <T> saveList(list: List<T>, key: String) {
        prefs.edit().putString(key, gson.toJson(list)).apply()
    }

    private fun loadMap(key: String): MutableMap<String, SavedSession>? {
        val json = prefs.getString(key, null) ?: return null
        return try {
            gson.fromJson(json, object : TypeToken<MutableMap<String, SavedSession>>() {}.type)
        } catch (e: Exception) { null }
    }

    private fun saveMap(map: Map<String, SavedSession>, key: String) {
        prefs.edit().putString(key, gson.toJson(map)).apply()
    }
}
