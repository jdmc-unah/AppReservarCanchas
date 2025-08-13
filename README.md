 <div align="center" style="display: flex; flex-direction: column  ;  align-items: center; justify-content: center; gap: 12px;">
  <img src="https://github.com/user-attachments/assets/a07ebfeb-bc9e-4cd6-9434-c4472883562d" alt="Icono" width="70">
  <h1 style="margin: 0;">Book & Play</h2>
</div>

Aplicación móvil diseñada para facilitar la gestión y reserva de canchas deportivas, ofreciendo una experiencia fluida, segura y personalizada. Construida con Flutter y respaldada por los servicios de Firebase, la app permite a los usuarios registrarse, buscar, reservar y pagar por espacios deportivos de forma rápida y confiable.


## Integrantes

José Daniel Mejía Cuellar - 20212030242  
Carlos Alfredo Alvarez Colindres - 20222030195  
Bryan Noé Cruz Izaguirre - 20192000205

## Características

### Servicios Firebase

- Autenticación y registro con correo y contraseña
- Autenticación con Google
- Servicio de base de datos Firestore

### Funciones Principales

- Inicio de sesión persistente con GetStorage
- Listado de Canchas. Actualización de la disponibilidad de las canchas en tiempo real
- Reservaciones. Horarios específicos dividido por hora, elección de fecha con DatePicker y suma automatica de total a pagar
- Gestión de métodos de pago. Agregar y eliminar tarjetas para efectuar el pago de la reserva
- Historial de reservas con estados (disponible, no disponible, estado del pago)
- Filtros. Busqueda por nombre, tipo de cancha, rango de precio
- Manejo de errores y excepciones personalizadas

## Requisitos

- Android 6.0 o posterior
- Acceso a internet
