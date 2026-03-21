package com.inventario.app.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.inventario.app.data.InventarioDataStore
import com.inventario.app.model.Jornada

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HistoryDialog(store: InventarioDataStore, onDismiss: () -> Unit) {
    var selectedJornada by remember { mutableStateOf<Jornada?>(null) }
    var jornadaToDelete by remember { mutableStateOf<Jornada?>(null) }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("Historial") },
                    actions = {
                        TextButton(onClick = onDismiss) { Text("Cerrar") }
                    }
                )
            }
        ) { padding ->
            if (selectedJornada != null) {
                HistoryDetail(
                    jornada = selectedJornada!!,
                    onEdit = {
                        store.editJornada(selectedJornada!!)
                        selectedJornada = null
                        onDismiss()
                    },
                    onBack = { selectedJornada = null }
                )
            } else if (store.historial.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize().padding(padding),
                    contentAlignment = Alignment.Center
                ) {
                    Text("Sin jornadas registradas.",
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize().padding(padding),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    items(store.historial.toList(), key = { it.id }) { jornada ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { selectedJornada = jornada }
                                .padding(vertical = 8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text(jornada.fecha, style = MaterialTheme.typography.bodyMedium)
                                Text(jornada.tabla, style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant)
                            }
                            Text("Total: ${String.format("%.2f", jornada.totalImporte)}",
                                style = MaterialTheme.typography.bodyMedium)
                            IconButton(onClick = { jornadaToDelete = jornada }) {
                                Icon(Icons.Default.Delete, contentDescription = "Eliminar",
                                    tint = MaterialTheme.colorScheme.error.copy(alpha = 0.7f))
                            }
                        }
                        Divider()
                    }
                }
            }
        }
    }

    jornadaToDelete?.let { j ->
        AlertDialog(
            onDismissRequest = { jornadaToDelete = null },
            title = { Text("¿Eliminar jornada?") },
            text = { Text("Se eliminará la jornada del ${j.fecha} (${j.tabla}).") },
            confirmButton = {
                TextButton(onClick = { store.deleteJornada(j); jornadaToDelete = null }) {
                    Text("Eliminar")
                }
            },
            dismissButton = {
                TextButton(onClick = { jornadaToDelete = null }) { Text("Cancelar") }
            }
        )
    }
}

@Composable
private fun HistoryDetail(jornada: Jornada, onEdit: () -> Unit, onBack: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        TextButton(onClick = onBack) { Text("← Volver") }

        Text("Jornada: ${jornada.fecha}", style = MaterialTheme.typography.titleMedium)
        Spacer(modifier = Modifier.height(8.dp))

        Row {
            Text("Tabla: ", style = MaterialTheme.typography.labelMedium)
            Text(jornada.tabla)
            Spacer(modifier = Modifier.weight(1f))
            Text("Total: ", style = MaterialTheme.typography.labelMedium)
            Text(String.format("%.2f", jornada.totalImporte))
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Detail
        val details = jornada.filas.filter { it.importe > 0 }
        if (details.isNotEmpty()) {
            Text("Detalle:", style = MaterialTheme.typography.labelMedium)
            details.forEach { e ->
                Row {
                    Text(e.nombre, style = MaterialTheme.typography.bodySmall, modifier = Modifier.weight(1f))
                    Text(String.format("%.2f", e.importe), style = MaterialTheme.typography.bodySmall)
                }
            }
            Spacer(modifier = Modifier.height(8.dp))
        }

        // Discrepancies
        val discs = jornada.filas.mapNotNull { e -> e.discrepancia?.let { e.nombre to it } }
        if (discs.isNotEmpty()) {
            Text("Discrepancias:", style = MaterialTheme.typography.labelMedium, color = Color(0xFFCC0000))
            discs.forEach { (nombre, diff) ->
                Text("Atención: ${if (diff > 0) "+" else ""}${String.format("%.2f", diff)} $nombre",
                    style = MaterialTheme.typography.bodySmall, color = Color(0xFFCC0000))
            }
            Spacer(modifier = Modifier.height(8.dp))
        }

        // Entries table
        LazyColumn(modifier = Modifier.weight(1f)) {
            items(jornada.filas, key = { it.id }) { entry ->
                Card(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
                ) {
                    Column(modifier = Modifier.padding(8.dp)) {
                        Text(entry.nombre, style = MaterialTheme.typography.titleSmall)
                        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                            Text("Ini: ${entry.inicial}", style = MaterialTheme.typography.bodySmall)
                            Text("Vta: ${entry.venta}", style = MaterialTheme.typography.bodySmall)
                            Text("Pre: ${entry.precio}", style = MaterialTheme.typography.bodySmall)
                            if (entry.importe > 0)
                                Text("Imp: ${String.format("%.2f", entry.importe)}", style = MaterialTheme.typography.bodySmall)
                            if (entry.finalVal.isNotBlank())
                                Text("Fin: ${entry.finalVal}", style = MaterialTheme.typography.bodySmall)
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        Button(
            onClick = onEdit,
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
        ) { Text("Editar esta jornada") }
    }
}
