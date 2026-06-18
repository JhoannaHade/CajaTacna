# 🏦 CAJATACNA Móvil - Aplicación Bancaria Flutter

Aplicación móvil bancaria desarrollada con **Flutter** y **Firebase**, diseñada como prueba para operaciones básicas de depósitos, retiros y gestión de cuenta.

## ✨ Características

- 🔐 **Autenticación**: Registro e inicio de sesión con Firebase Authentication
- 👤 **Perfil de usuario**: Gestión de datos personales y número de cuenta único
- 💰 **Operaciones bancarias**: Depósitos y retiros con validación automática de saldo
- 📊 **Historial de transacciones**: Visualización en tiempo real con Firestore
- 🎨 **Diseño moderno**: Interfaz atractiva con gradientes, colores dinámicos y animaciones
- 🔒 **Seguridad**: Autenticación basada en Firebase con reglas de seguridad

## 🚀 Inicio rápido

### Prerequisitos
- Flutter 3.0+
- Dart 3.0+
- Cuenta en [Firebase Console](https://console.firebase.google.com/)

### Instalación

1. **Instalar dependencias**
```bash
flutter pub get
```

2. **Configurar Firebase** (ver [CONFIGURACION_FIREBASE.md](CONFIGURACION_FIREBASE.md))
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=cajatacna-movil-project
```

3. **Ejecutar**
```bash
flutter run
```

## 📂 Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada con AuthWrapper
├── firebase_options.dart        # Configuración de Firebase
├── models/
│   ├── user_model.dart         # Modelo de usuario
│   └── transaction_model.dart  # Modelo de transacción
├── services/
│   └── firebase_service.dart   # Servicio centralizado de Firebase
└── screens/
    ├── auth_screen.dart        # Pantalla de login/registro
    ├── home_screen.dart        # Pantalla principal con operaciones
    ├── transactions_screen.dart # Historial de movimientos
    └── profile_screen.dart     # Perfil del usuario
```

## 🔄 Flujo de la aplicación

```
┌─────────────────┐
│  AuthWrapper    │ (StreamBuilder)
└────────┬────────┘
         │
    ┌────┴────┐
    │          │
    ▼          ▼
┌────────┐  ┌──────────┐
│ Auth   │  │ Home     │
│Screen  │  │Screen    │
└────────┘  └────┬─────┘
                 │
         ┌───────┼────────┐
         ▼       ▼        ▼
      Deposit Withdraw  Transactions
                        Profile
```

## 💳 Operaciones soportadas

| Operación | Descripción |
|-----------|-------------|
| **Depósito** | Aumenta el saldo de la cuenta |
| **Retiro** | Disminuye el saldo (con validación) |
| **Ver movimientos** | Historial en tiempo real |
| **Perfil** | Información de la cuenta |

## 🧪 Datos iniciales

Cada usuario al registrarse obtiene:
- **Saldo inicial**: S/. 5,000.00
- **Número de cuenta**: CAJATACNA + timestamp único
- **Fecha de registro**: Automática

## 📊 Estructura de Firestore

### Collection: `users`
```json
{
  "email": "usuario@example.com",
  "fullName": "Juan Pérez García",
  "accountNumber": "BCP1234567890123",
  "balance": 5000.00,
  "createdAt": "2024-05-18T10:30:00Z"
}
```

### Collection: `transactions`
```json
{
  "userId": "user_uid_123",
  "type": "deposit",
  "amount": 1000.00,
  "description": "Depósito en efectivo",
  "date": "2024-05-18T10:35:00Z"
}
```

## 🎨 Diseño y colores

- **Color primario**: Azul (#1e88e5)
- **Color depósito**: Verde (#4caf50)
- **Color retiro**: Rojo (#f44336)
- **Fondo**: Gradientes azul-degradados
- **Tipografía**: Material Design 3

## 📱 Plataformas

- ✅ **Android** - Totalmente soportado
- ✅ **iOS** - Totalmente soportado
- ✅ **Web** - Totalmente soportado
- ⏳ **Windows/macOS** - Requiere configuración adicional

## 🔑 Funciones principales

### Autenticación
```dart
// Registro
await firebaseService.registerUser(email, password);
await firebaseService.createUserProfile(uid, email, fullName, accountNumber);

// Login
await firebaseService.loginUser(email, password);

// Logout
await firebaseService.signOut();
```

### Operaciones bancarias
```dart
// Depósito o retiro
await firebaseService.createTransaction(
  userId,
  'deposit', // o 'withdrawal'
  amount,
  description
);
```

### Acceso a datos
```dart
// Perfil del usuario
UserModel? profile = await firebaseService.getUserProfile(userId);

// Transacciones en tiempo real
Stream<List<TransactionModel>> transactions = 
  firebaseService.getUserTransactions(userId);
```

## 🔒 Reglas de seguridad (Firestore)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /transactions/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📦 Dependencias principales

```yaml
firebase_core: ^3.3.0      # Core de Firebase
firebase_auth: ^5.1.4      # Autenticación
cloud_firestore: ^5.2.1    # Base de datos
provider: ^6.4.1           # State management
```

## 🐛 Solución de problemas

### Error: "Target of URI doesn't exist"
```bash
flutter clean
flutter pub get
flutter run
```

### Error de conexión a Firebase
- Verifica que Firebase esté configurado en `firebase_options.dart`
- Asegúrate de estar en conexión a internet
- Verifica que el proyecto en Firebase esté activo

### Base de datos vacía
- Está en **test mode** (correcto para desarrollo)
- Las colecciones se crean automáticamente al insertar datos

### Error de autenticación
- Verifica que Email/Password esté habilitado en Authentication
- Comprueba que las reglas de Firestore sean correctas

## 🚀 Próximas mejoras

- [ ] Transferencias entre cuentas
- [ ] Pagos de servicios
- [ ] Generador de reportes PDF
- [ ] Notificaciones push
- [ ] Two-factor authentication
- [ ] Biometric login (huella/cara)
- [ ] Soporte para múltiples monedas
- [ ] Gráficos de gastos

## 📚 Recursos útiles

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io/)

## 📄 Configuración detallada

Para instrucciones completas de configuración de Firebase, ver:
👉 [CONFIGURACION_FIREBASE.md](CONFIGURACION_FIREBASE.md)

## ⚠️ Importante

Esta es una **aplicación de prueba/demostración** para fines educativos. 
- No está destinada para uso en producción con datos reales
- Las reglas de seguridad son básicas (test mode)
- Se requieren mejoras de seguridad para producción

---

**Desarrollado con ❤️ usando Flutter y Firebase**
