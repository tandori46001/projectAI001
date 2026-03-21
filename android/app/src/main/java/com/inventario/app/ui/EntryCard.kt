package com.inventario.app.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.inventario.app.model.JornadaEntry

@Composable
fun EntryCard(
    entry: JornadaEntry,
    onUpdate: (JornadaEntry) -> Unit,
    onDelete: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            // Header: product name + delete
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (entry.nombre.isEmpty()) {
                    OutlinedTextField(
                        value = entry.nombre,
                        onValueChange = { onUpdate(entry.copy(nombre = it)) },
                        label = { Text("Producto") },
                        modifier = Modifier.weight(1f),
                        singleLine = true
                    )
                } else {
                    Text(
                        entry.nombre,
                        style = MaterialTheme.typography.titleSmall,
                        modifier = Modifier.weight(1f)
                    )
                }
                IconButton(onClick = onDelete, modifier = Modifier.size(32.dp)) {
                    Icon(Icons.Default.Close, contentDescription = "Eliminar",
                        tint = MaterialTheme.colorScheme.error.copy(alpha = 0.7f))
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Row 1: Inicial, Venta, Final
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                NumField("Inicial", entry.inicial, { onUpdate(entry.copy(inicial = it)) }, Modifier.weight(1f))
                NumField("Venta", entry.venta, { onUpdate(entry.copy(venta = it)) }, Modifier.weight(1f))
                NumField("Final", entry.finalVal, { onUpdate(entry.copy(finalVal = it)) }, Modifier.weight(1f))
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Row 2: Precio, Importe, Discrepancia
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                NumField("Precio", entry.precio, { onUpdate(entry.copy(precio = it)) }, Modifier.weight(1f))

                Column(modifier = Modifier.weight(1f)) {
                    Text("Importe", style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text(
                        if (entry.importe > 0) String.format("%.2f", entry.importe) else "—",
                        style = MaterialTheme.typography.titleSmall
                    )
                }

                val disc = entry.discrepancia
                if (disc != null) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Discr.", style = MaterialTheme.typography.labelSmall, color = Color(0xFFCC0000))
                        Text(
                            "${if (disc > 0) "+" else ""}${String.format("%.2f", disc)}",
                            style = MaterialTheme.typography.titleSmall,
                            color = Color(0xFFCC0000)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun NumField(
    label: String,
    value: String,
    onChange: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    OutlinedTextField(
        value = value,
        onValueChange = onChange,
        label = { Text(label) },
        modifier = modifier,
        singleLine = true,
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
    )
}
