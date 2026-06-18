# 🚀 Pasos para completar la configuración

## ✅ Checklist de configuración

### Paso 1: Instalar dependencias (2 min)
```bash
flutter pub get
```
**Estado**: ⏳ Pendiente

### Paso 2: Crear proyecto en Firebase (5 min)
1. Ve a https://console.firebase.google.com/
2. Crea un nuevo proyecto: `cajatacna-movil-project`
3. Habilita Google Analytics (opcional)

**Estado**: ⏳ Pendiente

### Paso 3: Configurar autenticación (3 min)
1. En Firebase Console → **Authentication**
2. Haz clic en **Get started**
3. Habilita: **Email/Password**

**Estado**: ⏳ Pendiente

### Paso 4: Crear Firestore Database (3 min)
1. En Firebase Console → **Firestore Database**
2. Clic en **Create database**
3. Selecciona: **Start in test mode**
4. Elige la región más cercana
5. Crea la base de datos

**Estado**: ⏳ Pendiente

### Paso 5: Generar configuración (2 min) - OPCIÓN A (RECOMENDADA)
```bash
# Instala FlutterFire CLI
dart pub global activate flutterfire_cli

# Genera la configuración automáticamente
flutterfire configure --project=cajatacna-movil-project
```

**Estado**: ⏳ Pendiente

### Paso 5 ALTERNATIVA (MANUAL) - OPCIÓN B
1. En Firebase Console → **Project Settings**
2. Copia las credenciales para cada plataforma
3. Actualiza `lib/firebase_options.dart` con tus valores reales

**Estado**: ⏳ Pendiente

### Paso 6: Ejecutar la aplicación (1 min)
```bash
# Asegúrate de tener un emulador o dispositivo conectado
flutter run
```

**Estado**: ⏳ Pendiente

## 📋 Verificación final

- [ ] Firebase está creado
- [ ] Autenticación habilitada
- [ ] Firestore Database creada en test mode
- [ ] firebase_options.dart está configurado
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Aplicación se ejecuta sin errores
- [ ] Puedes registrarte e iniciar sesión
- [ ] Puedes hacer depósitos y retiros

## 🔧 Archivos clave ya creados

✅ `lib/main.dart` - Punto de entrada con autenticación
✅ `lib/services/firebase_service.dart` - Servicio de Firebase
✅ `lib/models/user_model.dart` - Modelo de usuario
✅ `lib/models/transaction_model.dart` - Modelo de transacción
✅ `lib/screens/auth_screen.dart` - Pantalla de login/registro
✅ `lib/screens/home_screen.dart` - Pantalla principal
✅ `lib/screens/transactions_screen.dart` - Historial
✅ `lib/screens/profile_screen.dart` - Perfil
✅ `pubspec.yaml` - Dependencias actualizadas

## 📦 Dependencias instaladas

- firebase_core: ^3.3.0
- firebase_auth: ^5.1.4
- cloud_firestore: ^5.2.1
- provider: ^6.4.1

## 🧪 Prueba rápida después de la configuración

### 1. Registrarse
- Email: `test@example.com`
- Contraseña: `123456`
- Nombre: `Juan Pérez`

### 2. Iniciar sesión
Usa las mismas credenciales

### 3. Probar operaciones
- Haz un depósito: S/. 500
- Haz un retiro: S/. 100
- Visualiza el historial
- Revisa tu perfil

## ⚠️ Errores comunes y soluciones

### Error: "Target of URI doesn't exist"
**Causa**: Dependencias no instaladas
**Solución**:
```bash
flutter clean
flutter pub get
flutter run
```

### Error: "FirebaseException: [core/no-app]"
**Causa**: Firebase no está configurado correctamente
**Solución**: Verifica `firebase_options.dart` con tus credenciales reales

### Error: "Permission denied" en Firestore
**Causa**: Reglas de seguridad incorrectas
**Solución**: Asegúrate de estar en **test mode** o actualiza las reglas

### Error: "Authentication not configured"
**Causa**: Email/Password no habilitado en Firebase
**Solución**: Ve a Authentication → Sign-in method → Email/Password → Enable

## 💡 Tips útiles

1. **Usar el emulador de Firebase** (opcional pero recomendado):
```bash
firebase emulators:start
```

2. **Ver logs en tiempo real**:
```bash
flutter run -v
```

3. **Hot reload durante desarrollo**:
- Presiona `r` en la terminal para recargar
- Presiona `R` para reiniciar completamente

4. **Limpiar datos locales**:
```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
```

## 📞 Recursos de ayuda

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire Docs](https://firebase.flutter.dev/)
- [Flutter Docs](https://flutter.dev/docs)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)

## ✨ ¡Próximo paso!

Cuando hayas completado todos los pasos, tu aplicación CAJATACNA Móvil estará lista para:

1. ✅ Registrarse nuevos usuarios
2. ✅ Iniciar sesión seguro
3. ✅ Hacer depósitos
4. ✅ Hacer retiros
5. ✅ Ver historial de transacciones
6. ✅ Gestionar perfil

---

**Tiempo estimado total**: 20-30 minutos

¿Preguntas? Revisa los archivos de documentación:
- `CONFIGURACION_FIREBASE.md` - Guía detallada de Firebase
- `README.md` - Información general del proyecto
