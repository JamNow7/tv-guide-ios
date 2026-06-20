# Guía TV

Una aplicación iOS moderna escrita en Swift y SwiftUI que muestra la programación de TV en tiempo real utilizando la API de TVMaze. Presenta información completa de programas y episodios con imágenes, ratings y horarios, con navegación a pantalla de detalles y filtros por canal.

## 📺 Características

### Vista de Lista Principal
- **Filter Chips elegantes**: Filtro horizontal scrollable por canal de TV (estilo YouTube/Instagram)
- **Imágenes de shows**: En alta resolución (80x120) con AsyncImage
- **Badges informativos**:
  - Temporada/episodio (SXXEXX)
  - Tipo de episodio (Regular, Especial)
  - Rating con estrellas
  - Nombre del canal
- **Información completa**: Fecha, hora y duración del programa
- **Resumen**: Hasta 3 líneas con HTML limpio
- **FlowLayout**: Badges con wrapping automático para evitar deformación

### Vista de Detalles Completa
- **Imagen grande del show**: Hasta 300px de alto con placeholder elegante
- **Títulos prominentes**: Show y episodio con jerarquía visual clara
- **Badges completos**: Season, type, runtime, rating
- **Secciones organizadas**: Fecha, hora y canal con banderas del país
- **Resumen completo**: Todo el contenido sin etiquetas HTML
- **Navegación fluida**: Transition suave desde la lista

### Características Técnicas
- **Procesamiento de HTML**: Limpieza automática de etiquetas y entidades
- **Filtrado reactivo**: Los programas se filtran instantáneamente por canal
- **Banderas de países**: Emojis generados desde códigos ISO (US, UK, etc.)
- **Layout adaptativo**: FlowLayout custom para badges con wrapping

## 🛠 Tecnologías

- **Swift 5.9+**
- **SwiftUI** - Framework de UI declarativo
- **async/await** - Programación asíncrona moderna
- **Combine** - Manejo de estado con @Published
- **Custom Layout** - FlowLayout implementado con protocolo Layout
- **Regex** - Limpieza de HTML con NSRegularExpression
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
GuiaTv/
├── Guía TV/
│   ├── Models/
│   │   └── TVProgram.swift          # Modelo de datos principal
│   ├── ViewModels/
│   │   └── TVGuideViewModel.swift   # Lógica de presentación y filtros
│   ├── Views/
│   │   ├── ContentView.swift        # Vista principal con Filter Chips
│   │   ├── ProgramDetailView.swift  # Vista de detalles completa
│   │   └── String+Extensions.swift  # Extensiones (HTML, banderas)
│   ├── Services/
│   │   └── TVService.swift          # Servicio de API
│   └── GuiaTVApp.swift              # Entry point de la app
├── docs/                            # 📸 Fotos de evidencia
├── README.md
└── Guía TV.xcodeproj
```

## 🔧 Arquitectura

El proyecto sigue el patrón **MVVM** (Model-View-ViewModel):

### Model
- `TVProgram` - Modelo principal de programa de TV
- `TVMazeScheduleItem` - Respuesta cruda de la API
- `RatingDTO`, `ImageDTO`, `ShowDTO`, `NetworkDTO`, `CountryDTO` - Modelos auxiliares

### Views
- **ContentView** - Lista principal con Filter Chips y FlowLayout
- **ProgramDetailView** - Detalles completos con banderas
- **FilterChip** - Componente reutilizable de filtros
- **FlowLayout** - Layout custom para wrapping de badges

### ViewModel
- **TVGuideViewModel** - Estado reactivo con `@Published`:
  - `programs` - Lista completa de programas
  - `filteredPrograms` - Programas filtrados por canal
  - `availableNetworks` - Canales únicos disponibles
  - `selectedNetwork` - Canal seleccionado (nil = todos)

### Service
- **TVService** - Encapsula llamada a TVMaze API con async/await

### Flujo de Datos

```
TVMaze API → TVService → TVGuideViewModel → Views
                    ↓        ↓        ↓
              TVProgram   @Published  Filter
```

## 📦 API Utilizada

**TVMaze API** - https://api.tvmaze.com/

### Endpoint
```
GET https://api.tvmaze.com/schedule
```

### Datos que se consumen:

#### Episodio
- id, name, season, number, type
- airdate, airtime, runtime, airstamp
- rating (average), summary
- image (medium, original)

#### Show
- id, name, type, language, genres, status
- schedule (time, days)
- network (id, name, country, officialSite)
- image (medium, original)
- summary

### Procesamiento de HTML

Los resúmenes vienen con HTML (`<p>`, `<b>`, `</p>`, etc.). Se usa una extensión de String con regex para limpiar:

```swift
extension String {
    func stripHTML() -> String {
        // Elimina <p>, <b>, etc.
        // Reemplaza &nbsp;, &amp;, etc.
    }

    func flagEmoji() -> String {
        // Convierte "US" → 🇺🇸
    }
}
```

## 🎨 Screenshots

### Vista Principal
- **Filter Chips**: [Todos✓] [CNN] [HBO] [NBC] → (scroll horizontal)
- **Tarjetas de programas** con imagen, badges, fecha/hora y resumen

### Vista de Detalles
- **Imagen grande** del show con placeholder elegante
- **Secciones organizadas**: Fecha, hora, canal con bandera
- **Resumen completo** sin HTML

### Filtros
- **Chips seleccionados**: Color accent con checkmark
- **Chips no seleccionados**: Gris
- **Scroll fluido** para acceder a todos los canales

📸 **Ver más capturas en [`docs/`](docs/)**

## 👨‍💻 Autor

**Claudio Cataldo**

Desarrollado como proyecto de portafolio para demostrar habilidades en:

- **SwiftUI avanzado**: Views, Layouts personalizados, animaciones
- **Arquitectura MVVM**: Separación clara de responsabilidades
- **Integración de APIs**: REST con async/await
- **Modelado de datos**: Codable con structs anidados
- **Procesamiento de texto**: Regex para limpieza de HTML
- **UI/UX moderna**: Filter chips, flow layouts, navigation
- **Reactividad**: Combine con @Published
- **Extensiones de Swift**: String, UnicodeScalar

## 📄 Licencia

Este proyecto es solo para demostración en portafolio personal.

---

**Hecho con ❤️ en Swift**
