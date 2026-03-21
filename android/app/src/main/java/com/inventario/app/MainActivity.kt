package com.inventario.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.inventario.app.data.InventarioDataStore
import com.inventario.app.ui.ContentScreen
import com.inventario.app.ui.InventarioTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val store = InventarioDataStore(applicationContext)
        setContent {
            InventarioTheme {
                ContentScreen(store = store)
            }
        }
    }
}
