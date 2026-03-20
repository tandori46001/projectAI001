# PRD — Sistema de Control de Inventario Diario

**Versión:** 4.0
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

## 5. Principios de Diseño

### KISS — Keep It Simple

Cada funcionalidad debe ser comprensible y operable sin capacitación. Si una acción requiere más de dos pasos para completarse, debe simplificarse. La herramienta debe poder ser usada por cualquier encargado de turno desde el primer día.

> Aplicación concreta: el reordenamiento de productos se hace con botones simples de subir/bajar, no con arrastrar y soltar. El catálogo se gestiona en un único lugar, no en dos pantallas distintas.

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
| **Stock inicial** | Unidades disponibles al abrir la jornada |
| **Venta** | Unidades despachadas durante la jornada |
| **Stock esperado** | Cantidad de unidades que debería quedar al cierre, calculada a partir del stock inicial y las ventas registradas |
| **Stock final** | Unidades contadas físicamente al cerrar la jornada |
| **Discrepancia** | Diferencia entre el stock final físico y el stock esperado. Indica posibles pérdidas, errores de conteo o ventas no registradas |
| **Importe** | Valor monetario generado por las ventas de un producto durante la jornada |
| **Total del día** | Suma de los importes de todos los productos de la jornada |

---

## 7. Funcionalidades

### 7.1 Catálogo de Productos *(fuente de verdad única)*

El catálogo es **global y compartido** por todas las tablas. Se configura una sola vez y se mantiene desde un único lugar.

#### Primera puesta en marcha
- La primera vez que se abre el sistema, se presenta una pantalla de configuración donde el encargado ingresa todos los productos: nombre y precio de cada uno
- Una vez completado, el catálogo queda guardado de forma permanente
- En los usos posteriores, el sistema entra directamente al registro de jornada

#### Mantenimiento continuo
- Los productos permanecen en el catálogo hasta que el encargado decida eliminarlos
- La eliminación es **individual**: se puede quitar un producto sin afectar al resto
- Se pueden agregar nuevos productos en cualquier momento
- El nombre y precio de cada producto son editables en cualquier momento
- **Limpiar una jornada no afecta al catálogo** — el catálogo es independiente de las jornadas

#### Organización
- El encargado puede cambiar el orden de los productos usando botones de **subir / bajar** *(KISS: sin arrastrar)*
- Existe la opción de ordenar el catálogo **alfabéticamente** con una sola acción
- El orden se conserva entre jornadas

#### Exportación
- El catálogo puede exportarse como archivo de configuración para respaldo o para replicarlo en otro dispositivo

---

### 7.2 Gestión de Tablas

- El sistema permite operar con **múltiples tablas** independientes (ej. turno mañana, turno tarde, sucursal)
- El encargado puede **crear, renombrar y eliminar** tablas
- Cada tabla tiene su propia jornada activa e historial, pero **comparte el catálogo global**
- Al cambiar de tabla, el estado actual se guarda automáticamente

---

### 7.3 Registro de Jornada

- Cada jornada está asociada a una **fecha específica** (por defecto, la del día actual)
- Para cada producto del catálogo, el encargado registra: stock inicial, unidades vendidas y stock final contado
- El precio viene precargado desde el catálogo y puede ajustarse puntualmente si es necesario
- Los datos se guardan automáticamente mientras se trabaja

---

### 7.4 Cálculo Automático

- El importe por producto se calcula en cuanto se ingresan venta y precio
- El total del día se actualiza en tiempo real
- Al pie de la jornada se muestra el detalle de los productos que generaron ingresos

---

### 7.5 Detección de Discrepancias

- Al ingresar el stock final, el sistema lo compara con el stock esperado
- Si hay diferencia, se muestra una alerta con el nombre del producto y la magnitud de la diferencia
- Discrepancia positiva: más unidades de las esperadas
- Discrepancia negativa: menos unidades (posible pérdida o venta no registrada)

---

### 7.6 Cierre y Guardado de Jornada

- El encargado cierra la jornada con **Guardar día** — queda registrada en el historial con fecha y tabla
- Si necesita corregirse, la jornada puede **reabrirse para edición**; al guardar de nuevo sobreescribe el registro anterior
- **Limpiar** reinicia únicamente los datos de la jornada activa; el catálogo y el historial no se ven afectados

---

### 7.7 Historial de Jornadas

- Lista de todas las jornadas guardadas, ordenadas de más reciente a más antigua
- Cada entrada muestra: fecha, tabla, total del día, detalle por producto y discrepancias
- Las jornadas pueden **consultarse, editarse o eliminarse**

---

### 7.8 Exportación de Datos

| Formato | Contenido | Propósito |
|---|---|---|
| **Hoja de cálculo** | Jornada completa con tabla, fecha, producto, cantidades e importes | Análisis externo, archivo, contabilidad |
| **PDF** | Vista limpia lista para imprimir o archivar | Reporte impreso o archivo físico |

---

## 8. Flujo de Uso Típico

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

## 9. Restricciones Operativas

- Opera **sin conexión a internet**; no depende de ningún servicio externo
- Los datos se almacenan en el dispositivo donde se usa — no se comparten automáticamente entre equipos
- No hay autenticación ni control de acceso
- Se recomienda **exportar la hoja de cálculo periódicamente** como respaldo

---

## 10. Fuera de Alcance

| Funcionalidad | Motivo |
|---|---|
| Sincronización entre dispositivos | Fuera del problema actual *(YAGNI)* |
| Control de usuarios y permisos | No existe distinción de roles en el flujo actual *(YAGNI)* |
| Alertas automáticas (correo, mensajes) | No forma parte del flujo diario del encargado *(YAGNI)* |
| Integración con facturación o contabilidad | La exportación manual cubre la necesidad actual *(YAGNI)* |
| Arrastrar productos para reordenar | Los botones subir/bajar son suficientes y más simples *(KISS)* |

---

## 11. Historial de Versiones

| Versión | Capacidades incorporadas |
|---|---|
| 1.0 | Registro de inventario, cálculo de importes y detección de discrepancias |
| 1.1 | Jornadas con fecha, historial de días, guardado automático |
| 2.0 | Catálogo configurable, exportación a hoja de cálculo, impresión, importación de catálogo |
| 3.0 | Múltiples tablas, corrección de jornadas cerradas, exportación a PDF |
| 4.0 | Catálogo global único, configuración inicial guiada, eliminación individual, reordenamiento, ordenamiento alfabético. Aplicación de principios KISS y YAGNI |
