# Attendance App

Aplicación móvil Flutter para registro de asistencia empresarial con validación de ubicación GPS. Permite a los empleados registrar su asistencia mediante autenticación con Google, validando que la ubicación sea real y precisa antes de enviar los datos a un webhook externo.

## Funcionalidad Principal

- **Autenticación**: Login exclusivo con Google para usuarios con dominio `@jasu.us`
- **Registro de asistencia**: Botón central para registrar asistencia con validaciones estrictas
- **Datos enviados**:
  - Correo electrónico del usuario autenticado
  - Fecha y hora (timestamp ISO-8601)
  - Ubicación geográfica real (latitud, longitud, precisión, velocidad, dirección)
  - Comentario opcional
  - Información del dispositivo (plataforma, versión de app, hash del device ID)
- **Envío**: POST HTTP a webhook externo (`https://n8n.jasu.us/webhook/assistance`)

## Requisitos

- Flutter SDK 3.10.7 o superior
- Cuenta de Google con dominio `@jasu.us`
- Proyecto en Firebase Console
- Android SDK configurado (para desarrollo Android)
- Xcode y CocoaPods (para desarrollo iOS)

## Configuración del Proyecto

### 4.1 Crear Proyecto en Firebase Console

1. Accede a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto
3. Desactiva Google Analytics (opcional, no es necesario para esta app)
4. Completa la creación del proyecto

### 4.2 Configuración Android

1. En Firebase Console, ve a **Agregar app** → **Android**
2. Registra la app con el `applicationId`:
   ```
   com.example.attendance_app
   ```
   **Importante**: Este ID debe coincidir exactamente con el definido en `android/app/build.gradle.kts` (línea 25) y `AndroidManifest.xml`
3. Descarga el archivo `google-services.json`
4. Coloca el archivo en:
   ```
   android/app/google-services.json
   ```
5. **Configurar SHA-1 (OBLIGATORIO)**:
   - El SHA-1 es **requerido** para que Google Sign-In funcione
   - Sin SHA-1 configurado, la app compilará pero el login fallará silenciosamente
   - Obtén el SHA-1 ejecutando:
     ```bash
     cd android
     ./gradlew signingReport
     ```
     O usando Android Studio: Gradle → Tasks → android → signingReport
   - Copia el SHA-1 (formato: `AA:BB:CC:DD:EE:...`)
   - En Firebase Console: Configuración del proyecto → Tu app Android → Agregar huella digital
   - Pega el SHA-1 y guarda
   - **Descarga nuevamente** `google-services.json` actualizado y reemplázalo
6. Verifica que `android/app/build.gradle.kts` tenga el plugin de Google Services:
   ```kotlin
   plugins {
       id("com.google.gms.google-services")
   }
   ```

### 4.3 Configuración iOS

1. En Firebase Console, ve a **Agregar app** → **iOS**
2. Registra la app con el Bundle ID que coincida con tu configuración de Xcode
3. Descarga el archivo `GoogleService-Info.plist`
4. Coloca el archivo en:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
5. Abre el proyecto en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
6. Arrastra `GoogleService-Info.plist` a la carpeta `Runner` en el navegador de proyectos de Xcode
7. Asegúrate de que el archivo esté marcado para el target "Runner"

### 4.4 Configurar Icono Personalizado

**Android:**
1. Genera los iconos en diferentes resoluciones (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
2. Reemplaza los archivos en:
   ```
   android/app/src/main/res/mipmap-*/ic_launcher.png
   ```
3. También reemplaza `ic_launcher_round.png` si usas iconos redondeados

**iOS:**
1. Genera el icono en formato PNG (1024x1024px recomendado)
2. Abre `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
3. Reemplaza los archivos de icono según las resoluciones requeridas
4. O usa un generador de iconos como [AppIcon.co](https://www.appicon.co/) que genera todos los tamaños automáticamente

**Alternativa rápida (Flutter):**
```bash
flutter pub add flutter_launcher_icons
```
Agrega configuración en `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
```
Ejecuta:
```bash
flutter pub run flutter_launcher_icons
```

### 4.5 Configurar Nombre de la Aplicación

**Android:**
1. Edita `android/app/src/main/AndroidManifest.xml`
2. Modifica el atributo `android:label` en la etiqueta `<application>`:
   ```xml
   <application
       android:label="Attendance App"
       ...>
   ```
   Este es el nombre que aparecerá debajo del icono en el launcher

**iOS:**
1. Edita `ios/Runner/Info.plist`
2. Modifica el valor de `CFBundleDisplayName`:
   ```xml
   <key>CFBundleDisplayName</key>
   <string>Attendance App</string>
   ```
   Este es el nombre que aparecerá debajo del icono en el home screen

**Nota**: El nombre puede tener un máximo de caracteres según la plataforma. Si el nombre es muy largo, puede truncarse automáticamente.

## Variables y Configuración Sensible

**IMPORTANTE**: Los siguientes archivos contienen credenciales y NO deben subirse al repositorio:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `android/app/src/main/AndroidManifest.xml` (si contiene información sensible)

Asegúrate de que `.gitignore` incluya estos archivos o usa variables de entorno para credenciales compartidas. Cada desarrollador debe usar sus propias credenciales de Firebase.

## Ejecución del Proyecto

1. Instalar dependencias:
   ```bash
   flutter pub get
   ```

2. Ejecutar la aplicación:
   ```bash
   flutter run
   ```

3. **Requisitos para registrar asistencia**:
   - GPS activado en el dispositivo
   - Permisos de ubicación precisos otorgados
   - Si el GPS está desactivado o los permisos son denegados, la app **NO enviará datos** y mostrará un mensaje de error

## Errores Comunes y Advertencias

### Login de Google no funciona
- **Causa**: SHA-1 no configurado en Firebase Console
- **Solución**: Configurar SHA-1 como se indica en la sección 4.2, punto 5
- **Síntoma**: La app compila correctamente pero el login falla sin mensaje claro

### App compila pero no autentica
- Verifica que `google-services.json` esté en `android/app/`
- Verifica que el `applicationId` en Firebase coincida con `build.gradle.kts`
- Verifica que el SHA-1 esté agregado en Firebase Console

### Ubicación en null o error de permisos
- La app requiere permisos de ubicación **precisos** (no aproximados)
- En Android 12+, el usuario debe seleccionar "Precisa" cuando se solicite el permiso
- Si los permisos son denegados permanentemente, el usuario debe ir a Configuración → Apps → Attendance App → Permisos

### Emulador vs Dispositivo Físico
- **Emulador Android**: Puede simular ubicación, pero la validación de GPS real puede fallar
- **Dispositivo físico**: Recomendado para pruebas reales de ubicación
- La app valida que la ubicación NO sea mockeada (`isMocked == false`)

### Diferencias Android e iOS
- **Android**: Requiere SHA-1 para Google Sign-In
- **iOS**: Requiere abrir el proyecto en Xcode al menos una vez para configurar correctamente
- **Permisos**: Ambos requieren permisos de ubicación precisos, pero el flujo de solicitud difiere

### Dominio de email inválido
- Solo se permiten correos con dominio `@jasu.us`
- Si intentas iniciar sesión con otro dominio, se cerrará sesión automáticamente
- El mensaje de error indicará que solo se permiten cuentas corporativas

## Notas Finales

Este proyecto está diseñado para uso empresarial con validaciones estrictas de seguridad y ubicación. Utiliza Flutter con Firebase Authentication y requiere configuración adecuada de credenciales para funcionar correctamente. No es un proyecto de ejemplo genérico y requiere configuración específica de Firebase para cada entorno de desarrollo.
