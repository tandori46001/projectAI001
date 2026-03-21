# SPEC-TRACKING-REVIEW — Sistema de Control de Inventario Diario

**PRD de referencia:** PRD.md v4.0
**Código de referencia:** inventario.html v3.0
**Fecha de revisión:** 2026-03-20
**Rama activa:** paco

---

## Leyenda de estados

| Símbolo | Significado |
|---|---|
| ✅ | Implementado y verificado en el código actual |
| 🔄 | Parcialmente implementado — funciona pero con limitaciones respecto al PRD |
| ⏳ | Pendiente — definido en PRD v4.0, aún no codificado |
| ❌ | Excluido explícitamente por KISS o YAGNI |

---

## Tablero de Cobertura

| Área | Total | ✅ | 🔄 | ⏳ |
|---|---|---|---|---|
| SPEC-01 Catálogo: Primera puesta en marcha | 3 | 1 | 1 | 1 |
| SPEC-02 Catálogo: Mantenimiento | 4 | 3 | 1 | 0 |
| SPEC-03 Catálogo: Organización | 3 | 0 | 0 | 3 |
| SPEC-04 Catálogo: Exportación e importación | 2 | 2 | 0 | 0 |
| SPEC-05 Gestión de Tablas | 7 | 6 | 0 | 1 |
| SPEC-06 Registro de Jornada | 4 | 4 | 0 | 0 |
| SPEC-07 Cálculo Automático | 3 | 3 | 0 | 0 |
| SPEC-08 Detección de Discrepancias | 3 | 3 | 0 | 0 |
| SPEC-09 Cierre y Guardado | 4 | 4 | 0 | 0 |
| SPEC-10 Historial de Jornadas | 5 | 5 | 0 | 0 |
| SPEC-11 Exportación de Datos | 2 | 2 | 0 | 0 |
| SPEC-12 Restricciones Operativas | 4 | 3 | 1 | 0 |
| **TOTAL** | **44** | **36** | **3** | **5** |

**Cobertura:** ✅ 82% implementado · 🔄 7% parcial · ⏳ 11% pendiente

---

## SPEC-01 — Catálogo: Primera puesta en marcha

> *PRD §7.1 — Configuración inicial*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 01-A | En el primer uso se presenta una pantalla para ingresar el catálogo completo | ⏳ | No existe pantalla guiada. El sistema carga 26 productos predefinidos sin intervención del usuario |
| 01-B | El catálogo queda guardado de forma permanente tras la configuración inicial | 🔄 | Los productos se guardan por tabla junto con los datos de la jornada, no como catálogo independiente |
| 01-C | En usos posteriores el sistema entra directamente al registro de jornada | ✅ | Si existen datos guardados, se cargan directamente sin pantalla de configuración |

**Criterios de aceptación:**
- [ ] El sistema detecta si no existe catálogo configurado y muestra la pantalla de inicio
- [ ] La pantalla de inicio permite agregar productos con nombre y precio
- [ ] El catálogo se almacena como entidad separada de la jornada activa
- [ ] Una vez configurado, la pantalla de inicio no vuelve a mostrarse salvo que el catálogo sea eliminado

---

## SPEC-02 — Catálogo: Mantenimiento

> *PRD §7.1 — Mantenimiento continuo*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 02-A | Los productos permanecen en el catálogo hasta que el encargado los elimine explícitamente | 🔄 | Los productos persisten durante la sesión activa, pero si no hay datos guardados el sistema recarga los predefinidos |
| 02-B | Eliminación individual — quitar un producto no afecta al resto | ✅ | Botón de eliminación por fila, con efecto inmediato |
| 02-C | Se pueden agregar nuevos productos en cualquier momento | ✅ | Botón para añadir nueva fila al final de la tabla |
| 02-D | El nombre y el precio de cada producto son editables en cualquier momento | ✅ | Ambos campos son editables directamente en la tabla |

**Criterios de aceptación:**
- [ ] Un producto eliminado no reaparece al abrir una nueva jornada
- [ ] Un producto agregado está disponible en todas las jornadas siguientes
- [x] La eliminación de un producto no modifica los registros históricos que lo contenían
- [ ] Editar el precio de un producto en el catálogo actualiza el valor base para jornadas futuras sin alterar el historial

---

## SPEC-03 — Catálogo: Organización

> *PRD §7.1 — Organización del catálogo*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 03-A | Reordenamiento con botones subir / bajar (▲ / ▼) | ⏳ | No implementado. Solo se puede agregar al final de la lista |
| 03-B | Ordenamiento alfabético completo con una sola acción | ⏳ | No implementado |
| 03-C | El orden personalizado se conserva entre jornadas | ⏳ | Depende de 03-A y de que exista catálogo como entidad independiente (01-B) |

**Criterios de aceptación:**
- [ ] Cada producto muestra botón ▲ (excepto el primero) y ▼ (excepto el último)
- [ ] Al pulsar ▲ el producto intercambia posición con el anterior; ▼ con el siguiente
- [ ] Existe un botón "Ordenar A→Z" que reordena todo el catálogo alfabéticamente
- [ ] El orden se mantiene al recargar la herramienta y al cambiar de jornada

---

## SPEC-04 — Catálogo: Exportación e importación

> *PRD §7.1 — Exportación*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 04-A | El catálogo puede exportarse como archivo de configuración | ✅ | Modal "Productos JSON" — exporta nombre y precio de cada producto |
| 04-B | El catálogo puede importarse para reemplazar el actual | ✅ | El modal acepta el archivo y reemplaza la lista; muestra error ante formato inválido |

**Criterios de aceptación:**
- [x] El archivo exportado contiene nombre y precio de todos los productos en el orden actual
- [x] Al importar, los productos se reemplazan por los del archivo
- [x] Un archivo con formato inválido muestra un mensaje de error y no altera el catálogo existente
- [ ] El catálogo importado persiste entre sesiones como catálogo permanente (depende de 01-B)

---

## SPEC-05 — Gestión de Tablas

> *PRD §7.2*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 05-A | El sistema permite múltiples tablas independientes | ✅ | Selector de tabla visible en la cabecera |
| 05-B | Crear nuevas tablas | ✅ | Botón "+ Nueva tabla" con solicitud de nombre |
| 05-C | Renombrar tablas existentes | ✅ | El renombrado migra los datos guardados y actualiza el historial |
| 05-D | Eliminar tablas | ✅ | Requiere confirmación; impide eliminar la última tabla existente |
| 05-E | Cada tabla conserva su propia jornada activa e historial | ✅ | Almacenamiento separado por tabla |
| 05-F | El catálogo de productos es global y compartido por todas las tablas | ⏳ | Actualmente cada tabla tiene su propia lista — no existe catálogo global único |
| 05-G | Al cambiar de tabla el estado actual se guarda automáticamente | ✅ | El guardado se ejecuta antes de cargar la nueva tabla |

**Criterios de aceptación:**
- [x] No es posible eliminar la única tabla existente
- [x] El cambio de tabla no provoca pérdida de datos de la tabla anterior
- [x] Renombrar una tabla actualiza correctamente su nombre en el historial
- [ ] Agregar un producto al catálogo lo hace disponible en todas las tablas sin excepción

---

## SPEC-06 — Registro de Jornada

> *PRD §7.3*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 06-A | Cada jornada tiene una fecha específica, por defecto la del día actual | ✅ | Selector de fecha con valor automático al abrir |
| 06-B | Registro de stock inicial, venta, precio y stock final por producto | ✅ | Los cuatro campos están disponibles por cada producto |
| 06-C | El precio se precarga desde el catálogo y es ajustable puntualmente en la jornada | ✅ | El campo precio es editable sin afectar el catálogo base |
| 06-D | Los datos se guardan automáticamente mientras se trabaja | ✅ | Cualquier modificación dispara el guardado automático |

**Criterios de aceptación:**
- [x] Al recargar la herramienta, los datos de la jornada activa se restauran sin pérdida
- [x] La fecha por defecto corresponde al día actual del dispositivo
- [x] Ajustar el precio en una jornada no modifica el precio base del catálogo

---

## SPEC-07 — Cálculo Automático

> *PRD §7.4*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 07-A | El importe por producto se calcula automáticamente al ingresar venta y precio | ✅ | Cálculo en tiempo real sin necesidad de acción adicional |
| 07-B | El total del día se actualiza en tiempo real | ✅ | Suma continua visible al pie de la tabla |
| 07-C | Se muestra un detalle de los productos que generaron ingresos | ✅ | Lista de productos con importe mayor a cero, visible bajo el total |

**Criterios de aceptación:**
- [x] Importe = Venta × Precio, actualizado ante cualquier cambio
- [x] El total refleja la suma exacta de todos los importes de la jornada
- [x] Un producto sin ventas registradas no aparece en el detalle de ingresos

---

## SPEC-08 — Detección de Discrepancias

> *PRD §7.5*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 08-A | El sistema compara el stock final ingresado con el stock esperado | ✅ | La comparación ocurre en tiempo real al escribir el stock final |
| 08-B | Se muestra una alerta con el nombre del producto y la magnitud de la diferencia | ✅ | Alerta visible en rojo con indicación del signo (+ / −) |
| 08-C | Las discrepancias positivas y negativas son distinguibles | ✅ | El signo identifica si hay más o menos stock del esperado |

**Criterios de aceptación:**
- [x] Sin stock final ingresado no se muestra ninguna alerta para ese producto
- [x] La comparación maneja correctamente valores con decimales
- [x] El mensaje identifica claramente el producto y la cantidad de diferencia
- [x] Una discrepancia de cero no genera alerta

---

## SPEC-09 — Cierre y Guardado de Jornada

> *PRD §7.6*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 09-A | "Guardar día" registra la jornada en el historial con fecha y tabla | ✅ | El registro incluye todos los datos de la jornada |
| 09-B | Una jornada guardada puede reabrirse para corrección | ✅ | Opción "Editar esta jornada" disponible desde el historial |
| 09-C | Al guardar una jornada editada, sobreescribe el registro anterior | ✅ | No se generan duplicados para la misma fecha y tabla |
| 09-D | "Limpiar" reinicia la jornada activa sin afectar el historial ni el catálogo | ✅ | Solo se elimina el estado de la jornada en curso; historial y catálogo intactos |

**Criterios de aceptación:**
- [x] Intentar guardar sin fecha asignada muestra un aviso y no procede
- [x] Guardar una jornada editada no genera un duplicado en el historial
- [x] "Limpiar" solicita confirmación antes de borrar la jornada activa
- [x] Tras limpiar, los productos del catálogo permanecen disponibles

---

## SPEC-10 — Historial de Jornadas

> *PRD §7.7*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 10-A | Lista de jornadas ordenada de más reciente a más antigua | ✅ | Orden por fecha descendente |
| 10-B | Cada entrada muestra fecha, tabla y total del día | ✅ | Visible directamente en la lista sin abrir el detalle |
| 10-C | Vista de detalle con productos, importes y discrepancias | ✅ | Modal con la tabla completa de la jornada |
| 10-D | Las jornadas del historial pueden editarse | ✅ | Al editar una jornada de otra tabla, el sistema cambia de tabla automáticamente |
| 10-E | Las jornadas del historial pueden eliminarse | ✅ | Eliminación con confirmación previa |

**Criterios de aceptación:**
- [x] El historial persiste al recargar la herramienta
- [x] Eliminar una jornada del historial no afecta la jornada activa ni el catálogo
- [x] El historial incluye jornadas de todas las tablas, identificadas por su nombre
- [x] Al editar una jornada de otra tabla se realiza el cambio de tabla de forma transparente

---

## SPEC-11 — Exportación de Datos

> *PRD §7.8*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 11-A | Exportar la jornada como hoja de cálculo | ✅ | Descarga CSV con tabla, fecha, producto, cantidades e importes; total al pie |
| 11-B | Exportar la jornada como PDF | ✅ | Ventana de impresión limpia sin controles; el usuario elige "Guardar como PDF" |

**Criterios de aceptación:**
- [x] El archivo de hoja de cálculo incluye nombre de tabla y fecha
- [x] El archivo de hoja de cálculo incluye una fila de total al pie
- [x] El nombre del archivo descargado incluye tabla y fecha
- [x] El PDF no muestra controles, botones ni elementos de navegación
- [x] El PDF es legible e imprimible sin recortes de contenido

---

## SPEC-12 — Restricciones Operativas

> *PRD §8*

| ID | Especificación | Estado | Observación |
|---|---|---|---|
| 12-A | Operación sin conexión a internet | ✅ | La herramienta es completamente local; no realiza ninguna llamada a servicios externos |
| 12-B | Datos almacenados en el dispositivo local | ✅ | Todo se guarda en el almacenamiento local del navegador |
| 12-C | Sin autenticación ni control de acceso | ✅ | Acceso libre para cualquier usuario del dispositivo |
| 12-D | Exportación periódica como mecanismo de respaldo | 🔄 | La función de exportar existe, pero no hay recordatorio ni mecanismo automático de respaldo |

**Criterios de aceptación:**
- [x] La herramienta funciona completamente sin conexión a internet
- [x] Los datos sobreviven al cierre y reapertura del navegador
- [ ] Se informa al usuario, al menos una vez, sobre la recomendación de exportar periódicamente

---

## Gap Analysis — Brechas entre PRD v4.0 e implementación v3.0

| # | Brecha | Specs afectadas | Impacto | Prioridad |
|---|---|---|---|---|
| G-01 | No existe catálogo como entidad independiente — está embebido en la jornada | 01-B, 02-A, 04-B, 05-F | Alto — es el cambio estructural central de v4.0 | Alta |
| G-02 | No hay pantalla de primera puesta en marcha | 01-A | Alto — sin ella el encargado no puede configurar su catálogo desde cero | Alta |
| G-03 | El catálogo no es compartido entre tablas | 05-F | Medio — cada tabla tiene su lista independiente, contradice el PRD | Media |
| G-04 | No hay botones ▲/▼ para reordenar productos | 03-A, 03-C | Bajo — usabilidad | Media |
| G-05 | No hay ordenamiento alfabético del catálogo | 03-B | Bajo — usabilidad | Baja |
| G-06 | No hay aviso de respaldo periódico al usuario | 12-D | Bajo — riesgo de pérdida de datos | Baja |

---

## Especificaciones Excluidas (Fuera de Alcance)

| ID | Funcionalidad excluida | Principio | Justificación |
|---|---|---|---|
| OOS-01 | Sincronización entre dispositivos | YAGNI | No forma parte del problema actual; requeriría plataforma centralizada |
| OOS-02 | Control de usuarios y permisos | YAGNI | Un operador por dispositivo es el escenario actual |
| OOS-03 | Alertas automáticas (correo, mensajes) | YAGNI | Fuera del flujo del encargado de turno |
| OOS-04 | Integración con facturación o contabilidad | YAGNI | La exportación manual cubre la necesidad actual |
| OOS-05 | Reordenamiento por arrastre (drag & drop) | KISS | Los botones ▲/▼ son suficientes y más simples de operar |

---

## Próximos Pasos — Hoja de Ruta v4.0

| Orden | Acción | Specs que cubre | Dependencias |
|---|---|---|---|
| 1 | Crear catálogo como entidad de almacenamiento independiente | G-01 → 01-B, 02-A, 05-F | Ninguna — cambio estructural base |
| 2 | Implementar pantalla de configuración inicial (primer uso) | G-02 → 01-A | Requiere paso 1 |
| 3 | Hacer el catálogo global y compartido entre todas las tablas | G-03 → 05-F | Requiere paso 1 |
| 4 | Agregar botones ▲/▼ de reordenamiento por producto | G-04 → 03-A, 03-C | Requiere paso 1 |
| 5 | Agregar botón de ordenamiento alfabético | G-05 → 03-B | Requiere paso 4 |
| 6 | Añadir mensaje de recomendación de respaldo periódico | G-06 → 12-D | Independiente |
