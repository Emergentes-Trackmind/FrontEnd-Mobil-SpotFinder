# SpotFinder Mobile - Modo Offline

Esta aplicación ha sido configurada para funcionar completamente offline sin necesidad de APIs externas ni bases de datos.

## 🚀 Cómo usar la aplicación

### 1. Inicio de Sesión

La aplicación viene con usuarios predefinidos para testing:

**Usuarios disponibles:**
- Email: `driver1@test.com` | Contraseña: `123456`
- Email: `driver2@test.com` | Contraseña: `123456`
- Email: `test@test.com` | Contraseña: `test12`

**O puedes registrar un nuevo usuario** usando cualquier email válido.

### 2. Funcionalidades Disponibles

#### 🗺️ Mapa de Estacionamientos
- Visualiza 5 estacionamientos predefinidos en Lima, Perú
- Cada estacionamiento tiene información realista:
  - Centro Comercial Plaza Norte
  - Mall Aventura Plaza
  - Estacionamiento Centro de Lima
  - Real Plaza Salaverry
  - Larcomar

#### 🅿️ Reservas
- Crea reservas de estacionamiento
- Visualiza reservas por estado: Pendiente, Confirmada, Completada, Cancelada
- Simula pagos y confirmaciones
- Cada usuario tiene reservas de ejemplo

#### ⭐ Reseñas
- Visualiza reseñas existentes de estacionamientos
- Crea nuevas reseñas (simuladas)
- Sistema de calificación de 1-5 estrellas

#### 👤 Perfil de Usuario
- Información del usuario logueado
- Gestión de datos personales

## ⚙️ Configuración Técnica

### Modo Mock Activado
La aplicación está configurada con `USE_MOCK_SERVICES = true` en `lib/config.mock.dart`

### Datos Simulados
- **Usuarios**: Definidos en `AuthServiceMock`
- **Estacionamientos**: 5 ubicaciones en Lima con datos realistas
- **Reservas**: Reservas de ejemplo por usuario
- **Reseñas**: Reseñas de ejemplo con calificaciones

### Servicios Mock Creados
1. `AuthServiceMock` - Autenticación local
2. `ParkingServiceMock` - Gestión de estacionamientos
3. `ReservationServiceMock` - Manejo de reservas
4. `ReviewServiceMock` - Sistema de reseñas

## 🔧 Ejecución

```bash
# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

## 📱 Navegación

1. **Login** → Usar credenciales predefinidas o registrarse
2. **Mapa** → Ver estacionamientos disponibles
3. **Reservas** → Gestionar reservas por estado
4. **Reseñas** → Ver y crear reseñas
5. **Perfil** → Información del usuario

## ✨ Características Mock

- **Sin conexión a internet requerida**
- **Datos persistentes durante la sesión**
- **Simulación realista de delays de red**
- **Manejo de errores simulados**
- **Datos de ejemplo representativos**

## 🛠️ Para Desarrolladores

Si necesitas volver al modo real con APIs:
1. Cambiar `USE_MOCK_SERVICES = false` en `lib/config.mock.dart`
2. Configurar URLs reales en `.env`
3. Implementar backend correspondiente

La aplicación está lista para usar y probar todas las funcionalidades sin necesidad de servicios externos.
