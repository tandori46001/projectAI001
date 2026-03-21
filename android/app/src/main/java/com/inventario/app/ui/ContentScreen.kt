package com.inventario.app.ui

import androidx.compose.runtime.Composable
import com.inventario.app.data.InventarioDataStore

@Composable
fun ContentScreen(store: InventarioDataStore) {
    if (store.catalogIsEmpty) {
        WizardScreen(store = store)
    } else {
        MainScreen(store = store)
    }
}
