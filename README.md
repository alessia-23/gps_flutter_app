# GPS-Flutter-Antigravity 🌍🛰️

Este repositorio contiene la implementación de una aplicación móvil con servicios de **Geolocalización GPS nativa** utilizando **Flutter**. El desarrollo de este proyecto se realizó con asistencia de Inteligencia Artificial mediante la herramienta **Antigravity**, formando parte de un estudio comparativo integral de desarrollo de software asistido.

## 📋 Contexto y Objetivo del Proyecto

Este desarrollo se enmarca dentro de la evaluación práctica de geolocalización y herramientas generativas, cuyo objetivo principal es:
* **Comparar la implementación de GPS** entre dos de los frameworks híbridos más populares del mercado: **Ionic** y **Flutter**.
* **Analizar la eficiencia y precisión** de las herramientas de asistencia en codificación por Inteligencia Artificial: **Codex** y **Antigravity**.

---

## 🛠️ Características Principales (Flutter + Antigravity)

La aplicación implementa de manera robusta y limpia las siguientes funcionalidades solicitadas:

1. **Gestión Activa de Permisos Nativos:** Verificación automática y solicitud dinámica del estado de los permisos de ubicación en el dispositivo antes de acceder a los sensores de hardware.
2. **Captura de Coordenadas de Alta Precisión:** Configuración optimizada utilizando el máximo nivel de precisión del GPS del dispositivo, con controles de tiempo de espera (*timeout*) para garantizar una respuesta rápida y exacta.
3. **Manejo Extensivo de Errores:** Capacidad de interceptar las excepciones nativas de los sensores y transformarlas en mensajes de interfaz de usuario (UI) claros y amigables en español, cubriendo tres escenarios críticos:
   * **Permiso Denegado:** Indicación interactiva para redirigir al usuario a los ajustes del sistema.
   * **GPS Desactivado:** Alerta solicitando la activación del hardware de ubicación del dispositivo.
   * **Tiempo de Espera Agotado (Timeout):** Control de pérdida de señal en entornos techados o de baja cobertura.
4. **Historial Local con Almacenamiento Persistente:** Registro persistente de las capturas de coordenadas utilizando almacenamiento local seguro. Cada registro incluye una marca de tiempo formateada, precisión redondeada y la opción de limpieza completa del historial mediante diálogos de confirmación.
5. **Integración con Mapas Externos:** Capacidad de enviar las coordenadas capturadas directamente hacia aplicaciones de mapas externas (como Google Maps) mediante intents nativos del sistema operativo.

---

## 💻 Arquitectura de Código Destacada

El flujo lógico del aplicativo está modularizado para separar las responsabilidades de la interfaz de usuario de la lógica de comunicación con los servicios nativos:

* **`lib/services/geolocation_service.dart`:** Clase de servicio que encapsula la API nativa de geolocalización, controlando el flujo de permisos, el formateo de errores al idioma local y la persistencia de datos.
* **`lib/screens/home_screen.dart`:** Componente de la interfaz gráfica encargado de renderizar los estados visuales del ciclo de vida (indicadores de carga, snackbars de notificación y alertas de diálogo).

---

## 🚀 Instalación y Despliegue Local

Sigue los siguientes pasos para clonar, instalar las dependencias y ejecutar este proyecto en tu entorno local:

### Pre-requisitos
* **Flutter SDK** (Versión estable más reciente)
* **Dart SDK**
* **Android Studio** o **VS Code** con extensiones de Flutter configuradas

### Pasos de Configuración

1. **Clonar el Repositorio:**
```bash
git clone <https://github.com/alessia-23/gps_flutter_app.git>
cd gps_flutter_app

```

2. **Instalar Dependencias de Dart y Flutter:**

```bash
flutter pub get

```

3. **Verificar Dispositivos Conectados:**

```bash
flutter devices

```

4. **Ejecutar la Aplicación:**

```bash
flutter run

```

*Este comando compilará y desplegará automáticamente la aplicación en tu emulador activo o dispositivo físico conectado.*

---

# 📷 Capturas del sistema

| App con falta de permisos | Cambio d permisos |
|---------------|-------|
|<img width="698" height="1500" alt="image" src="https://github.com/user-attachments/assets/8927baef-b7f7-4ecc-8239-97bb72703dd6" />|<img width="698" height="1600" alt="image" src="https://github.com/user-attachments/assets/62b8297e-d4f7-4497-8016-c28c4db1bfab" />|

| Toma de ubicación | Borrar todo |
|-------|-----------|
|<img width="698" height="1600" alt="image" src="https://github.com/user-attachments/assets/e6e572df-4938-4aee-bb5c-e9e06af1ca30" />|<img width="698" height="1600" alt="image" src="https://github.com/user-attachments/assets/321108ab-4657-4b8e-9dc9-35144c51cb95" />|

| Uso de promt |
|------------|
|<img width="1364" height="709" alt="image" src="https://github.com/user-attachments/assets/ca135b26-0e7e-4b46-ad5f-885c34e16d36" />
 />|
## 🧠 Nota de Desarrollo Asistido (Antigravity AI)

La estructura lógica de los servicios de geolocalización en Dart, la abstracción asíncrona de las promesas del sistema (`async`/`await`) y el mapeo condicional de errores nativos fueron generados y refinados utilizando **Antigravity**.

La herramienta demostró un excelente entendimiento del ecosistema de Flutter, agilizando la gestión de permisos nativos en los archivos de configuración de la plataforma y optimizando los widgets dinámicos de estado.
