# gestor_cafeteria

Cliente Flutter de la cafetería que gestiona pedidos contra el servicio `mini_backend`. Expone una capa `ApiClient` que traduce las respuestas HTTP del servidor a una jerarquía de fallos tipados (`Failure`) para que la UI pueda reaccionar de forma específica a cada tipo de error (sin conexión, no encontrado, conflicto, validación, error del servidor y errores no contemplados).

## Requisitos

- **Flutter** 3.x y Dart 3.x. Comprueba la versión con `flutter --version`.
- **Node.js 22.13 o superior** para levantar el `mini_backend`.
- Un emulador de Android, Chrome o un dispositivo físico para ejecutar la app.

## mini_backend

El backend se desarrolla y mantiene en un repositorio separado:

- Repositorio: <https://github.com/DMI-2026/mini_backend>
- Rama de referencia: `master`
- Versión probada en este proyecto: copia tomada el **19 de octubre de 2026** (rama `master`).

Para levantarlo:

```bash
git clone https://github.com/DMI-2026/mini_backend.git
cd mini_backend
node server.js
# -> Listening on http://0.0.0.0:8000
```

Verifica el estado con `curl http://localhost:8000/health`; debe responder `{"status":"ok"}`.

## Ejecutar la app

Desde la raíz del proyecto Flutter:

```bash
flutter pub get
```

Luego, según el objetivo:

| Entorno | Comando | API_URL por defecto |
| --- | --- | --- |
| Chrome (web dev) | `flutter run -d chrome` | `http://localhost:8000` |
| Emulador Android | `flutter run` | `http://10.0.2.2:8000` |
| Dispositivo físico | `flutter run --dart-define=API_URL=http://<IP-de-tu-PC>:8000` | el que indiques |

El valor de `API_URL` se inyecta vía `--dart-define` y lo lee `ApiClient` al construirse (`const String.fromEnvironment('API_URL')`).

## Pruebas

El proyecto incluye pruebas unitarias que no necesitan servidor (usan `MockClient` del paquete `http`):

```bash
flutter test
```

Para la salida detallada con el nombre de cada caso:

```bash
flutter test --reporter expanded
```

Las pruebas cubren:

- `test/core/failure_test.dart`: comportamiento de la jerarquía `Failure`.
- `test/core/http_client_test.dart`: 7 escenarios del `ApiClient` (éxito 200, 404, 409, 422, 503, sin conexión/timeout y el borde del rango de éxito en 300).

Análisis estático:

```bash
flutter analyze
```

## Estructura del proyecto

```
gestor_cafeteria/
├── lib/
│   ├── core/
│   │   ├── failure.dart        # Jerarquía sellada de fallos
│   │   └── http_client.dart    # ApiClient + mapeo HTTP -> Failure
│   └── main.dart               # Punto de entrada de la app
├── test/
│   └── core/
│       ├── failure_test.dart
│       └── http_client_test.dart
├── android/, ios/, web/        # Carpetas por plataforma de Flutter
├── pubspec.yaml                # Dependencias
└── README.md                   # Este archivo
```
