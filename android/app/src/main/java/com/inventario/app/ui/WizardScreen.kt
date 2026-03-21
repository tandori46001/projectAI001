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
import com.inventario.app.data.InventarioDataStore
import com.inventario.app.model.CatalogProduct

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WizardScreen(store: InventarioDataStore) {
    var products by remember { mutableStateOf(listOf(CatalogProduct())) }

    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Bienvenido") })
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
        ) {
            Text(
                "Configura tu catálogo de productos",
                style = MaterialTheme.typography.headlineSmall
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                "Ingresa todos los productos con su nombre y precio. Podrás editarlos en cualquier momento desde el botón Catálogo.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(modifier = Modifier.height(16.dp))

            LazyColumn(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                itemsIndexed(products, key = { _, p -> p.id }) { index, product ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.fillMaxWidth()
                    ) {
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
                            modifier = Modifier.width(100.dp),
                            singleLine = true,
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
                        )
                        IconButton(onClick = {
                            products = products.toMutableList().also { it.removeAt(index) }
                        }) {
                            Icon(Icons.Default.Close, contentDescription = "Eliminar", tint = MaterialTheme.colorScheme.error)
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

            Spacer(modifier = Modifier.height(16.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Button(
                    onClick = {
                        val valid = products.filter { it.nombre.trim().isNotEmpty() }
                        if (valid.isNotEmpty()) {
                            store.catalog.clear()
                            store.catalog.addAll(valid)
                            store.saveCatalog()
                            store.loadCurrentSession()
                        }
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
                ) {
                    Text("Comenzar")
                }
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    "Al menos un producto es necesario.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}
