import 'package:flutter/material.dart';
import 'app_state.dart';

/// Very small i18n helper for quick translations.
/// Use `tr('key')` to get the translated string for the current AppState.locale.

const Map<String, Map<String, String>> _translations = {
  'es': {
    // Navigation
    'nav.home': 'Inicio',
    'nav.reviews': 'Reseñas',
    'nav.reservations': 'Reservas',
    'nav.profile': 'Perfil',

    // Parking / Home
    'parking.search_hint': 'Buscar parking...',
    'parking.reserve_now': 'Reservar ahora',
    'parking.view_reviews': 'Ver reseñas',
    'parking.filter.covered': 'Cubierto',
    'parking.filter.open24': '24h',
    'parking.no_results': 'No se encontraron parkings',

    // Reservations
    'reservations.title': 'Mis Reservas',
    'reservations.empty': 'No tienes reservas',
    'reservations.upcoming': 'PRÓXIMAS',
    'reservations.past': 'PASADAS',
    'reservations.no_driver': 'No driver ID found. Please log in again.',
    'reservations.empty_hint': 'Cuando hagas tu primera reserva aparecerá aquí',
    'reservations.retry': 'Reintentar',
    'reservations.loading_error': 'Error cargando reservas',

    // Reviews
    'reviews.title': 'Reseñas',
    'reviews.loading_error': 'Error al cargar reseñas',
    'reviews.empty': 'No hay reseñas disponibles',

    'settings.title': 'Configuración',
    'settings.notifications': 'Notificaciones',
    'settings.reminders': 'Recordatorios de reserva',
    'settings.offers': 'Ofertas y promociones',
    'settings.updates': 'Actualizaciones de la app',
    'settings.preferences': 'Preferencias',
    'settings.language': 'Idioma',
    'settings.theme': 'Tema',
    'settings.select_language': 'Selecciona idioma',
    'language.spanish': 'Español',
    'language.english': 'English',
    'settings.saved_language': 'Idioma guardado',
    'settings.select_theme': 'Selecciona tema',
    'theme.light': 'Claro',
    'theme.dark': 'Oscuro',
    'settings.saved_theme': 'Tema guardado',

    // Profile / Driver
    'profile.change_photo_title': 'Cambiar foto de perfil',
    'profile.change_photo_content':
    'Funcionalidad para cambiar foto aún no implementada.',
    'profile.retry': 'Reintentar',
    'profile.driver_not_available': 'Detalles del conductor no disponibles.',
    'profile.personal_data': 'Datos personales',
    'profile.edit_info': 'Editar información',
    'profile.payment_methods': 'Métodos de pago',
    'profile.stored_cards': 'Tarjetas guardadas',
    'profile.notifications': 'Notificaciones',
    'profile.view_notifications': 'Visualizar Notificaciones',
    'profile.settings': 'Configuración',
    'profile.preferences': 'Preferencias de la app',
    'profile.logout': 'Cerrar sesión',
    // Parking card
    'parking.details_title': 'Detalles del Parking',
    'parking.no_image': 'No hay imagen disponible',
    'parking.spots_format': '{available} disponibles / {total} totales',
    // Generic
    'common.loading': 'Cargando...',
    // Reservation labels
    'reservation.view_details': 'Ver detalles',
    'reservation.spot': 'Espacio',
    'reservation.status.completed': 'Completada',
    'reservation.status.active': 'Activa',
    'reservation.status.pending': 'Próxima',
    // Active reservation / detail
    'reservations.active_title': 'Reserva activa',
    'reservation.remaining_label': 'restante',
    'reservations.view_on_map': 'Ver en mapa',
    'reservations.cancel_label': 'Cancelar reserva',
    'reservations.canceled_snack': 'Reserva cancelada',
    'reservations.error_canceling': 'Error cancelando',
    'reservation.extend_time_title': 'Extender tiempo',
    'reservation.extend_time_content':
    'Funcionalidad de extender tiempo (placeholder).',
    'common.close': 'Cerrar',
    // Notifications (examples)
    'notifications.title': 'Notificaciones',
    'notifications.confirmed_title': 'Reserva confirmada',
    'notifications.confirmed_subtitle':
    'Tu reserva para hoy a las 10:00 está confirmada',
    'notifications.reminder_title': 'Recordatorio',
    'notifications.reminder_subtitle': 'Tu reserva comienza en 30 minutos',
    'notifications.offer_title': 'Oferta especial',
    'notifications.offer_subtitle': '20% de descuento en tu próxima reserva',
    // Reservation form / flow
    'form.vehicle_plate': 'Matrícula del vehículo',
    'form.vehicle_plate_hint': 'ABC-123',
    'form.start_time': 'Hora de inicio',
    'form.end_time': 'Hora de fin',
    'form.select_start': 'Selecciona hora de inicio',
    'form.select_end': 'Selecciona hora de fin',
    'form.selected_spot': 'Plaza seleccionada',
    'form.no_spot_selected': 'No hay plaza seleccionada',
    'form.total': 'Total',
    'form.hours_label': 'horas',
    'form.cancel': 'Cancelar',
    'form.reserve': 'Reservar',
    'form.error_complete_fields':
    'Por favor completa todos los campos antes de reservar.',
    'form.error_same_times': 'La hora de inicio y fin no pueden ser iguales.',
    'form.error_end_before_start':
    'La hora de fin debe ser después de la hora de inicio.',
    'form.error_enter_plate': 'Por favor ingresa la matrícula del vehículo.',
    'form.success_reservation': '¡Reserva exitosa!',
    'form.go_to_payment': 'Ir al pago',
    // Forgot / Reset password
    'forgot.title': 'Recuperar contraseña',
    'forgot.email_hint': 'Correo electrónico',
    'forgot.send': 'Enviar instrucciones',
    'forgot.success_message':
    'Si existe una cuenta con ese correo, recibirás instrucciones para restablecer la contraseña.',
    'forgot.error': 'Error al solicitar restablecimiento',

    'reset.title': 'Restablecer contraseña',
    'reset.token_hint': 'Código o token recibido por correo',
    'reset.new_password_hint': 'Nueva contraseña',
    'reset.confirm_password_hint': 'Confirmar nueva contraseña',
    'reset.submit': 'Cambiar contraseña',
    'reset.success': 'Contraseña cambiada correctamente',
    'reset.error': 'Error al cambiar contraseña',
    'reset.error_mismatch': 'Las contraseñas no coinciden',
    'form.error_reserving': 'Error reservando plaza',
    // Payment / reservation payment
    'reservation.payment_title': 'Pago de Reserva',
    'payment.simulated_success':
    'Pago simulado localmente. Reserva confirmada.',
    'payment.simulated_failed': 'La simulación de pago falló.',
    'payment.success': 'Pago exitoso',
    'payment.failed': 'Pago fallido',
    'payment.pay_now': 'Pagar ahora',
    'payment.name_on_card': 'Nombre en la tarjeta',
    'payment.card_number': 'Número de tarjeta',
    'payment.expiration_date': 'Fecha de expiración',
    'payment.cvv': 'CVV',
    'form.field_required': 'Este campo es obligatorio',
  },
  'en': {
    // Navigation
    'nav.home': 'Home',
    'nav.reviews': 'Reviews',
    'nav.reservations': 'Reservations',
    'nav.profile': 'Profile',

    // Parking / Home
    'parking.search_hint': 'Search parking...',
    'parking.reserve_now': 'Reserve Now',
    'parking.view_reviews': 'View Reviews',
    'parking.filter.covered': 'Covered',
    'parking.filter.open24': '24h',
    'parking.no_results': 'No parkings found',

    // Reservations
    'reservations.title': 'My Reservations',
    'reservations.empty': 'You have no reservations',
    'reservations.upcoming': 'UPCOMING',
    'reservations.past': 'PAST',
    'reservations.no_driver': 'No driver ID found. Please log in again.',
    'reservations.empty_hint':
    'When you make your first reservation it will appear here',
    'reservations.retry': 'Retry',
    'reservations.loading_error': 'Error loading reservations',

    // Reviews
    'reviews.title': 'Reviews',
    'reviews.loading_error': 'Error loading reviews',
    'reviews.empty': 'No reviews available',

    'settings.title': 'Settings',
    'settings.notifications': 'Notifications',
    'settings.reminders': 'Reservation reminders',
    'settings.offers': 'Offers & promotions',
    'settings.updates': 'App updates',
    'settings.preferences': 'Preferences',
    'settings.language': 'Language',
    'settings.theme': 'Theme',
    'settings.select_language': 'Select language',
    'language.spanish': 'Spanish',
    'language.english': 'English',
    'settings.saved_language': 'Language saved',
    'settings.select_theme': 'Select theme',
    'theme.light': 'Light',
    'theme.dark': 'Dark',
    'settings.saved_theme': 'Theme saved',

    // Profile / Driver
    'profile.change_photo_title': 'Change profile picture',
    'profile.change_photo_content':
    'Profile picture change not implemented yet.',
    'profile.retry': 'Retry',
    'profile.driver_not_available': 'Driver details not available.',
    'profile.personal_data': 'Personal data',
    'profile.edit_info': 'Edit information',
    'profile.payment_methods': 'Payment methods',
    'profile.stored_cards': 'Saved cards',
    'profile.notifications': 'Notifications',
    'profile.view_notifications': 'View notifications',
    'profile.settings': 'Settings',
    'profile.preferences': 'App preferences',
    'profile.logout': 'Sign out',
    // Parking card
    'parking.details_title': 'Parking Details',
    'parking.no_image': 'No image available',
    'parking.spots_format': '{available} available / {total} total',
    // Generic
    'common.loading': 'Loading...',
    // Reservation labels
    'reservation.view_details': 'View details',
    'reservation.spot': 'Spot',
    'reservation.status.completed': 'Completed',
    'reservation.status.active': 'Active',
    'reservation.status.pending': 'Upcoming',
    // Active reservation / detail
    'reservations.active_title': 'Active reservation',
    'reservation.remaining_label': 'remaining',
    'reservations.view_on_map': 'View on map',
    'reservations.cancel_label': 'Cancel reservation',
    'reservations.canceled_snack': 'Reservation canceled',
    'reservations.error_canceling': 'Error canceling',
    'reservation.extend_time_title': 'Extend time',
    'reservation.extend_time_content':
    'Extend time functionality (placeholder).',
    'common.close': 'Close',
    // Notifications (examples)
    'notifications.title': 'Notifications',
    'notifications.confirmed_title': 'Reservation confirmed',
    'notifications.confirmed_subtitle':
    'Your reservation for today at 10:00 is confirmed',
    'notifications.reminder_title': 'Reminder',
    'notifications.reminder_subtitle': 'Your reservation starts in 30 minutes',
    'notifications.offer_title': 'Special offer',
    'notifications.offer_subtitle': '20% off your next reservation',
    // Reservation form / flow
    'form.vehicle_plate': 'Vehicle Plate',
    'form.vehicle_plate_hint': 'ABC-123',
    'form.start_time': 'Start Time',
    'form.end_time': 'End Time',
    'form.select_start': 'Select start time',
    'form.select_end': 'Select end time',
    'form.selected_spot': 'Selected Spot',
    'form.no_spot_selected': 'No spot selected',
    'form.total': 'Total',
    'form.hours_label': 'hours',
    'form.cancel': 'Cancel',
    'form.reserve': 'Reserve',
    'form.error_complete_fields':
    'Please complete all fields before reserving.',
    'form.error_same_times': 'Start time and end time cannot be the same.',
    'form.error_end_before_start': 'End time must be after start time.',
    'form.error_enter_plate': 'Please enter your vehicle plate.',
    'form.success_reservation': 'Reservation successful!',
    'form.go_to_payment': 'Go to Payment',
    // Forgot / Reset password
    'forgot.title': 'Forgot password',
    'forgot.email_hint': 'Email',
    'forgot.send': 'Send instructions',
    'forgot.success_message':
    'If an account exists for that email you will receive instructions to reset your password.',
    'forgot.error': 'Error requesting reset',

    'reset.title': 'Reset password',
    'reset.token_hint': 'Token received by email',
    'reset.new_password_hint': 'New password',
    'reset.confirm_password_hint': 'Confirm new password',
    'reset.submit': 'Change password',
    'reset.success': 'Password changed',
    'reset.error': 'Error changing password',
    'reset.error_mismatch': "Passwords don't match",
    'form.error_reserving': 'Error reserving spot',
    // Payment / reservation payment
    'reservation.payment_title': 'Reservation Payment',
    'payment.simulated_success':
    'Payment simulated locally. Reservation confirmed.',
    'payment.simulated_failed': 'Payment simulation failed.',
    'payment.pay_now': 'Pay Now',
    'payment.success': 'Payment successful!',
    'payment.failed': 'Payment failed.',
    'payment.name_on_card': 'Name on Card',
    'payment.card_number': 'Card Number',
    'payment.expiration_date': 'Expiration Date',
    'payment.cvv': 'CVV',
    'form.field_required': 'This field is required',
  },
};

String tr(String key) {
  final Locale? loc = AppState.locale.value;
  final code = (loc?.languageCode ?? 'es');
  final map = _translations[code] ?? _translations['es']!;
  return map[key] ?? key;
}
