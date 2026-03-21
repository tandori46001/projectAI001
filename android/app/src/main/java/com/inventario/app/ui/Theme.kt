package com.inventario.app.ui

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val LightColors = lightColorScheme(
    primary = Color(0xFF28A745),
    onPrimary = Color.White,
    secondary = Color(0xFF6C757D),
    error = Color(0xFFDC3545),
    surface = Color.White,
    background = Color(0xFFF8F9FA)
)

@Composable
fun InventarioTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColors,
        content = content
    )
}
