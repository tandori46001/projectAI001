# PRD — Inventario Editable

**Versión:** 2.0
**Fecha:** 2026-03-20
**Archivo de implementación:** `inventario.html`

---

## 1. Resumen del Producto

Herramienta de control de inventario diario para un punto de venta de productos varios (dulces, bebidas, artículos). Permite registrar el stock inicial, las unidades vendidas y el stock final de cada producto, calculando automáticamente el importe generado y detectando discrepancias entre el conteo físico final y el esperado.

---

## 2. Problema

El encargado del punto de venta necesita llevar control diario de su inventario sin depender de hojas de cálculo externas ni conexión a internet. Actualmente el proceso es manual y propenso a errores aritméticos y de conteo.

---

## 3. Usuarios

| Perfil | Descripción |
|---|---|
| Encargado de tienda | Opera la herramienta diariamente para registrar ventas y verificar inventario |

---

## 4. Objetivos

- Registrar el inventario inicial y final de cada producto en una jornada **asociada a una fecha específica**
- Calcular automáticamente el importe vendido por producto y el total del día
- Detectar y alertar discrepancias entre el stock final físico y el calculado
- Persistir los datos entre recargas de página para no perder trabajo en curso
- **Mantener un historial de jornadas** por fecha, consultable desde la misma herramienta

---

## 5. Funcionalidades Actuales (v1.0)

### 5.1 Fecha de Jornada

- Cada sesión de inventario tiene asociada una **fecha específica** (día/mes/año)
- La fecha se muestra y es editable en la parte superior de la tabla
- Por defecto se propone la fecha actual del sistema
- La fecha forma parte de los datos guardados y es la clave del historial

### 5.2 Tabla de Inventario

| Campo | Tipo | Descripción |
|---|---|---|
| Producto | Texto editable | Nombre del producto; editable directamente en la celda |
| Inicial | Número | Unidades en stock al inicio de la jornada |
| Venta | Número | Unidades vendidas durante la jornada |
| Precio | Número | Precio unitario de venta |
| Importe | Número (solo lectura) | Calculado automáticamente: `Venta × Precio` |
| Final | Número | Stock físico contado al cierre; se contrasta con el calculado |

**Productos precargados (26):** Apazaguety, Codito, Aopa, Dulce, Trío 4, Llenita, Turrones, Zips, Primuo, Junil, Biscuit, Adria, Chupchups, Lil grand, Chambelona, Caramelo, Jabas, Whisky, Lunitita, Leche condens, Zagoth, Vino, Fosforera, Ref pagt, Bases, Gito.

### 5.3 Cálculo en Tiempo Real

- El importe por fila se recalcula automáticamente al modificar cualquier campo
- El Total Importe se actualiza de forma inmediata sin necesidad de presionar botón

### 5.4 Detalle de Importe

Muestra al pie de la tabla la lista de productos con importe mayor a cero, con su valor individual.

### 5.5 Detección de Discrepancias

- Compara `Final` (ingresado manualmente) con `Inicial - Venta` (calculado)
- Si hay diferencia, la muestra en rojo indicando el producto y la magnitud (`+N` o `-N`)
- La comparación usa redondeo a 2 decimales para evitar falsos positivos por precisión de punto flotante

### 5.6 Persistencia Local

- Los datos se guardan en `localStorage` cada vez que el usuario modifica algún campo
- Al recargar la página, los datos de la jornada activa se restauran automáticamente
- El botón **Limpiar** borra la jornada activa (con confirmación previa) y reinicia la tabla

### 5.7 Historial de Jornadas

- Al cerrar una jornada (o explícitamente con un botón **Guardar día**), los datos del día quedan registrados en el historial indexado por fecha
- El historial se almacena en `localStorage` y persiste entre sesiones
- Una sección desplegable **Historial** muestra la lista de fechas registradas, ordenadas de más reciente a más antigua
- Al seleccionar una fecha del historial se puede consultar el resumen de esa jornada (solo lectura): productos vendidos, importes, total del día y discrepancias registradas
- No se permite editar jornadas cerradas; solo consulta

**Estructura de datos del historial (localStorage):**
```json
{
  "inventario_historial": [
    {
      "fecha": "2026-03-20",
      "totalImporte": 4500.00,
      "filas": [
        { "producto": "Whisky", "inicial": 5, "venta": 2, "precio": 2000, "importe": 4000, "final": 3 },
        ...
      ]
    }
  ]
}
```

---

## 6. Flujo de Uso Típico

```
1. Abrir inventario.html en el navegador
2. Confirmar o ajustar la fecha de la jornada (por defecto: hoy)
3. Ingresar stock Inicial de cada producto al comenzar la jornada
4. Durante o al final del día, ingresar Venta de cada producto
5. Opcionalmente contar físicamente y registrar el stock Final
6. Revisar Discrepancias — investigar y corregir diferencias
7. Presionar "Guardar día" para cerrar la jornada y registrarla en el historial
8. Para consultar días anteriores, abrir la sección "Historial" y seleccionar la fecha
9. Para iniciar una nueva jornada en blanco, presionar "Limpiar"
```

---

## 7. Restricciones Técnicas

- Aplicación de archivo único (`inventario.html`) — sin dependencias externas ni servidor
- Persistencia limitada a `localStorage` del navegador — los datos no se comparten entre dispositivos ni navegadores
- Sin autenticación ni control de acceso
- Compatible con cualquier navegador moderno (Chrome, Firefox, Safari, Edge)

---

## 8. Fuera de Alcance (v1.1)

- Exportación a CSV o PDF
- Múltiples tablas o sucursales
- Sincronización en la nube
- Control de usuarios o permisos
- Vista de impresión optimizada
- Edición de jornadas ya cerradas en el historial

---

## 9. Mejoras Implementadas en v2.0

| Estado | Mejora |
|---|---|
| ✅ | Fecha de jornada con selector (default hoy) |
| ✅ | Historial de jornadas por fecha (guardar, ver, eliminar) |
| ✅ | Agregar y eliminar filas de productos dinámicamente |
| ✅ | Exportar resumen del día a CSV |
| ✅ | Vista de impresión optimizada (`@media print`) |
| ✅ | Importar/exportar configuración de productos en JSON |

## 10. Fuera de Alcance (v2.0)

- Exportación a PDF
- Soporte para múltiples tablas o sucursales
- Sincronización en la nube
- Edición de jornadas ya cerradas en el historial
