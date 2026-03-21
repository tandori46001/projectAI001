# PRD — Sistema de Control de Inventario Diario

**Versión:** 5.1
**Fecha:** 2026-03-20
**Estado:** Activo

---

## 1. Resumen del Producto

Herramienta de control de inventario diario para puntos de venta de productos varios (dulces, bebidas, artículos de consumo). Permite al encargado registrar el movimiento de stock de cada producto por jornada, calcular automáticamente los ingresos del día y detectar diferencias entre el inventario físico real y el esperado.

Disponible como **app web HTML** (archivo único, sin servidor), **app nativa iOS** (SwiftUI) y **app nativa Android** (Jetpack Compose). Todas las implementaciones comparten la misma lógica de negocio y estructura de datos.

---

## 2. Problema

Los encargados de puntos de venta llevan el control de inventario de forma manual, lo que genera:

- Errores aritméticos en el cálculo de importes y totales
- Pérdida de registros de jornadas anteriores
- Dificultad para detectar pérdidas o diferencias de stock
- Tiempo invertido en tareas repetitivas y de bajo valor

---

## 3. Usuarios

| Perfil | Rol | Necesidades principales |
|---|---|---|
| Encargado de turno | Usuario principal | Registrar ventas y stock al inicio y cierre de jornada |
| Dueño / Supervisor | Consulta | Revisar historial de jornadas y detectar irregularidades |

---

## 4. Objetivos del Producto

1. **Eliminar errores de cálculo** — los importes y totales se calculan automáticamente
2. **Agilizar el cierre de jornada** — el encargado solo registra cantidades; el sistema hace el resto
3. **Detectar diferencias de stock** — alertar cuando el conteo físico no coincide con lo esperado
4. **Mantener memoria histórica** — conservar el registro de cada jornada para consulta posterior
5. **Operar de forma autónoma** — sin necesidad de conexión a internet ni sistemas externos

---

## 5. Principios de Diseño

### KISS — Keep It Simple

Cada funcionalidad debe ser comprensible y operable sin capacitación. Si una acción requiere más de dos pasos para completarse, debe simplificarse. La herramienta debe poder ser usada por cualquier encargado de turno desde el primer día.

> Aplicación concreta: el reordenamiento de productos se hace con botones simples de subir/bajar (web) o drag-and-drop nativo (iOS). El catálogo se gestiona en un único lugar.

### YAGNI — You Aren't Gonna Need It

No se incluye ninguna funcionalidad que no tenga un uso claro e inmediato en el flujo diario del negocio. Las ideas útiles pero no urgentes se registran como candidatas futuras, no se implementan de forma anticipada.

> Aplicación concreta: no hay roles de usuario, no hay alertas automáticas, no hay integración con otros sistemas — porque ninguna de estas cosas forma parte del problema actual que se está resolviendo.

---

## 6. Conceptos Clave

| Concepto | Definición |
|---|---|
| **Jornada** | Período de operación de un día, identificado por fecha y tabla |
| **Tabla** | Unidad de inventario independiente (puede representar un turno, vendedor o sucursal) |
| **Catálogo** | Lista permanente de productos del negocio, compartida por todas las tablas |
| **Sesión actual** | Estado de trabajo en curso para una tabla (fecha + filas), auto-guardado |
| **Stock inicial** | Unidades disponibles al abrir la jornada |
| **Venta** | Unidades despachadas durante la jornada |
| **Stock esperado** | inicial - venta (calculado, no almacenado) |
| **Stock final** | Unidades contadas físicamente al cerrar la jornada (campo opcional) |
| **Discrepancia** | stockFinal - (inicial - venta). Si ≠ 0, indica pérdida o error |
| **Importe** | venta × precio (calculado en tiempo real) |
| **Total del día** | Suma de los importes de todos los productos de la jornada |

---

## 7. Arquitectura Técnica

### 7.1 Plataformas

| Plataforma | Tecnología | Archivo / Carpeta |
|---|---|---|
| Web | HTML + CSS + JavaScript vanilla (archivo único) | `inventario2.html` |
| iOS | SwiftUI + ObservableObject (iOS 17+) | `InventarioApp/` (9 archivos Swift) |
| Android | Kotlin + Jetpack Compose + Material 3 (API 26+, Android 8.0+) | `android/` (app Kotlin) |

### 7.2 Almacenamiento

Todas las plataformas usan almacenamiento local con codificación JSON:

- **Web**: `localStorage`
- **iOS**: `UserDefaults` con `JSONEncoder` / `JSONDecoder`
- **Android**: `SharedPreferences` con `Gson` / `kotlinx.serialization`

No hay servidor, no hay base de datos, no hay sincronización. Todo opera offline en el dispositivo.

### 7.3 Claves de Persistencia

| Clave | Tipo | Contenido |
|---|---|---|
| `inv2_catalog` | `[CatalogProduct]` | Array de productos del catálogo global |
| `inv2_tables` | `[String]` | Array con nombres de tablas. Default: `["Tabla 1"]` |
| `inv2_active` | `String` | Nombre de la tabla activa |
| `inv2_hist` | `[Jornada]` | Array de jornadas guardadas (historial) |
| `inv2_sessions` | `{String: SavedSession}` | Diccionario: nombre de tabla → sesión actual (fecha + filas) |
| `inv2_save_count` | `Int` | Contador de guardados (para recordatorio de backup cada 7) |

> Nota: en la versión web, las sesiones se guardan como claves individuales `inv2_cur_[nombreTabla]`. En iOS y Android se usa un diccionario único `inv2_sessions`.

---

## 8. Modelos de Datos

### 8.1 CatalogProduct

Producto del catálogo maestro global.

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | UUID | Identificador único |
| `nombre` | String | Nombre del producto |
| `precio` | Double | Precio unitario por defecto |

### 8.2 JornadaEntry

Una fila del inventario diario (un producto en una jornada).

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | UUID | Identificador único |
| `nombre` | String | Nombre del producto (snapshot, no referencia) |
| `inicial` | String | Stock al inicio del día |
| `venta` | String | Unidades vendidas |
| `precio` | String | Precio unitario (editable por jornada, pre-rellenado del catálogo) |
| `finalVal` | String | Stock final contado físicamente (opcional, puede estar vacío) |

**Propiedades computadas:**

```
importe = Double(venta) × Double(precio)

discrepancia:
  si finalVal está vacío → nil (no se calcula)
  si no → Double(finalVal) - (Double(inicial) - Double(venta))
  si resultado = 0 → nil
  si resultado ≠ 0 → valor con signo (+ sobrante, - faltante)
```

> Los campos numéricos se almacenan como String para preservar exactamente lo que el usuario escribe (vacío = no ingresado). Se convierten a Double solo para cálculos.

### 8.3 Jornada

Registro de una jornada guardada en el historial.

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | UUID | Identificador único |
| `fecha` | String | Fecha en formato `yyyy-MM-dd` |
| `tabla` | String | Nombre de la tabla a la que pertenece |
| `totalImporte` | Double | Suma de todos los importes (pre-calculado al guardar) |
| `filas` | [JornadaEntry] | Array con todas las filas de la jornada |

**Regla de unicidad:** No pueden existir dos jornadas con la misma combinación `fecha + tabla`. Al guardar, si ya existe una, se reemplaza.

**Ordenamiento:** Las jornadas se ordenan por fecha descendente, luego por tabla ascendente.

### 8.4 SavedSession

Estado de trabajo auto-guardado para cada tabla (sesión actual en progreso).

| Campo | Tipo | Descripción |
|---|---|---|
| `fecha` | String | Fecha de la jornada en curso |
| `filas` | [JornadaEntry] | Array con el estado actual de las filas |

---

## 9. Funcionalidades

### 9.1 Wizard (Configuración Inicial)

**Cuándo se muestra:** Si el catálogo está vacío (primera vez o tras borrar todos los productos).

**Comportamiento:**
- Pantalla completa que no se puede cerrar ni saltar
- Lista editable de productos con nombre y precio por fila
- Se pueden agregar, eliminar y reordenar productos
- Botón "Comenzar" guarda el catálogo y entra a la pantalla principal
- Requiere al menos un producto para continuar
- Si el catálogo ya tiene productos, el wizard no aparece

**Al completar el wizard:**
- Se guarda el catálogo en `inv2_catalog`
- Se crea la tabla por defecto "Tabla 1" si no existe
- Se genera la sesión actual con una fila por cada producto del catálogo
- Se muestra la pantalla principal con TODAS las acciones visibles

---

### 9.2 Catálogo de Productos

El catálogo es **global y compartido** por todas las tablas. Es la fuente de verdad para los productos del negocio.

**Acceso:** Desde el botón "Catálogo" en la pantalla principal (abre un modal/sheet).

**Operaciones:**
- **Agregar producto:** nueva fila con nombre y precio
- **Editar producto:** nombre y precio son editables directamente
- **Eliminar producto:** eliminación individual sin afectar el resto
- **Reordenar:** botones ▲/▼ (web) o drag-and-drop (iOS)
- **Ordenar A→Z:** ordena alfabéticamente todos los productos con un botón
- **Exportar JSON:** descarga el catálogo como `[{nombre, precio}]`
- **Importar JSON:** carga un catálogo desde archivo JSON (reemplaza el actual)

**Reglas:**
- El catálogo no puede quedar vacío (validación al guardar)
- Limpiar una jornada NO afecta al catálogo
- Cambiar un precio en el catálogo NO cambia jornadas ya guardadas
- El orden del catálogo se conserva entre sesiones

---

### 9.3 Gestión de Tablas

El sistema soporta múltiples tablas independientes. Cada tabla representa un turno, vendedor, sucursal u otra unidad.

**Operaciones:**
- **Crear tabla:** pide nombre, verifica que no exista uno igual
- **Renombrar tabla:** actualiza el nombre en tablas, sesiones y en TODAS las jornadas del historial que pertenecían a esa tabla
- **Eliminar tabla:** solo si hay más de una tabla; pide confirmación; elimina la sesión actual de esa tabla
- **Cambiar tabla:** guarda la sesión actual → carga la sesión de la nueva tabla

**Reglas:**
- Siempre debe existir al menos 1 tabla
- El catálogo es compartido entre todas las tablas
- Cada tabla tiene su propia sesión actual independiente
- El historial almacena jornadas de todas las tablas juntas

---

### 9.4 Registro de Jornada

**Pantalla principal.** Muestra una lista de productos con campos editables por cada uno.

**Campos por producto:**

| Campo | Editable | Teclado | Descripción |
|---|---|---|---|
| Producto | Solo si es ad-hoc | Texto | Nombre (readonly si viene del catálogo) |
| Inicial | Sí | Numérico | Stock al inicio del día |
| Venta | Sí | Numérico | Unidades vendidas |
| Precio | Sí | Numérico | Pre-rellenado del catálogo, ajustable |
| Importe | No (calculado) | — | venta × precio, se muestra solo si > 0 |
| Final | Sí | Numérico | Stock físico al cierre (opcional) |

**Agregar producto ad-hoc:** Botón "+ Agregar producto" añade una fila vacía para productos que no están en el catálogo.

**Eliminar fila:** Botón ✕ en cada fila para eliminarla.

**Auto-guardado:** Cada modificación en cualquier campo guarda automáticamente la sesión actual.

**Carga inicial:** Si no hay sesión guardada para la tabla activa, se genera una fila por cada producto del catálogo con precio pre-rellenado y demás campos vacíos. Fecha por defecto: hoy.

---

### 9.5 Cálculos Automáticos

Todos los cálculos se actualizan en **tiempo real** al modificar cualquier campo.

**Fórmulas:**

```
importe_producto = venta × precio
total_dia = Σ importe_producto (para todas las filas)
stock_esperado = inicial - venta (no se almacena, solo se usa para discrepancia)
discrepancia = stock_final - stock_esperado = stock_final - (inicial - venta)
```

**Redondeo:** Todos los valores monetarios se redondean a 2 decimales: `Math.round(valor * 100) / 100`

**Resumen al pie:**
- **Total Importe:** suma de todos los importes
- **Detalle Importe:** lista expandible con nombre y importe de cada producto que tiene importe > 0
- **Discrepancias:** lista expandible en rojo con productos que tienen discrepancia ≠ 0, mostrando el signo (+/-) y la magnitud

---

### 9.6 Detección de Discrepancias

- Solo se calcula si el campo "Final" tiene un valor (no vacío)
- Fórmula: `finalVal - (inicial - venta)`
- Si el resultado es 0: no hay discrepancia (no se muestra nada)
- Si > 0: "Atención: +N producto" (hay más unidades de las esperadas)
- Si < 0: "Atención: -N producto" (faltan unidades — posible pérdida)
- Se muestra en **rojo** tanto en el resumen como en el detalle de la jornada

---

### 9.7 Guardar Día

**Acción:** Botón "Guardar día" (verde, prominente).

**Proceso:**
1. Valida que la fecha no esté vacía
2. Calcula el total importe
3. Busca en el historial si ya existe una jornada con la misma `fecha + tabla`
4. Si existe: la **reemplaza** (sobreescribe)
5. Si no existe: la **inserta** al inicio del historial
6. Ordena el historial por fecha DESC, luego tabla ASC
7. Si estaba en modo edición histórica: desactiva el banner de edición
8. Incrementa el contador de guardados
9. Si el contador es múltiplo de 7: muestra recordatorio de backup
10. Muestra mensaje: "Jornada del [fecha] ([tabla]) guardada."

---

### 9.8 Historial de Jornadas

**Ubicación:** Sección en la pantalla principal (últimas 5) + vista completa accesible con botón "Historial".

**Lista de jornadas:**
- Ordenadas de más reciente a más antigua
- Cada entrada muestra: fecha (negrita), nombre de tabla (gris), total importe
- Swipe/botón para eliminar con confirmación

**Detalle de jornada (al tocar una entrada):**
- Fecha, tabla, total
- Tabla con columnas: Producto, Inicial, Venta, Precio, Importe, Final
- Detalle de importes por producto
- Discrepancias en rojo
- Botón "Editar esta jornada"

**Editar jornada histórica:**
1. Carga la fecha y todas las filas de la jornada seleccionada en la pantalla principal
2. Si la jornada pertenece a otra tabla, cambia automáticamente a esa tabla (la crea si fue eliminada)
3. Muestra un **banner de advertencia** (amarillo/naranja): "Editando jornada histórica — los cambios se guardarán al presionar Guardar día"
4. Botón "Cancelar" en el banner para abandonar la edición y volver al estado anterior
5. Al guardar: sobreescribe la jornada en el historial y desactiva el banner

**Eliminar jornada:**
- Pide confirmación: "¿Eliminar la jornada del [fecha] ([tabla]) del historial?"
- Elimina permanentemente

---

### 9.9 Limpiar

**Acción:** Botón "Limpiar" (rojo).

**Proceso:**
1. Pide confirmación
2. Restablece la fecha a hoy
3. Regenera las filas desde el catálogo (una fila por producto, con precio del catálogo, demás campos vacíos)
4. Elimina la sesión guardada para la tabla activa
5. Desactiva el banner de edición histórica si estaba activo

**Lo que NO afecta:**
- El catálogo (intacto)
- El historial de jornadas (intacto)
- Otras tablas (intactas)

---

### 9.10 Exportación de Datos

#### CSV (Hoja de cálculo)

**Formato:**
```
Tabla,Fecha,Producto,Inicial,Venta,Precio,Importe,Final
"Tabla 1",2026-03-20,"Coca Cola",10,3,1.50,4.50,7
"Tabla 1",2026-03-20,"Galletas",20,5,0.75,3.75,15

,,,,,Total,8.25,
```

- Incluye TODAS las filas (no filtra las vacías)
- El total va en una fila separada al final
- Nombre del archivo: `inventario_[tabla]_[fecha].csv`
- Se comparte vía share sheet nativo del sistema

#### PDF

**Contenido:**
- Título: "Inventario — [tabla]"
- Fecha
- Tabla con columnas: Producto, Inicial, Venta, Precio, Importe, Final
- Solo incluye filas con venta > 0 o inicial > 0 (filtra las vacías)
- Total importe al pie
- Nombre del archivo: `inventario_[tabla]_[fecha].pdf`

**Generación (iOS):** Se crea un HTML interno y se renderiza a PDF con `UIMarkupTextPrintFormatter` + `UIPrintPageRenderer`.

---

### 9.11 Recordatorio de Backup

- Cada vez que se guarda una jornada, se incrementa un contador persistente
- Cada 7 guardados, se muestra un aviso: "Recordatorio: exporta tu historial en CSV periódicamente para no perder datos"
- Opciones: "Exportar CSV ahora" o "Entendido" (cierra el aviso)
- El contador persiste entre sesiones de la app

---

## 10. Especificación de UI (iOS y Android)

### 10.1 Estructura General

Tanto iOS como Android usan un **único scroll vertical** que contiene todas las secciones. Esto es crítico para que el usuario pueda acceder a todas las funcionalidades haciendo scroll.

- **iOS**: `ScrollView` dentro de `NavigationStack`
- **Android**: `LazyColumn` dentro de `Scaffold` con `TopAppBar`

```
NavigationStack
└── ScrollView
    ├── Selector de tabla (Picker + botones Nueva/Renombrar/Eliminar)
    ├── Banner de edición histórica (condicional, amarillo)
    ├── DatePicker (fecha de la jornada)
    ├── ─── Divider ───
    ├── EntryCards (una card por producto)
    ├── Botón "+ Agregar producto"
    ├── ─── Divider ───
    ├── Resumen (total, detalle expandible, discrepancias expandibles)
    ├── ─── Divider ───
    ├── Botones de acción:
    │   ├── [Guardar día]     ← verde, ancho completo, prominente
    │   ├── [CSV] [PDF]       ← grid 2 columnas
    │   ├── [Catálogo] [Historial]
    │   └── [Limpiar]         ← rojo, ancho completo
    ├── ─── Divider ───
    └── Preview del historial (últimas 5 jornadas + "Ver todo")
```

### 10.2 EntryCard (tarjeta por producto)

Cada producto se muestra como una tarjeta con fondo gris claro y esquinas redondeadas:

```
┌─────────────────────────────────┐
│ Nombre del Producto          ✕  │
│                                 │
│ Inicial     Venta      Final    │
│ [______]   [______]   [______]  │
│                                 │
│ Precio      Importe   Discr.    │
│ [______]    123.45    -2.00     │
└─────────────────────────────────┘
```

- Nombre: texto fijo si viene del catálogo, editable si es ad-hoc
- Campos numéricos: TextField con teclado decimal
- Importe: texto no editable, solo aparece si > 0
- Discrepancia: texto rojo, solo aparece si ≠ 0

### 10.3 Modales/Sheets

- **Catálogo:** lista editable (drag-to-reorder, swipe-to-delete), botones de acción (A→Z, exportar JSON, importar JSON), guardar/cancelar
- **Historial completo:** lista de jornadas, swipe-to-delete, tap para ver detalle
- **Detalle de jornada:** tabla de datos, secciones de detalle/discrepancias, botón "Editar esta jornada"
- **Compartir archivos:**
  - iOS: `UIActivityViewController` (share sheet)
  - Android: `Intent.ACTION_SEND` con `FileProvider` (share sheet nativo)

### 10.4 Alertas / Diálogos

- Nueva tabla: campo de texto para el nombre
- Renombrar tabla: campo pre-rellenado con nombre actual
- Eliminar tabla: confirmación destructiva
- Limpiar: confirmación destructiva
- Guardar día: mensaje de éxito
- Recordatorio de backup: con opción de exportar o cerrar

**Implementación:**
- iOS: `alert()` con TextField
- Android: `AlertDialog` de Material 3 con `OutlinedTextField`

---

## 11. Flujo de Uso Típico

**En el primer uso (una sola vez):**
1. Ingresar el catálogo completo de productos con nombre y precio
2. El sistema guarda el catálogo y queda listo para operar

**Al abrir la jornada:**
1. Seleccionar la tabla correspondiente (turno, sucursal, vendedor)
2. Confirmar la fecha del día
3. Registrar el stock inicial de cada producto

**Durante la jornada:**

4. Registrar las ventas conforme ocurren, o en bloque al cierre

**Al cerrar la jornada:**

5. Contar físicamente el stock restante y registrar el stock final
6. Revisar las discrepancias y corregir lo necesario
7. Guardar la jornada en el historial
8. Exportar el reporte si se necesita
9. Limpiar la jornada para dejar lista la tabla para el día siguiente

---

## 12. Edge Cases y Reglas de Negocio

| Situación | Comportamiento |
|---|---|
| Catálogo vacío al iniciar | Se muestra el Wizard; no se puede acceder a la app principal |
| Intentar eliminar la última tabla | Botón deshabilitado; siempre debe existir al menos una |
| Guardar jornada sin fecha | Se muestra error "Indica la fecha de la jornada" |
| Guardar jornada con misma fecha+tabla que una existente | Sobreescribe la anterior sin preguntar |
| Producto con venta = 0 | Importe = 0, no aparece en detalle de importes |
| Campo Final vacío | No se calcula discrepancia; no se muestra alerta |
| Cambiar precio en el catálogo | Solo afecta nuevas jornadas; las guardadas conservan su precio |
| Editar jornada de tabla eliminada | Se recrea la tabla automáticamente |
| Cambiar de tabla | Se guarda la sesión actual antes de cargar la nueva |
| Renombrar tabla | Se actualiza en tablas, sesiones Y en todas las jornadas del historial |
| Importar JSON de catálogo inválido | Se muestra error; no se modifica el catálogo |
| Nombre de tabla duplicado | No se permite; se muestra aviso |
| Producto con nombre vacío en catálogo | Se ignora al guardar (se filtran) |

---

## 13. Restricciones Operativas

- Opera **sin conexión a internet**; no depende de ningún servicio externo
- Los datos se almacenan en el dispositivo donde se usa — no se comparten automáticamente entre equipos
- No hay autenticación ni control de acceso
- Se recomienda **exportar CSV periódicamente** como respaldo
- En iOS con Apple ID gratuito, la app instalada vía Xcode caduca a los 7 días

---

## 14. Fuera de Alcance

| Funcionalidad | Motivo |
|---|---|
| Sincronización entre dispositivos | Fuera del problema actual *(YAGNI)* |
| Control de usuarios y permisos | No existe distinción de roles en el flujo actual *(YAGNI)* |
| Alertas automáticas (correo, mensajes) | No forma parte del flujo diario del encargado *(YAGNI)* |
| Integración con facturación o contabilidad | La exportación manual cubre la necesidad actual *(YAGNI)* |
| Base de datos en la nube | El almacenamiento local cubre la necesidad *(YAGNI)* |

---

## 15. Estructura de Archivos

### 15.1 iOS (SwiftUI)

```
InventarioApp/
├── InventarioApp.swift     — @main, crea DataStore como @StateObject
├── Models.swift            — CatalogProduct, JornadaEntry, Jornada, SavedSession (Codable)
├── DataStore.swift         — ObservableObject: toda la lógica de negocio y persistencia
├── ContentView.swift       — Router: si catálogo vacío → Wizard, si no → MainView
├── WizardView.swift        — Setup inicial del catálogo
├── MainView.swift          — Pantalla principal (ScrollView con todo) + EntryCard + ShareSheet
├── CatalogSheet.swift      — Modal de gestión del catálogo
├── HistorySheet.swift      — Modal de historial + HistoryDetailView
└── Exporters.swift         — Generación de CSV y PDF
```

### 15.2 Android (Jetpack Compose + Kotlin)

```
android/app/src/main/java/com/inventario/app/
├── MainActivity.kt              — Activity única, punto de entrada
│
├── model/
│   └── Models.kt                — data classes: CatalogProduct, JornadaEntry, Jornada, SavedSession
│
├── data/
│   └── DataStore.kt             — Lógica de negocio y persistencia (SharedPreferences + Gson)
│
├── ui/
│   ├── ContentScreen.kt         — Router: wizard o main
│   ├── WizardScreen.kt          — Configuración inicial del catálogo
│   ├── MainScreen.kt            — Pantalla principal (LazyColumn con todas las secciones)
│   ├── EntryCard.kt             — Tarjeta de producto con campos editables
│   ├── CatalogDialog.kt         — Dialog fullscreen para gestión del catálogo
│   ├── HistoryDialog.kt         — Dialog fullscreen para historial + detalle
│   └── Theme.kt                 — Tema Material 3 (colores, tipografía)
│
└── export/
    └── Exporters.kt             — Generación de PDF (android.graphics.pdf.PdfDocument)
```

**Dependencias Android:**
- `androidx.compose.material3` — UI Material 3
- `androidx.compose.ui` — Framework Compose
- `androidx.activity:activity-compose` — Integration Compose con Activity
- `com.google.code.gson:gson:2.10.1` — Serialización JSON
- `androidx.core:core-ktx` — FileProvider para compartir archivos
- Compose BOM: `2024.01.00` — AGP: `8.2.2` — Kotlin: `1.9.22` — Gradle: `8.5`
- Min SDK: 26 (Android 8.0) — Target SDK: 34 (Android 14)

**Equivalencias iOS → Android:**

| Concepto | iOS (SwiftUI) | Android (Compose) |
|---|---|---|
| Estado reactivo | `@Published` + `ObservableObject` | `mutableStateOf` + `ViewModel` |
| Inyección | `@EnvironmentObject` | `CompositionLocalProvider` o `hiltViewModel()` |
| Scroll principal | `ScrollView` | `LazyColumn` |
| Modales | `.sheet()` | `ModalBottomSheet` o `Dialog` |
| Alertas con input | `.alert()` + TextField | `AlertDialog` + `OutlinedTextField` |
| Compartir archivos | `UIActivityViewController` | `Intent.ACTION_SEND` + `FileProvider` |
| Persistencia | `UserDefaults` | `SharedPreferences` |
| Navegación | `NavigationStack` | `NavHost` + `NavController` (o single-screen con sheets) |
| Selector | `Picker` | `ExposedDropdownMenuBox` |
| DatePicker | `DatePicker` | `DatePickerDialog` (Material 3) |
| Teclado numérico | `.keyboardType(.decimalPad)` | `keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)` |
| PDF | `UIMarkupTextPrintFormatter` | `android.graphics.pdf.PdfDocument` |

---

## 16. Historial de Versiones

| Versión | Capacidades incorporadas |
|---|---|
| 1.0 | Registro de inventario, cálculo de importes y detección de discrepancias |
| 1.1 | Jornadas con fecha, historial de días, guardado automático |
| 2.0 | Catálogo configurable, exportación a hoja de cálculo, impresión, importación de catálogo |
| 3.0 | Múltiples tablas, corrección de jornadas cerradas, exportación a PDF |
| 4.0 | Catálogo global único, configuración inicial guiada, eliminación individual, reordenamiento, ordenamiento alfabético. Aplicación de principios KISS y YAGNI |
| 5.0 | Especificación técnica completa: modelos de datos, claves de persistencia, arquitectura de almacenamiento, especificación de UI para iOS, edge cases documentados, estructura de archivos Swift |
| 5.1 | Plataforma Android: Jetpack Compose + Kotlin, estructura de archivos, dependencias, tabla de equivalencias iOS→Android, SharedPreferences para persistencia |
