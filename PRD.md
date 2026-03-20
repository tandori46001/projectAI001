# PRD — Sistema de Control de Inventario Diario

**Versión:** 3.0
**Fecha:** 2026-03-20
**Estado:** Activo

---

## 1. Resumen del Producto

Herramienta de control de inventario diario para puntos de venta de productos varios (dulces, bebidas, artículos de consumo). Permite al encargado registrar el movimiento de stock de cada producto por jornada, calcular automáticamente los ingresos del día y detectar diferencias entre el inventario físico real y el esperado.

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

## 5. Conceptos Clave

| Concepto | Definición |
|---|---|
| **Jornada** | Período de operación de un día, identificado por fecha y tabla |
| **Tabla** | Unidad de inventario independiente (puede representar un turno, vendedor o sucursal) |
| **Stock inicial** | Unidades disponibles al abrir la jornada |
| **Venta** | Unidades despachadas durante la jornada |
| **Stock esperado** | Cantidad de unidades que debería quedar al cierre, calculada a partir del stock inicial y las ventas registradas |
| **Stock final** | Unidades contadas físicamente al cerrar la jornada |
| **Discrepancia** | Diferencia entre el stock final físico y el stock esperado. Indica posibles pérdidas, errores de conteo o ventas no registradas |
| **Importe** | Valor monetario generado por las ventas de un producto durante la jornada |
| **Total del día** | Suma de los importes de todos los productos de la jornada |

---

## 6. Funcionalidades

### 6.1 Gestión de Tablas

- El sistema permite operar con **múltiples tablas** independientes (ej. Tabla 1, Tabla 2, turno mañana, turno tarde)
- El encargado puede **crear, renombrar y eliminar** tablas según la organización del negocio
- Cada tabla conserva su propio inventario activo y su historial de jornadas
- El cambio de tabla guarda automáticamente el estado actual antes de cambiar

### 6.2 Registro de Jornada

- Cada jornada está asociada a una **fecha específica** (por defecto, la del día actual)
- El encargado registra para cada producto: stock inicial, unidades vendidas, precio y stock final contado
- La lista de productos es **configurable**: se pueden agregar, eliminar y renombrar productos según el catálogo del negocio
- Los cambios se guardan automáticamente mientras se trabaja, sin riesgo de perder información

### 6.3 Cálculo Automático

- El **importe** por producto se calcula automáticamente en cuanto se ingresan venta y precio
- El **total del día** se actualiza en tiempo real conforme se completan los datos
- Al pie de la jornada se muestra un **detalle** de los productos que generaron ingresos

### 6.4 Detección de Discrepancias

- Al ingresar el stock final físico, el sistema lo compara con el stock esperado
- Si hay diferencia, se muestra una **alerta** indicando el producto y la magnitud de la diferencia (positiva o negativa)
- Las discrepancias positivas indican más unidades de las esperadas; las negativas, menos (posible pérdida o venta no registrada)

### 6.5 Cierre y Guardado de Jornada

- El encargado cierra la jornada con la acción **Guardar día**
- Los datos quedan registrados en el **historial** con su fecha y nombre de tabla
- Si una jornada ya guardada necesita corregirse, puede **reabrirse para edición**; al guardar de nuevo sobreescribe el registro anterior
- La acción **Limpiar** reinicia la jornada activa sin afectar el historial

### 6.6 Historial de Jornadas

- El historial muestra todas las jornadas guardadas, ordenadas de más reciente a más antigua
- Para cada entrada se visualiza: fecha, tabla, total del día, detalle de productos e importe, y discrepancias registradas
- Las jornadas del historial pueden **consultarse, editarse o eliminarse**

### 6.7 Exportación de Datos

| Formato | Contenido | Propósito |
|---|---|---|
| **Hoja de cálculo** | Todas las filas de la jornada con tabla, fecha, producto, cantidades e importes | Análisis externo, archivo, contabilidad |
| **PDF** | Vista limpia de la jornada lista para imprimir o archivar digitalmente | Reporte impreso o archivo físico |

### 6.8 Gestión del Catálogo de Productos

#### Configuración inicial

- La **primera vez que se usa el sistema**, se presenta una pantalla de configuración donde el encargado ingresa todos los productos del negocio: nombre y precio de cada uno
- Este catálogo queda guardado de forma permanente y se reutiliza en cada nueva jornada sin necesidad de volver a ingresarlo
- Una vez completada la configuración inicial, el sistema entra directamente al registro de jornada en los usos posteriores

#### Mantenimiento del catálogo

- Los productos se conservan en el catálogo **hasta que el encargado decida eliminarlos**
- La eliminación es **individual**: se puede quitar un producto específico sin afectar al resto
- Se pueden **agregar nuevos productos** en cualquier momento; quedarán disponibles para las jornadas siguientes
- Los **precios y nombres** de cada producto son editables en cualquier momento

#### Organización del catálogo

- El encargado puede **reorganizar el orden** en que los productos aparecen en la tabla de inventario, arrastrándolos a la posición deseada
- Existe la opción de **ordenar el catálogo alfabéticamente** con una sola acción
- El orden personalizado se conserva entre jornadas

#### Exportación e importación

- El catálogo completo puede exportarse como archivo de configuración para respaldo o para replicarlo en otra tabla

---

## 7. Flujo de Uso Típico

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
6. Revisar las discrepancias detectadas e investigar las diferencias
7. Guardar la jornada en el historial
8. Exportar el reporte del día si se necesita (hoja de cálculo o PDF)
9. Limpiar la jornada para dejar lista la tabla para el día siguiente

---

## 8. Restricciones Operativas

- La herramienta opera **sin conexión a internet**; no depende de ningún servicio externo
- Los datos se almacenan en el dispositivo donde se usa — no se comparten automáticamente entre equipos
- No hay autenticación ni control de acceso; cualquier persona con acceso al dispositivo puede operar la herramienta
- Se recomienda **exportar el reporte en hoja de cálculo periódicamente** como respaldo ante pérdida accidental de datos

---

## 9. Fuera de Alcance

| Funcionalidad | Motivo de exclusión |
|---|---|
| Sincronización entre dispositivos | La herramienta es local por diseño; compartir datos requeriría una plataforma centralizada |
| Control de usuarios y permisos | No existe distinción de roles; el acceso es único por dispositivo |
| Alertas automáticas (correo, mensajes) | No se contempla comunicación activa hacia el usuario fuera de la herramienta |
| Integración con facturación o contabilidad | Se cubre mediante exportación manual de reportes |

---

## 10. Historial de Versiones

| Versión | Capacidades incorporadas |
|---|---|
| 1.0 | Registro de inventario, cálculo de importes y detección de discrepancias |
| 1.1 | Jornadas con fecha, historial de días, guardado automático |
| 2.0 | Catálogo de productos configurable, exportación a hoja de cálculo, impresión, importación de catálogo |
| 3.0 | Múltiples tablas por negocio, corrección de jornadas cerradas, exportación a PDF |
| 4.0 | Configuración inicial guiada del catálogo, eliminación individual de productos, reordenamiento manual y ordenamiento alfabético |
