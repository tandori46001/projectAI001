package com.inventario.app.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.inventario.app.data.InventarioDataStore
import com.inventario.app.model.CatalogProduct

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CatalogDialog(store: InventarioDataStore, onDismiss: () -> Unit) {
    var products by remember { mutableStateOf(store.catalog.toList()) }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("Catálogo de Productos") },
                    navigationIcon = {
                        TextButton(onClick = onDismiss) { Text("Cancelar") }
                    },
                    actions = {
                        TextButton(onClick = {
                            val valid = products.filter { it.nombre.trim().isNotEmpty() }
                            if (valid.isNotEmpty()) {
                                store.catalog.clear()
                                store.catalog.addAll(valid)
                                store.saveCatalog()
                            }
                            onDismiss()
                        }) { Text("Guardar") }
                    }
                )
            }
        ) { padding ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .padding(horizontal = 16.dp)
            ) {
                // Action buttons
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    OutlinedButton(onClick = {
                        products = products.sortedBy { it.nombre.lowercase() }
                    }) { Text("A→Z", style = MaterialTheme.typography.labelSmall) }
                }

                Spacer(modifier = Modifier.height(12.dp))

                LazyColumn(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    itemsIndexed(products, key = { _, p -> p.id }) { index, product ->
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            OutlinedTextField(
                                value = product.nombre,
                                onValueChange = { v ->
                                    products = products.toMutableList().also { it[index] = product.copy(nombre = v) }
                                },
                                label = { Text("Producto") },
                                modifier = Modifier.weight(1f),
                                singleLine = true
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            OutlinedTextField(
                                value = if (product.precio == 0.0) "" else product.precio.toString(),
                                onValueChange = { v ->
                                    val precio = v.toDoubleOrNull() ?: 0.0
                                    products = products.toMutableList().also { it[index] = product.copy(precio = precio) }
                                },
                                label = { Text("Precio") },
                                modifier = Modifier.width(90.dp),
                                singleLine = true,
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
                            )
                            IconButton(onClick = {
                                products = products.toMutableList().also { it.removeAt(index) }
                            }) {
                                Icon(Icons.Default.Close, contentDescription = "Eliminar",
                                    tint = MaterialTheme.colorScheme.error)
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                TextButton(onClick = {
                    products = products + CatalogProduct()
                }) {
                    Icon(Icons.Default.Add, contentDescription = null)
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Agregar producto")
                }
            }
        }
    }
}
