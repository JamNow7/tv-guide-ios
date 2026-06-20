# Guía TV

Una aplicación iOS moderna written in Swift y SwiftUI que muestra la programación de TV en tiempo real utilizando la API de TVMaze. Presenta información completa de programas y episodios con imágenes, ratings y horarios.

## 📺 Características

- **Programación en vivo**: Datos actualizados desde TVMaze API
- **Imágenes de alta calidad**: Posters de shows con AsyncImage
- **Información completa**: 
  - Nombre del show y episodio
  - Fecha y hora de transmisión
  - Duración del episodio
  - Temporada y número de episodio
  - Rating con puntuación
  - Resumen del episodio
- **Interfaz moderna**: Diseño limpio con SwiftUI
- **Badges informativos**: SXXEXX, tipo de episodio, rating

## 🛠 Tecnologías

- **Swift 5.9+**
- **SwiftUI** - Framework de UI
- **async/await** - Programación asíncrona moderna
- **Combine** - Manejo de estado con @Published
- **TVMaze API** - Fuente de datos de TV

## 📋 Requisitos

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ (target mínimo)

## 🚀 Instalación y Ejecución

1. **Clonar el repositorio**
   ```bash
   git clone <https://github.com/JamNow7/tv-guide-ios.git>
   cd GuiaTv
   ```

2. **Abrir el proyecto en Xcode**
   ```bash
   open "Guía TV/Guía TV.xcodeproj"
   ```

3. **Seleccionar el simulator**
   - Elige un dispositivo (iPhone 15 Pro recomendado)

4. **Build & Run**
   - Presiona `Cmd + R` o clic en el botón Play

## 📂 Estructura del Proyecto

```
Guía TV/
├── Models/
│   └── TVProgram.swift       # Modelo de datos principal
├── ViewModels/
│   └── TVGuideViewModel.swift # Lógica de presentación
├── Views/
│   └── ContentView.swift      # Vista principal de la lista
├── Services/
│   └── TVService.swift       # Servicio de API
└── GuiaTVApp.swift           # Entry point de la app
```

## 🔧 Arquitectura

El proyecto sigue el patrón **MVVM** (Model-View-ViewModel):

- **Model**: `TVProgram` y structs relacionadas para datos de TVMaze
- **View**: `ContentView` con SwiftUI para renderizado declarativo
- **ViewModel**: `TVGuideViewModel` con `@Published` para estado reactivo
- **Service**: `TVService` encapsula la llamada a la API

## 📦 API Utilizada

**TVMaze API** - https://api.tvmaze.com/

Endpoint utilizado:
```
GET https://api.tvmaze.com/schedule
```

Respuesta incluye datos de episodios y shows con imágenes, ratings, horarios, etc.

## 🎨 Screenshots

La aplicación muestra una lista de programas con:
- Imagen del show (80x120)
- Título del show y episodio
- Badges de temporada/episodio, tipo, rating
- Fecha, hora y duración
- Resumen del episodio (hasta 3 líneas)

## 👨‍💻 Autor

**Claudio Cataldo**

Desarrollado como proyecto de portafolio para demostrar habilidades en:
- SwiftUI y programación reactiva
- Integración de APIs REST
- Modelado de datos con Codable
- async/await para operaciones asíncronas
- MVVM architecture

## 📄 Licencia

Este proyecto es solo para demostración en portafolio personal.

---

**Hecho con ❤️ en Swift**
