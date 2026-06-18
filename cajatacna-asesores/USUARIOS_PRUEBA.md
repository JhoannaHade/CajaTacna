# 👥 USUARIOS DE PRUEBA - CAJATACNA MÓVIL

## 📝 Instrucciones para crear usuarios de prueba

### Paso 1: Crear usuario en Firebase Authentication

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto `cafeteria-232b1`
3. Ve a **Authentication > Users**
4. Haz clic en **Add user**
5. Completa los datos:

### Usuarios de prueba a crear:

#### Usuario 1:
```
Email: jhon.smith@example.com
Password: 123456
Nombre: Jhon Smith
```

#### Usuario 2:
```
Email: maria.garcia@example.com
Password: 123456
Nombre: Maria Garcia
```

#### Usuario 3:
```
Email: carlos.lopez@example.com
Password: 123456
Nombre: Carlos Lopez
```

---

### Paso 2: Crear documentos en Firestore

1. En Firebase Console, ve a **Firestore Database**
2. Crea la colección `users` si no existe
3. Para cada usuario, crea un documento con el **User ID** de Firebase como ID del documento
4. Agrega los siguientes campos:

```json
{
  "email": "jhon.smith@example.com",
  "fullName": "Jhon Smith",
  "accountNumber": "BCP00001751",
  "balance": 5000.00,
  "createdAt": "2024-05-18T10:30:00Z"
}
```

```json
{
  "email": "maria.garcia@example.com",
  "fullName": "Maria Garcia",
  "accountNumber": "BCP00001752",
  "balance": 10500.50,
  "createdAt": "2024-05-18T11:00:00Z"
}
```

```json
{
  "email": "carlos.lopez@example.com",
  "fullName": "Carlos Lopez",
  "accountNumber": "BCP00001753",
  "balance": 3200.75,
  "createdAt": "2024-05-18T11:30:00Z"
}
```

---

### Paso 3: Agregar transacciones de ejemplo (Opcional)

En Firestore, crea la colección `transactions` y agrega documentos como estos:

```json
{
  "userId": "{userId del usuario}",
  "type": "deposit",
  "amount": 500.00,
  "description": "Depósito en caja",
  "date": "2024-05-18T10:35:00Z"
}
```

```json
{
  "userId": "{userId del usuario}",
  "type": "withdrawal",
  "amount": 200.00,
  "description": "Retiro en efectivo",
  "date": "2024-05-18T10:40:00Z"
}
```

---

## 🔐 CÓMO USAR LA APP

### Flujo de acceso:

1. **Splash Screen** (2 segundos)
   - Muestra el logo del CAJATACNA

2. **Pantalla de Login**
   - Email: `jhon.smith@example.com`
   - Password: `123456`
   - Presiona "Ingresar"

3. **Pantalla de PIN**
   - Clave de 6 dígitos: `123456` (o cualquier número de 6 dígitos)
   - Presiona "Ingresar"

4. **App Principal**
   - Acceso completo a la app

### Opciones de datos guardados:

- La sesión se guarda automáticamente
- La próxima vez que abras la app, irá directamente a la pantalla de PIN
- Para cambiar de cuenta, presiona "Cambiar" en la tarjeta de cuenta

---

## 💡 DATOS DE PRUEBA RÁPIDOS

Copia y pega en Firestore:

### Usuarios:
- **Email 1**: jhon.smith@example.com | **Pass**: 123456 | **Nombre**: Jhon Smith
- **Email 2**: maria.garcia@example.com | **Pass**: 123456 | **Nombre**: Maria Garcia
- **Email 3**: carlos.lopez@example.com | **Pass**: 123456 | **Nombre**: Carlos Lopez

### PIN de prueba:
- Cualquier PIN de 6 dígitos (ej: 123456, 999999, etc.)

---

## ✅ CHECKLIST DE CONFIGURACIÓN

- [ ] Usuarios creados en Firebase Authentication
- [ ] Documentos creados en Firestore `users` collection
- [ ] Transacciones de ejemplo agregadas (opcional)
- [ ] Firestore en `test mode` habilitado
- [ ] Reglas de seguridad configuradas

---

## 🚀 EJECUTAR LA APP

```bash
flutter run
```

¡Disfruta probando la app del CAJATACNA! 🎉
