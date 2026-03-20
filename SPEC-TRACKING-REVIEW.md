# SPEC-TRACKING-REVIEW — Inventario Diario

**PRD de referencia:** PRD.md v4.0
**Código de referencia:** inventario.html v3.0
**Fecha de revisión:** 2026-03-20
**Rama activa:** paco

---

## Leyenda

| Símbolo | Estado |
|---|---|
| ✅ | Implementado y verificado |
| 🔄 | Parcialmente implementado |
| ⏳ | Pendiente — definido en PRD, no codificado |
| ❌ | Fuera de alcance — excluido por YAGNI/KISS |

---

## Resumen Ejecutivo

| Total specs | ✅ Implementadas | 🔄 Parciales | ⏳ Pendientes | ❌ Excluidas |
|---|---|---|---|---|
| 27 | 17 | 2 | 6 | 2 |

**Cobertura de implementación:** 63% completo · 7% parcial · 30% pendiente

---

## SPEC-01 — Catálogo de Productos: Primera puesta en marcha

**Sección PRD:** 7.1

| ID | Especificación | Estado | Notas |
|---|---|---|---|
| 01-A | En el primer uso se presenta una pantalla de configuración para ingresar productos | ⏳ | No implementado. El código carga 26 productos predefinidos (hardcoded) sin pantalla guiada |
| 01-B | El catálogo queda guardado de forma permanente tras la configuración inicial | 🔄 | El estado se guarda por tabla en localStorage, pero no como catálogo independiente — está mezclado con los datos de la jornada |
| 01-C | En usos posteriores el sistema entra directamente al registro de jornada | ✅ | Implementado: si hay datos guardados, los carga directamente |

**Criterios de aceptación:**
- [ ] El sistema detecta si es la primera vez que se usa (sin catálogo configurado)
- [ ] Se muestra una pantalla o modal de configuración inicial antes de la jornada
- [ ] El catálogo se almacena como entidad separada de la jornada activa
- [ ] Una vez configurado, no vuelve a mostrarse la pantalla de inicio

---

## SPEC-02 — Catálogo de Productos: Mantenimiento

**Sección PRD:** 7.1

| ID | Especificación | Estado | Notas |
|---|---|---|---|
| 02-A | Los productos permanecen hasta que el encargado los elimine | 🔄 | Los productos se conservan en la sesión actual, pero al limpiar o en nueva sesión sin datos guardados, se recargan los defaults |
| 02-B | Eliminación individual de productos | ✅ | El botón ✕ por fila funciona correctamente |
| 02-C | Se pueden agregar nuevos productos en cualquier momento | ✅ | Botón "+ Agregar producto" implementado |
| 02-D | Nombre y precio de cada producto son editables | ✅ | Campos editables directamente en la tabla |

**Criterios de aceptación:**
- [ ] Un producto eliminado no reaparece en la siguiente jornada
- [ ] Un producto agregado persiste en todas las jornadas futuras
- [ ] Editar el precio en el catálogo actualiza el precio base para jornadas futuras

---

## SPEC-03 — Catálogo de Productos: Organización

**Sección PRD:** 7.1

| ID | Especificación | Estado | Notas |
|---|---|---|---|
| 03-A | Reordenamiento con botones subir / bajar | ⏳ | No implementado. Actualmente solo se puede agregar al final |
| 03-B | Ordenamiento alfabético con una sola acción | ⏳ | No implementado |
| 03-C | El orden personalizado se conserva entre jornadas | ⏳ | Depende de 03-A; sin catálogo persistente no aplica aún |

**Criterios de aceptación:**
- [ ] Cada fila tiene botones ▲ / ▼ visibles
- [ ] Al pulsar ▲ el producto sube una posición; ▼ baja una posición
- [ ] El primer producto no muestra ▲; el último no muestra ▼
- [ ] El botón "Ordenar A→Z" reordena el listado completo alfabéticamente
- [ ] El orden se restaura correctamente al recargar la herramienta

---

## SPEC-04 — Catálogo de Productos: Exportación

**Sección PRD:** 7.1

| ID | Especificación | Estado | Notas |
|---|---|---|---|
| 04-A | El catálogo puede exportarse como archivo de configuración | ✅ | Implementado vía modal "Productos JSON" — exporta nombre y precio de cada producto |
| 04-B | El catálogo puede importarse desde un archivo de configuración | ✅ | El modal permite pegar y cargar un JSON con la lista de productos |

**Criterios de aceptación:**
- [x] El archivo exportado contiene nombre y precio de todos los productos
- [x] Al importar, los productos se reemplazan con los del archivo
- [x] Un JSON inválido muestra un mensaje de error claro sin romper la herramienta

---

## SPEC-05 — Gestión de Tablas

**Sección PRD:** 7.2

| ID | Especificación | Estado | Notas |
|---|---|---|---|
| 05-A | Múltiples tablas independientes | ✅ | Selector de tabla implementado |
| 05-B | Crear nuevas tablas | ✅ | Botón "+ Nueva tabla" con prompt de nombre |
| 05-C | Renombrar tablas | ✅ | Botón "Renombrar" implementado; migra datos y actualiza historial |
| 05-D | Eliminar tablas | ✅ | Botón "Eliminar tabla" con confirmación; no permite eliminar la última |
| 05-E | Cada tabla tiene su propia jornada activa e historial | ✅ | Claves de almacenamiento separadas por tabla |
| 05-F | El catálogo es compartido entre todas las tablas | ⏳ | En el código actual cada tabla tiene su propia lista de productos — no hay catálogo global único |
| 05-G | Al cambiar de tabla se guarda el estado actual | ✅ | `guardarLocal()` se llama antes de cambiar |

**Criterios de aceptación:**
- [x] No se puede eliminar la única tabla existente
- [x] Cambiar de tabla no pierde los datos de la tabla anterior
- [ ] Agregar un producto al catálogo lo hace disponible en todas las tablas

---

## SPEC-06 — Registro de Jornada

**Sección PRD:** 7.3

| ID | Especificación | Estado | Notas |
|---|---|---|---|
| 06-A | Jornada asociada a una fecha específica | ✅ | Selector de fecha con valor por defecto = hoy |
| 06-B | Registro de stock inicial, venta, precio y stock final por producto | ✅ | Todos los campos implementados |
| 06-C | El precio se precarga desde el catálogo y es ajustable puntualmente | ✅ | Campo precio editable por fila |
| 06-D | Guardado automático mientras se trabaja | ✅ | Evento `input` en la tabla dispara `guardarLocal()` |

**Criterios de aceptación:**
- [x] Al cambiar cualquier campo, los datos se guardan sin acción del usuario
- [x] Al recargar la herramienta, los datos de la jornada activa se restauran
- [x] La fecha por defecto es la del día actual

---

## SPEC-07 — Cálculo Automático

**Sección PRD:** 7.4

| ID | Especificación | Estado | Notas |
|---|---|---|---|
| 07-A | El importe por producto se calcula automáticamente | ✅ | `calcularFila()` actualiza el campo importe en tiempo real |
| 07-B | El total del día se actualiza en tiempo real | ✅ | `actualizarResumen()` suma todos los importes |
| 07-C | Detalle de productos con importe mayor a cero | ✅ | Sección "Detalle Importe" visible bajo la tabla |

**Criterios de aceptación:**
- [x] Importe = Venta × Precio, siempre actualizado
- [x] El total refleja la suma exacta de todos los importes
- [x] Productos sin venta no aparecen en el detalle

---

## SPEC-08 — Detección de Discrepancias

**Sección PRD:** 7.5

| ID | Especificación | Estado | Notas |
|---|---|---|---|
| 08-A | Comparación entre stock final ingresado y stock esperado | ✅ | Implementado en `calcularFila()` |
| 08-B | Alerta visible con nombre del producto y magnitud | ✅ | Mostrado en rojo con signo +/− |
| 08-C | Discrepancia positiva y negativa distinguibles | ✅ | El signo indica la dirección de la diferencia |

**Criterios de aceptación:**
- [x] Sin stock final ingresado, no se muestra ninguna alerta
- [x] La comparación es correcta ante valores decimales
- [x] El mensaje indica claramente el nombre del producto y la cantidad de diferencia

---

## SPEC-09 — Cierre y Guardado de Jornada

**Sección PRD:** 7.6

| ID | Especificación | Estado | Notas |
|---|---|---|---|
| 09-A | Acción "Guardar día" registra la jornada en el historial | ✅ | Implementado; incluye fecha y tabla |
| 09-B | Jornada puede reabrirse para edición | ✅ | Botón "Editar esta jornada" en el modal del historial |
| 09-C | Reeditar sobreescribe el registro anterior de la misma fecha/tabla | ✅ | `guardarDia()` filtra y reemplaza la entrada existente |
| 09-D | "Limpiar" reinicia solo la jornada activa; no afecta historial ni catálogo | ✅ | Confirmado en el código: elimina solo `keyCur(activeTable)` |

**Criterios de aceptación:**
- [x] "Guardar día" sin fecha muestra un aviso y no procede
- [x] Al editar y guardar una jornada pasada, no se duplica en el historial
- [x] "Limpiar" solicita confirmación antes de proceder
- [x] Tras limpiar, el catálogo de productos se mantiene intacto

---

## SPEC-10 — Historial de Jornadas

**Sección PRD:** 7.7

| ID | Especificación | Estado | Notas |
|---|---|---|---|
| 10-A | Lista ordenada de más reciente a más antigua | ✅ | Ordenamiento por fecha descendente |
| 10-B | Cada entrada muestra fecha, tabla y total del día | ✅ | Visible en la lista del historial |
| 10-C | Vista de detalle por producto con importes y discrepancias | ✅ | Modal con tabla completa de la jornada |
| 10-D | Editar jornadas del historial | ✅ | Botón "Editar esta jornada" en el modal |
| 10-E | Eliminar jornadas del historial | ✅ | Botón 🗑 con confirmación |

**Criterios de aceptación:**
- [x] El historial persiste al recargar la herramienta
- [x] Eliminar una jornada del historial no afecta la jornada activa
- [x] Al editar una jornada de otra tabla, el sistema cambia de tabla automáticamente

---

## SPEC-11 — Exportación de Datos

**Sección PRD:** 7.8

| ID | Especificación | Estado | Notas |
|---|---|---|---|
| 11-A | Exportar jornada como hoja de cálculo | ✅ | Exporta CSV con tabla, fecha, producto, cantidades e importes |
| 11-B | Exportar jornada como PDF | ✅ | Abre ventana de impresión limpia; el usuario guarda como PDF |

**Criterios de aceptación:**
- [x] El CSV incluye el nombre de la tabla y la fecha
- [x] El CSV incluye una fila de total al pie
- [x] El PDF muestra solo la tabla sin controles ni botones
- [x] El nombre del archivo descargado incluye tabla y fecha

---

## Brechas Identificadas (Gap Analysis)

| Gap | Specs afectadas | Impacto | Prioridad sugerida |
|---|---|---|---|
| No existe catálogo como entidad independiente — los productos están embebidos en la jornada | 01-A, 01-B, 02-A, 05-F | Alto — el catálogo global es la base de v4.0 | Alta |
| No hay pantalla de primera puesta en marcha | 01-A | Medio — los defaults hardcoded cubren el caso inicial pero no son editables antes de la primera jornada | Alta |
| No hay botones subir/bajar para reordenar productos | 03-A, 03-C | Bajo — usabilidad | Media |
| No hay ordenamiento alfabético del catálogo | 03-B | Bajo — usabilidad | Media |

---

## Especificaciones Fuera de Alcance

| ID | Especificación | Principio | Decisión |
|---|---|---|---|
| OOS-01 | Sincronización entre dispositivos | YAGNI | No incluir hasta que exista necesidad explícita |
| OOS-02 | Control de usuarios y permisos | YAGNI | Un solo operador por dispositivo es el caso actual |
| OOS-03 | Alertas automáticas (correo, mensajes) | YAGNI | Fuera del flujo diario del encargado |
| OOS-04 | Integración con facturación o contabilidad | YAGNI | La exportación CSV cubre la necesidad actual |
| OOS-05 | Arrastrar productos para reordenar (drag & drop) | KISS | Reemplazado por botones ▲/▼ |

---

## Próximos Pasos Recomendados (v4.0)

| # | Acción | Specs cubiertas |
|---|---|---|
| 1 | Separar el catálogo como entidad propia en el almacenamiento | 01-B, 02-A, 05-F |
| 2 | Implementar pantalla de configuración inicial (primer uso) | 01-A |
| 3 | Agregar botones ▲ / ▼ para reordenar productos | 03-A, 03-C |
| 4 | Agregar botón de ordenamiento alfabético | 03-B |
