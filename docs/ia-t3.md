# Declaración de uso de IA · Tarea 3

**No usé IA en esta tarea.**

Toda la implementación (clase sellada `Resultado<T>`, entidad `Pedido`, repositorio falso y pantalla con los tres estados) la escribí por mi cuenta a partir del material del deck P3 y de mi propia `Resultado<T>` entregada en la Tarea 1.

## Qué sé defender si me preguntan

- **Por qué el `switch` no necesita `default`:** `Resultado<T>` es `sealed`, el analizador conoce las tres subclases (`Cargando`, `Exito`, `Error`) y marca el `switch` como exhaustivo. Si en el futuro agregara una cuarta subclase, el compilador me obligaría a actualizar el `switch` justo porque no tiene `default`.
- **Para qué sirve `mounted` después de un `await`:** entre que empieza el `await` del repositorio y que termina, el usuario pudo cerrar la pantalla. Si llamara a `setState` sobre un `State` ya desmontado, Flutter arroja un error. `if (!mounted) return;` corta el flujo antes del `setState`.
- **Ciclo `setState → build`:** `setState` marca el `State` como dirty y encola un rebuild; Flutter llama a `build` en el próximo frame con el nuevo valor de `_estado` y el `switch` elige qué widget pintar.

## Evidencia

- `docs/evidencia-t3/estado-cargando.png` — `CircularProgressIndicator` centrado.
- `docs/evidencia-t3/estado-error.png` — ícono rojo, mensaje legible y botón **Reintentar**.
- `docs/evidencia-t3/estado-lista.png` — `ListView.builder` con 6 pedidos (cliente + producto + estado).
