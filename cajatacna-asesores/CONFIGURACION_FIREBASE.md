# Configuración de Firebase para CAJATACNA Móvil

## Pasos para configurar Firebase

### 1. Crear proyecto en Firebase Console
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto llamado "cajatacna-movil-project"
3. Habilita Google Analytics (opcional)

### 2. Configurar autenticación
1. Ve a **Authentication** en la consola
2. Haz clic en **Get started**
3. Habilita **Email/Password** como proveedor de autenticación

### 3. Crear base de datos Firestore
1. Ve a **Firestore Database**
2. Haz clic en **Create database**
3. Selecciona el modo de inicio: **Start in test mode** (para desarrollo)
4. Selecciona la ubicación geográfica
5. Crea la base de datos

### 4. Configurar FlutterFire CLI (Recomendado)
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Ejecutar desde la raíz del proyecto
flutterfire configure --project=cajatacna-movil-project
```

Este comando genera automáticamente `lib/firebase_options.dart` con tus credenciales reales.

### 5. Actualizar firebase_options.dart (Si no usas FlutterFire CLI)
Reemplaza los valores dummy en `lib/firebase_options.dart` con tus credenciales reales de Firebase:
- Ve a **Project Settings** en Firebase Console
- Copia los valores de configuración para cada plataforma

### 6. Instalar dependencias
```bash
flutter pub get
```

### 7. Ejecutar la aplicación
```bash
flutter run
```

## Estructura de la base de datos Firestore

La aplicación usa la siguiente estructura:

```
Firestore Database
├── users/
│   ├── {userId}
│   │   ├── email: string
│   │   ├── fullName: string
│   │   ├── accountNumber: string
│   │   ├── balance: number
│   │   └── createdAt: timestamp
│
└── transactions/
    ├── {transactionId}
    │   ├── userId: string
    │   ├── type: string ("deposit" | "withdrawal")
    │   ├── amount: number
    │   ├── description: string
    │   └── date: timestamp
```

## Reglas de seguridad para Firestore (Desarrollo)

En **Firestore > Rules**, usa estas reglas para desarrollo:

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

## Características de la aplicación

✅ **Autenticación**: Registro e inicio de sesión con Firebase Auth
✅ **Gestión de usuarios**: Perfiles de usuario con número de cuenta
✅ **Transacciones**: Depósitos y retiros con actualización automática de saldo
✅ **Historial**: Visualización de movimientos en tiempo real
✅ **UI moderna**: Interfaz con gradientes y diseño responsivo

## Datos de prueba

Al registrarse, los usuarios obtienen:
- Saldo inicial: S/. 5,000.00
- Número de cuenta: CAJATACNA + timestamp

## Notas importantes

- Esta es una aplicación de prueba
- Los datos en Firestore son reales, úsalos responsablemente
- Para producción, implementa reglas de seguridad más estrictas
- Considera agregar validación adicional en el backend

## Troubleshooting

### Error: "Target of URI doesn't exist"
Ejecuta `flutter pub get` después de configurar Firebase.

### Error de autenticación
Asegúrate de habilitar Email/Password en Authentication.

### Firestore vacío
Verifica que la base de datos esté en modo "test mode" durante desarrollo.

## Recursos útiles

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- [Flutter Documentation](https://flutter.dev/docs)
