# InventarioApp

Aplicación iOS nativa para gestionar el inventario diario de un negocio (restaurante, tienda, bar, etc.). Permite registrar stock inicial, ventas y stock final de cada producto, calcular importes automáticamente, detectar discrepancias y mantener un historial de jornadas.

## Requisitos

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

## Arquitectura

- **SwiftUI** para la interfaz
- **@Observable** (Observation framework) como capa reactiva
- **UserDefaults + JSON** para persistencia local
- **Environment** para inyección del DataStore en todas las vistas

No utiliza SwiftData, CoreData ni Combine.

## Estructura del proyecto

```
InventarioApp/
├── Models.swift          # Modelos de datos (CatalogProduct, JornadaEntry, Jornada, SavedSession)
├── DataStore.swift       # Lógica de negocio y persistencia (UserDefaults)
├── InventarioAppApp.swift # Punto de entrada de la app
├── ContentView.swift     # Router: Wizard o MainView según estado del catálogo
├── WizardView.swift      # Configuración inicial del catálogo de productos
├── MainView.swift        # Pantalla principal con todas las secciones
├── CatalogView.swift     # Gestión del catálogo (modal)
├── HistorialView.swift   # Historial de jornadas y detalle (modal)
├── ShareSheet.swift      # Exportación CSV/PDF y share sheet
└── Assets.xcassets/      # Recursos gráficos
```

## Funcionalidades

### Catálogo de productos
- Alta, edición y eliminación de productos (nombre + precio)
- Reordenamiento con drag & drop
- Ordenar alfabéticamente (A→Z)
- Exportar/importar catálogo en formato JSON

### Inventario diario
- Registro de stock inicial, ventas, stock final y precio por producto
- Cálculo automático de importe (venta × precio)
- Detección de discrepancias (final ≠ inicial - venta)
- Agregar productos ad-hoc que no están en el catálogo
- Selector de fecha

### Múltiples tablas
- Crear, renombrar y eliminar tablas (ej. "Barra", "Cocina", "Turno mañana")
- Cada tabla tiene su sesión independiente
- El catálogo es compartido entre todas las tablas

### Historial
- Guardado de jornadas con fecha, tabla y detalle completo
- Visualización de jornadas pasadas con desglose de importes y discrepancias
- Edición de jornadas históricas
- Eliminación con confirmación

### Exportación
- **CSV**: genera archivo con columnas Tabla, Fecha, Producto, Inicial, Venta, Precio, Importe, Final
- **PDF**: genera documento formateado con tabla HTML

### Auto-guardado
- La sesión actual se guarda automáticamente al modificar cualquier campo
- Recordatorio de backup cada 7 guardados

## Instalación

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/tandori46001/venti.git
   git checkout paco
   ```
2. Abrir `InventarioApp.xcodeproj` en Xcode
3. Seleccionar un simulador o dispositivo iOS 17+
4. Build & Run (⌘R)

## Uso

1. Al abrir la app por primera vez, aparece el **Wizard** para configurar el catálogo de productos
2. Introduce los productos con su nombre y precio unitario
3. Pulsa **Comenzar** para acceder a la pantalla principal
4. Rellena los campos de inventario diario (Inicial, Venta, Final)
5. Pulsa **Guardar día** para registrar la jornada en el historial
6. Usa los botones **CSV** o **PDF** para exportar los datos
