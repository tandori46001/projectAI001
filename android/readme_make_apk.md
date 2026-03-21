# Cómo generar el APK de Inventario App

## Requisitos previos

| Herramienta | Versión mínima | Verificar con |
|---|---|---|
| Java JDK | 17 | `java -version` |
| Android SDK | API 34 (Android 14) | `ls $ANDROID_HOME/platforms/` |
| Android Build Tools | 34.0.0 | `ls $ANDROID_HOME/build-tools/` |
| Gradle | 8.5 (incluido via wrapper) | — |

### Instalar el Android SDK

**Opción A — Android Studio (recomendado para principiantes)**

1. Descargar [Android Studio](https://developer.android.com/studio)
2. Al instalar, seleccionar "Android SDK" con API 34
3. El SDK se instala por defecto en:
   - macOS: `~/Library/Android/sdk`
   - Linux: `~/Android/Sdk`
   - Windows: `%LOCALAPPDATA%\Android\Sdk`

**Opción B — Solo command-line tools (macOS con Homebrew)**

```bash
brew install --cask android-commandlinetools
# El SDK queda en: /opt/homebrew/share/android-commandlinetools

# Instalar componentes necesarios:
sdkmanager "platforms;android-34" "build-tools;34.0.0"
```

### Instalar Java 17

```bash
# macOS
brew install openjdk@17

# Linux (Ubuntu/Debian)
sudo apt install openjdk-17-jdk
```

## Configurar el SDK

Crear el archivo `local.properties` en la raíz del directorio `android/`:

```bash
cd android
echo "sdk.dir=/RUTA/A/TU/ANDROID/SDK" > local.properties
```

Ejemplos de rutas según instalación:

| Instalación | Ruta |
|---|---|
| Android Studio (macOS) | `~/Library/Android/sdk` |
| Android Studio (Linux) | `~/Android/Sdk` |
| Homebrew (macOS) | `/opt/homebrew/share/android-commandlinetools` |

> **Nota:** `local.properties` está en `.gitignore` — cada desarrollador debe crear el suyo.

## Generar el APK

### APK de debug (para pruebas)

```bash
cd android
./gradlew assembleDebug
```

El APK se genera en:
```
android/app/build/outputs/apk/debug/app-debug.apk
```

### APK de release (para distribución)

```bash
cd android
./gradlew assembleRelease
```

El APK se genera en:
```
android/app/build/outputs/apk/release/app-release-unsigned.apk
```

> **Nota:** El APK de release sale sin firmar. Para publicar en Google Play necesitas firmarlo con un keystore. Para instalación directa (sideload), el APK de debug es suficiente.

## Instalar en un teléfono

### Opción 1 — Enviar el APK por WhatsApp, email o cable USB

1. Enviar `app-debug.apk` al teléfono
2. En el teléfono: Ajustes → Seguridad → Permitir "Instalar desde fuentes desconocidas"
3. Abrir el APK y pulsar Instalar

### Opción 2 — Instalar por ADB (con cable USB)

```bash
adb install app/build/outputs/apk/debug/app-debug.apk
```

## Limpiar y reconstruir

Si tienes problemas con el build:

```bash
./gradlew clean
./gradlew assembleDebug
```

## Resumen de versiones del proyecto

- **compileSdk / targetSdk:** 34 (Android 14)
- **minSdk:** 26 (Android 8.0)
- **AGP:** 8.2.2
- **Kotlin:** 1.9.22
- **Compose BOM:** 2024.01.00
- **Gradle:** 8.5
