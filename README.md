# Inventario — Sistema de Control de Inventario Diario

Aplicación multiplataforma para gestionar el inventario diario de un negocio (restaurante, tienda, bar, etc.). Permite registrar stock inicial, ventas y stock final de cada producto, calcular importes automáticamente, detectar discrepancias y mantener un historial de jornadas.

Disponible como **app web HTML** (archivo único, sin servidor), **app iOS nativa** (SwiftUI) y **app Android nativa** (Jetpack Compose). Las tres plataformas comparten la misma lógica de negocio y estructura de datos.

---

## Funcionalidades

- **Catálogo de productos**: alta, edición, eliminación, reordenamiento, ordenar A→Z, exportar/importar JSON
- **Inventario diario**: stock inicial, ventas, stock final, precio por producto, cálculo automático de importes
- **Detección de discrepancias**: alerta cuando el conteo físico no coincide con lo esperado
- **Múltiples tablas**: crear, renombrar, eliminar tablas (turnos, sucursales, vendedores)
- **Historial de jornadas**: guardado, consulta, edición y eliminación de jornadas pasadas
- **Exportación**: CSV y PDF compartibles por WhatsApp, email, etc.
- **Auto-guardado**: la sesión se guarda automáticamente al modificar cualquier campo
- **Recordatorio de backup**: cada 7 guardados sugiere exportar datos

---

## Web

### Archivo

- `inventario.html` — aplicación completa en un solo archivo HTML (CSS + JavaScript embebidos)

### Uso

Abrir `inventario.html` directamente en cualquier navegador (Chrome, Safari, Firefox, Edge). No requiere servidor ni instalación.

Los datos se guardan en `localStorage` del navegador. Funciona completamente offline.

### Funciones adicionales (solo web)

- **Imprimir** — imprime la jornada actual directamente desde el navegador
- **Exportar/Importar catálogo JSON** — permite mover el catálogo entre dispositivos
- **Reordenar productos** — con botones ▲/▼ en el wizard y catálogo

---

## iOS

### Requisitos

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

### Arquitectura

- **SwiftUI** para la interfaz
- **ObservableObject** como capa reactiva
- **UserDefaults + JSON** para persistencia local

### Estructura

```
InventarioApp/
├── InventarioApp.swift    — @main, crea DataStore como @StateObject
├── Models.swift           — CatalogProduct, JornadaEntry, Jornada, SavedSession
├── DataStore.swift        — Lógica de negocio y persistencia (UserDefaults)
├── ContentView.swift      — Router: Wizard o MainView según estado del catálogo
├── WizardView.swift       — Configuración inicial del catálogo
├── MainView.swift         — Pantalla principal (ScrollView con todas las secciones)
├── CatalogSheet.swift     — Modal de gestión del catálogo
├── HistorySheet.swift     — Modal de historial + detalle
└── Exporters.swift        — Generación de CSV y PDF
```

### Instalación en iPhone

1. Abrir `InventarioApp.xcodeproj` en Xcode
2. Seleccionar tu iPhone como destino (necesita estar conectado por cable)
3. En Xcode: Signing & Capabilities → seleccionar tu Apple ID como equipo
4. Build & Run (Cmd+R)

> Con Apple ID gratuito, la app caduca a los 7 días y hay que reinstalar.

---

## Android

### Requisitos

- Android 8.0+ (API 26)
- Java 17
- Android SDK 34 + Build Tools 34.0.0

### Arquitectura

- **Kotlin + Jetpack Compose** para la interfaz
- **Material 3** para el diseño
- **mutableStateOf / mutableStateListOf** como capa reactiva
- **SharedPreferences + Gson** para persistencia local

### Estructura

```
android/app/src/main/java/com/inventario/app/
├── MainActivity.kt              — Activity única, punto de entrada
├── model/Models.kt              — CatalogProduct, JornadaEntry, Jornada, SavedSession
├── data/DataStore.kt            — Lógica de negocio y persistencia (SharedPreferences)
├── ui/ContentScreen.kt          — Router: Wizard o MainScreen
├── ui/WizardScreen.kt           — Configuración inicial del catálogo
├── ui/MainScreen.kt             — Pantalla principal (LazyColumn con todas las secciones)
├── ui/EntryCard.kt              — Tarjeta de producto con campos editables
├── ui/CatalogDialog.kt          — Dialog de gestión del catálogo
├── ui/HistoryDialog.kt          — Dialog de historial + detalle
├── ui/Theme.kt                  — Tema Material 3
└── export/Exporters.kt          — Generación de PDF
```

### Compilar APK

```bash
cd android

# Configurar SDK (ajustar ruta según tu sistema)
echo "sdk.dir=/path/to/android/sdk" > local.properties

# Compilar
./gradlew assembleDebug
```

El APK se genera en: `android/app/build/outputs/apk/debug/app-debug.apk`

### Instalar en teléfono Android

1. Enviar el APK por WhatsApp, email o cable USB
2. En el teléfono: Ajustes → Seguridad → Permitir "Instalar desde fuentes desconocidas"
3. Abrir el APK y pulsar Instalar

---

## Uso

1. Al abrir la app por primera vez, aparece el **Wizard** para configurar el catálogo de productos
2. Introduce los productos con su nombre y precio unitario
3. Pulsa **Comenzar** para acceder a la pantalla principal
4. Rellena los campos de inventario diario (Inicial, Venta, Final)
5. Pulsa **Guardar día** para registrar la jornada en el historial
6. Usa los botones **CSV** o **PDF** para exportar los datos

---

## Documentación

Ver [PRD.md](PRD.md) para la especificación técnica completa: modelos de datos, claves de persistencia, edge cases, flujos de UI y tabla de equivalencias iOS/Android.
