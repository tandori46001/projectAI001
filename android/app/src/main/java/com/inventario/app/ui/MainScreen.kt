package com.inventario.app.ui

import android.app.DatePickerDialog
import android.content.Intent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import com.inventario.app.data.InventarioDataStore
import com.inventario.app.export.Exporters
import java.io.File
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(store: InventarioDataStore) {
    val context = LocalContext.current

    // Dialog states
    var showCatalog by remember { mutableStateOf(false) }
    var showHistory by remember { mutableStateOf(false) }
    var showNewTable by remember { mutableStateOf(false) }
    var showRenameTable by remember { mutableStateOf(false) }
    var showDeleteTable by remember { mutableStateOf(false) }
    var showLimpiar by remember { mutableStateOf(false) }
    var showSaved by remember { mutableStateOf(false) }
    var savedMessage by remember { mutableStateOf("") }
    var dialogInput by remember { mutableStateOf("") }
    var tableExpanded by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Inventario") })
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            contentPadding = PaddingValues(vertical = 12.dp)
        ) {
            // ── 1. TABLE SELECTOR ──
            item {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("Tabla:", style = MaterialTheme.typography.labelLarge)
                        Spacer(modifier = Modifier.width(8.dp))
                        ExposedDropdownMenuBox(
                            expanded = tableExpanded,
                            onExpandedChange = { tableExpanded = it }
                        ) {
                            OutlinedTextField(
                                value = store.activeTable,
                                onValueChange = {},
                                readOnly = true,
                                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = tableExpanded) },
                                modifier = Modifier.menuAnchor().weight(1f),
                                singleLine = true
                            )
                            ExposedDropdownMenu(
                                expanded = tableExpanded,
                                onDismissRequest = { tableExpanded = false }
                            ) {
                                store.tables.forEach { name ->
                                    DropdownMenuItem(
                                        text = { Text(name) },
                                        onClick = {
                                            store.switchTable(name)
                                            tableExpanded = false
                                        }
                                    )
                                }
                            }
                        }
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        OutlinedButton(onClick = { dialogInput = ""; showNewTable = true }) {
                            Text("+ Nueva", style = MaterialTheme.typography.labelSmall)
                        }
                        OutlinedButton(onClick = { dialogInput = store.activeTable; showRenameTable = true }) {
                            Text("Renombrar", style = MaterialTheme.typography.labelSmall)
                        }
                        OutlinedButton(
                            onClick = { showDeleteTable = true },
                            enabled = store.tables.size > 1,
                            colors = ButtonDefaults.outlinedButtonColors(contentColor = MaterialTheme.colorScheme.error)
                        ) {
                            Text("Eliminar", style = MaterialTheme.typography.labelSmall)
                        }
                    }
                }
            }

            // ── 2. EDIT BANNER ──
            if (store.isEditingHistorical) {
                item {
                    Card(colors = CardDefaults.cardColors(containerColor = Color(0xFFFFF3CD))) {
                        Row(
                            modifier = Modifier.padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("⚠ Editando jornada histórica",
                                style = MaterialTheme.typography.bodySmall,
                                color = Color(0xFF856404),
                                modifier = Modifier.weight(1f))
                            OutlinedButton(onClick = {
                                store.cancelarEdicion()
                                store.loadCurrentSession()
                            }) {
                                Text("Cancelar", style = MaterialTheme.typography.labelSmall)
                            }
                        }
                    }
                }
            }

            // ── 3. DATE ──
            item {
                OutlinedButton(onClick = {
                    val parts = store.currentFecha.split("-").map { it.toIntOrNull() ?: 0 }
                    val y = if (parts.size >= 3) parts[0] else Calendar.getInstance().get(Calendar.YEAR)
                    val m = if (parts.size >= 3) parts[1] - 1 else Calendar.getInstance().get(Calendar.MONTH)
                    val d = if (parts.size >= 3) parts[2] else Calendar.getInstance().get(Calendar.DAY_OF_MONTH)
                    DatePickerDialog(context, { _, year, month, day ->
                        store.currentFecha = String.format("%04d-%02d-%02d", year, month + 1, day)
                        store.saveCurrentSession()
                    }, y, m, d).show()
                }) {
                    Text("Fecha: ${store.currentFecha}")
                }
            }

            item { Divider() }

            // ── 4. ENTRIES ──
            if (store.entries.isEmpty()) {
                item {
                    Text("No hay productos. Agrega uno o configura el catálogo.",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            } else {
                itemsIndexed(store.entries.toList(), key = { _, e -> e.id }) { index, entry ->
                    EntryCard(
                        entry = entry,
                        onUpdate = { updated -> store.updateEntry(index, updated) },
                        onDelete = { store.removeEntry(entry.id) }
                    )
                }
            }

            // ── 5. ADD PRODUCT ──
            item {
                TextButton(onClick = { store.addEntry() }) {
                    Icon(Icons.Default.Add, contentDescription = null)
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Agregar producto")
                }
            }

            item { Divider() }

            // ── 6. SUMMARY ──
            item {
                Column {
                    Row {
                        Text("Total Importe:", style = MaterialTheme.typography.titleMedium)
                        Spacer(modifier = Modifier.weight(1f))
                        Text(String.format("%.2f", store.totalImporte),
                            style = MaterialTheme.typography.titleMedium)
                    }

                    if (store.detalleImporte.isNotEmpty()) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("Detalle:", style = MaterialTheme.typography.labelMedium)
                        store.detalleImporte.forEach { (nombre, importe) ->
                            Row {
                                Text(nombre, style = MaterialTheme.typography.bodySmall)
                                Spacer(modifier = Modifier.weight(1f))
                                Text(String.format("%.2f", importe), style = MaterialTheme.typography.bodySmall)
                            }
                        }
                    }

                    if (store.discrepancias.isNotEmpty()) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("Discrepancias:", style = MaterialTheme.typography.labelMedium, color = Color(0xFFCC0000))
                        store.discrepancias.forEach { (nombre, diff) ->
                            Text(
                                "Atención: ${if (diff > 0) "+" else ""}${String.format("%.2f", diff)} $nombre",
                                style = MaterialTheme.typography.bodySmall,
                                color = Color(0xFFCC0000)
                            )
                        }
                    }
                }
            }

            item { Divider() }

            // ── 7. ACTIONS ──
            item {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Button(
                        onClick = {
                            val err = store.guardarDia()
                            savedMessage = err ?: "Jornada del ${store.currentFecha} (${store.activeTable}) guardada."
                            showSaved = true
                        },
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
                    ) { Text("Guardar día") }

                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        OutlinedButton(onClick = {
                            shareFile(context, store.generateCSV(),
                                "inventario_${store.activeTable}_${store.currentFecha}.csv", "text/csv")
                        }, modifier = Modifier.weight(1f)) { Text("CSV") }

                        OutlinedButton(onClick = {
                            val pdf = Exporters.generatePDF(store)
                            if (pdf != null) shareFileBytes(context, pdf,
                                "inventario_${store.activeTable}_${store.currentFecha}.pdf", "application/pdf")
                        }, modifier = Modifier.weight(1f)) { Text("PDF") }
                    }

                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        OutlinedButton(onClick = { showCatalog = true },
                            modifier = Modifier.weight(1f)) { Text("Catálogo") }
                        OutlinedButton(onClick = { showHistory = true },
                            modifier = Modifier.weight(1f)) { Text("Historial") }
                    }

                    OutlinedButton(
                        onClick = { showLimpiar = true },
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = MaterialTheme.colorScheme.error)
                    ) { Text("Limpiar") }
                }
            }

            item { Divider() }

            // ── 8. HISTORY PREVIEW ──
            item {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("Historial de jornadas", style = MaterialTheme.typography.titleSmall)
                        Spacer(modifier = Modifier.weight(1f))
                        TextButton(onClick = { showHistory = true }) { Text("Ver todo") }
                    }
                    if (store.historial.isEmpty()) {
                        Text("Sin jornadas registradas.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    } else {
                        store.historial.take(5).forEach { j ->
                            Row(modifier = Modifier.padding(vertical = 4.dp)) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(j.fecha, style = MaterialTheme.typography.bodyMedium)
                                    Text(j.tabla, style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                                }
                                Text(String.format("%.2f", j.totalImporte),
                                    style = MaterialTheme.typography.bodyMedium)
                            }
                        }
                    }
                }
            }

            item { Spacer(modifier = Modifier.height(32.dp)) }
        }
    }

    // ── DIALOGS ──
    if (showNewTable) {
        InputDialog("Nueva tabla", dialogInput, { dialogInput = it },
            onConfirm = { store.addTable(dialogInput); showNewTable = false; dialogInput = "" },
            onDismiss = { showNewTable = false })
    }
    if (showRenameTable) {
        InputDialog("Renombrar tabla", dialogInput, { dialogInput = it },
            onConfirm = { store.renameTable(dialogInput); showRenameTable = false; dialogInput = "" },
            onDismiss = { showRenameTable = false })
    }
    if (showDeleteTable) {
        ConfirmDialog("¿Eliminar tabla?",
            "Se eliminará \"${store.activeTable}\" y sus datos actuales.",
            onConfirm = { store.deleteTable(); showDeleteTable = false },
            onDismiss = { showDeleteTable = false })
    }
    if (showLimpiar) {
        ConfirmDialog("¿Limpiar?",
            "Se restablecerán los datos de la jornada actual.",
            onConfirm = { store.limpiar(); showLimpiar = false },
            onDismiss = { showLimpiar = false })
    }
    if (showSaved) {
        AlertDialog(onDismissRequest = { showSaved = false },
            confirmButton = { TextButton(onClick = { showSaved = false }) { Text("OK") } },
            text = { Text(savedMessage) })
    }
    if (store.showBackupReminder) {
        AlertDialog(
            onDismissRequest = { store.showBackupReminder = false },
            confirmButton = {
                TextButton(onClick = {
                    shareFile(context, store.generateCSV(),
                        "inventario_${store.activeTable}_${store.currentFecha}.csv", "text/csv")
                    store.showBackupReminder = false
                }) { Text("Exportar CSV") }
            },
            dismissButton = {
                TextButton(onClick = { store.showBackupReminder = false }) { Text("Entendido") }
            },
            text = { Text("Recordatorio: exporta tu historial periódicamente para no perder datos.") }
        )
    }
    if (showCatalog) {
        CatalogDialog(store = store, onDismiss = { showCatalog = false })
    }
    if (showHistory) {
        HistoryDialog(store = store, onDismiss = { showHistory = false })
    }
}

@Composable
private fun InputDialog(title: String, value: String, onValueChange: (String) -> Unit,
                        onConfirm: () -> Unit, onDismiss: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(title) },
        text = { OutlinedTextField(value = value, onValueChange = onValueChange, singleLine = true) },
        confirmButton = { TextButton(onClick = onConfirm) { Text("Aceptar") } },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Cancelar") } }
    )
}

@Composable
private fun ConfirmDialog(title: String, message: String,
                          onConfirm: () -> Unit, onDismiss: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(title) },
        text = { Text(message) },
        confirmButton = { TextButton(onClick = onConfirm) { Text("Confirmar") } },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Cancelar") } }
    )
}

private fun shareFile(context: android.content.Context, content: String, filename: String, mimeType: String) {
    val file = File(context.cacheDir, filename)
    file.writeText(content)
    val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
    val intent = Intent(Intent.ACTION_SEND).apply {
        type = mimeType
        putExtra(Intent.EXTRA_STREAM, uri)
        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }
    context.startActivity(Intent.createChooser(intent, "Compartir"))
}

private fun shareFileBytes(context: android.content.Context, bytes: ByteArray, filename: String, mimeType: String) {
    val file = File(context.cacheDir, filename)
    file.writeBytes(bytes)
    val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
    val intent = Intent(Intent.ACTION_SEND).apply {
        type = mimeType
        putExtra(Intent.EXTRA_STREAM, uri)
        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }
    context.startActivity(Intent.createChooser(intent, "Compartir"))
}
