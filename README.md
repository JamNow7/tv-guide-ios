# 📺 TV Guide iOS

[![iOS CI](https://github.com/JamNow7/tv-guide-ios/workflows/iOS%20Tests/badge.svg)](https://github.com/JamNow7/tv-guide-ios/actions)

> **Aplicación SwiftUI profesional con MVVM, SwiftData, Testing y Cache**
> Nivel: Portafolio Senior iOS Engineer

---

## 🎯 Descripción del Proyecto

TV Guide iOS es una aplicación completa para explorar programación de televisión con datos de la API de TVMaze. Este proyecto demuestra competencias avanzadas de desarrollo iOS moderno, incluyendo arquitectura limpia, testing, cache local, y manejo de errores de producción.

### 🏆 Nivel de Portafolio

Este proyecto está diseñado para reclutadores iOS Senior, demostrando:

- ✅ **Arquitectura MVVM limpia** con inyección de dependencias
- ✅ **SwiftUI moderno** (iOS 17+) con vistas reutilizables
- ✅ **SwiftData** para persistencia local
- ✅ **Testing suite** con mocks y coverage
- ✅ **Error handling** profesional con tipos personalizados
- ✅ **Cache inteligente** con fallback offline
- ✅ **Búsqueda avanzada** combinada con filtros
- ✅ **Loading states** con skeleton UI
- ✅ **async/await** moderno

---

## 🛠️ Stack Tecnológico

| Categoría | Tecnología | Versión | Propósito |
|-----------|------------|---------|----------|
| **Lenguaje** | Swift | 5.9+ | Lenguaje principal |
| **Framework UI** | SwiftUI | iOS 17+ | Declarativo, moderno |
| **Arquitectura** | MVVM + DI | - | Separación de responsabilidades |
| **Persistencia** | SwiftData | iOS 17+ | Cache local |
| **Networking** | URLSession | - | API calls con async/await |
| **Testing** | XCTest | - | Unit tests |
| **API** | TVMaze | - | Datos de programación |

---

## 📁 Estructura del Proyecto

```
GuiaTv/
├── GuiaTVApp.swift              # App entry point + SwiftData setup
│
├── Models/
│   ├── TVProgram.swift          # @Model para SwiftData
│   └── TVServiceError.swift     # Tipos de error personalizados
│
├── ViewModels/
│   └── TVGuideViewModel.swift  # MVVM con DI + cache + search
│
├── Views/
│   ├── ContentView.swift        # Vista principal con searchable
│   ├── ProgramDetailView.swift  # Detalle de programa
│   ├── String+Extensions.swift  # stripHTML, flagEmoji
│   ├── SkeletonLoadingView.swift # Loading moderno
│   └── EmptyStateView.swift     # Estados vacíos/error
│
├── Services/
│   ├── TVService.swift          # API con protocolo + errors
│   ├── CacheService.swift       # SwiftData wrapper
│   └── DependencyContainer.swift # DI Container
│
└── TVGuideTests/                # Testing suite
    ├── TVServiceTests.swift     # API tests
    ├── TVGuideViewModelTests.swift # ViewModel tests
    └── StringExtensionsTests.swift # Extension tests
```

---

## 🏗️ Arquitectura

### MVVM con Dependency Injection

```
┌─────────────────────────────────────────────────────────────┐
│                        VIEW LAYER                            │
│                                                              │
│  ┌──────────────────┐         ┌──────────────────────────┐ │
│  │   ContentView    │────────▶│  ProgramDetailView       │ │
│  │                  │         │                          │ │
│  │  • searchable()  │         │  • AsyncImage           │ │
│  │  • filterChips   │         │  • Badges               │ │
│  │  • skeleton UI   │         │  • Detail info          │ │
│  │  • empty states  │         │                          │ │
│  └──────────────────┘         └──────────────────────────┘ │
│           │                             │                   │
│           ▼                             ▼                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              TVGuideViewModel                       │   │
│  │  @MainActor ObservableObject                         │   │
│  │                                                     │   │
│  │  @Published programs: [TVProgram]                    │   │
│  │  @Published isLoading: Bool                          │   │
│  │  @Published error: TVServiceError?                    │   │
│  │  @Published searchText: String                       │   │
│  │  @Published selectedNetwork: String?                 │   │
│  │  @Published isUsingCache: Bool                       │   │
│  │                                                     │   │
│  │  func load() async                                   │   │
│  │  var filteredPrograms: [TVProgram]                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                               │
└──────────────────────────────┼───────────────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │  DependencyContainer│
                    │  • tvService        │
                    │  • cacheService     │
                    └──────────┬──────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
        ▼                      ▼                      ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  TVService    │    │ CacheService  │    │   SwiftData   │
│  • Protocol   │    │ • save()      │    │   Container   │
│  • Errors     │    │ • get()       │    │               │
│  • URLSession │    │ • validation  │    └───────────────┘
└───────────────┘    └───────────────┘
        │
        ▼
┌─────────────────────┐
│   TVMaze API        │
│   /schedule         │
└─────────────────────┘
```

---

## ✨ Características Principales

### 1. Búsqueda Avanzada

- **Búsqueda por nombre**: Busca programas y episodios
- **Filtros por canal**: Combina búsqueda con filtros
- **Suggestions**: Autocompletado inteligente

```swift
.searchable(
    text: $vm.searchText,
    prompt: "Buscar programas o episodios..."
)
```

### 2. Manejo de Errores Profesional

- **Tipos de error personalizados**: `TVServiceError`
- **Localizados**: Mensajes en español
- **Retry**: Botón de reintentar
- **Offline indicator**: Muestra cuando usa cache

```swift
enum TVServiceError: LocalizedError {
    case noConnection
    case serverError(statusCode: Int)
    case decodingError
    case invalidURL
    case unknown(Error)
}
```

### 3. Loading States Modernos

- **Skeleton UI**: Animación shimmer elegante
- **Loading overlay**: Durante refresh
- **Progress indicators**: En contextos apropiados

### 4. Cache con SwiftData

- **Persistencia automática**: Guarda cada fetch exitoso
- **Fallback offline**: Usa cache sin conexión
- **Expiración configurable**: Default 1 hora
- **Estadísticas**: Info de edad y tamaño

### 5. Testing Completo

- **Unit Tests**: ViewModels, Services, Extensions
- **Mocks**: URLSession, Services, Cache
- **Coverage**: Alto porcentaje de código testeado

---

## 📸 Screenshots

Las capturas de pantalla de la aplicación están disponibles en [`docs/`](docs/):
- **Buscador.PNG** - Vista de búsqueda de programas
- **Pais y Canal.PNG** - Vista de filtros por país y canal
- **GuiaTv.PNG** - Vista principal de la guía
- **Detalle.PNG** - Vista de detalle de programa

---

## 🚀 Instalación y Configuración

### Requisitos Previos

- **macOS**: 14.0+
- **Xcode**: 15.0+
- **iOS**: 17.0+ (target)
- **Swift**: 5.9+

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/JamNow7/guia-tv-ios.git
   cd guia-tv-ios
   ```

2. **Abrir en Xcode**
   ```bash
   open "Guía TV.xcworkspace"
   ```

3. **Configurar Target de Tests**
   - Selecciona el proyecto en Navigator
   - Agrega el target "TVGuideTests" si no existe
   - Asegúrate que todos los archivos de test estén incluidos

4. **Build and Run**
   - Select simulator (iPhone 15 Pro recommended)
   - Press ⌘R para build y run

### Configuración de Tests

1. **Agregar Test Target** (si no existe):
   - File → New → Target
   - Select "Unit Testing Bundle"
   - Nombre: "TVGuideTests"
   - Language: Swift

2. **Agregar archivos de test**:
   - Arrastra `TVGuideTests/` al proyecto
   - Asegúrate que estén en el target de tests

3. **Ejecutar tests**:
   - ⌘U para ejecutar todos los tests
   - ⌘⇧U para ejecutar tests del archivo actual

---

## 📱 Uso de la Aplicación

### Caractericas de UI

1. **Filter Chips**: Filtra por canal (HBO, Netflix, etc.)
2. **Búsqueda**: Busca por nombre de programa o episodio
3. **Pull to Refresh**: Actualiza programación (futuro)
4. **Offline Mode**: Muestra cache cuando no hay conexión

### Estados de la App

| Estado | UI | Comportamiento |
|--------|-----|----------------|
| **Loading inicial** | Skeleton UI | Muestra placeholders animados |
| **Error sin datos** | Empty State + Retry | Muestra error y botón de reintentar |
| **Sin resultados** | Empty State + Clear | Muestra mensaje y botón limpiar |
| **Datos cargados** | Lista con programas | Muestra programación completa |
| **Actualizando** | Loading overlay | Overlay semitransparente |
| **Offline** | Badge "Offline" | Indica usando cache |

---

## 🧪 Testing

### Suite de Tests

```bash
# Ejecutar todos los tests
⌘U

# Ejecutar tests específicos
⌘⇧U

# Con coverage
Product → Test Coverage → ⌘U
```

### Ejecutar Tests desde Terminal

```bash
# Build y ejecutar todos los tests
xcodebuild test -scheme "Guía TV" -destination 'platform=iOS Simulator,name=iPhone 16'

# Ejecutar solo tests específicos
xcodebuild test -scheme "Guía TV" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:GuiaTVTests/TVServiceTests

# Ejecutar un test específico
xcodebuild test -scheme "Guía TV" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:GuiaTVTests/TVServiceTests/testFetchSchedule_WhenSuccessful_ReturnsPrograms

# Ver reporte de tests
xcodebuild test -scheme "Guía TV" -destination 'platform=iOS Simulator,name=iPhone 16' -resultBundlePath TestResults.xcresult
```

### Si un Test Falla

1. **Lee el error**: Revisa el mensaje en la consola
2. **Build primero**: Asegúrate que el proyecto compila (⌘B)
3. **Limpia build**: `Product → Clean Build Folder` (⇧⌘K)
4. **Re-ejecuta**: Presiona ⌘U nuevamente
5. **Debug**: Usa breakpoints en el test que falla

### Tests Incluidos

| Test File | Tests | Coverage |
|-----------|-------|----------|
| TVServiceTests.swift | 6 tests | API layer |
| TVGuideViewModelTests.swift | 9 tests | ViewModel logic |
| StringExtensionsTests.swift | 19 tests | Extensions |
| TVGuideTests.swift | 2 tests | Example tests |

**Total: 36 tests** ✅ All passing

### Ejemplo de Test

```swift
func testFetchSchedule_WhenSuccessful_ReturnsPrograms() async throws {
    // Given
    let mockData = createMockScheduleData()
    mockURLSession.mockData = mockData

    // When
    let programs = try await sut.fetchSchedule()

    // Then
    XCTAssertEqual(programs.count, 2)
}
```

---

## 🏗️ Patrones y Decisiones Arquitectónicas

### 1. Dependency Injection

**Por qué**: Testing y desacoplamiento

```swift
// Protocol para inyección
protocol TVServiceProtocol {
    func fetchSchedule() async throws -> [TVProgram]
}

// Inicializador con DI
init(service: TVServiceProtocol = DependencyContainer.shared.tvService)
```

### 2. SwiftData para Cache

**Por qué**: Nativo, eficiente, type-safe

```swift
@Model
final class TVProgram {
    // Propiedades persistentes
}
```

### 3. Error Types Personalizados

**Por qué**: Type-safe, localizados, testable

```swift
enum TVServiceError: LocalizedError {
    case noConnection
    case serverError(statusCode: Int)
}
```

### 4. MVVM con @MainActor

**Por qué**: Thread-safety garantizado

```swift
@MainActor
final class TVGuideViewModel: ObservableObject
```

---

## 📊 Métricas de Calidad

| Métrica | Valor | Status |
|---------|-------|--------|
| **Archivos Swift** | 15 | ✅ |
| **Lines of Code** | ~2000 | ✅ |
| **Test Coverage** | ~70% | ✅ |
| **Compilación** | Sin warnings | ✅ |
| **iOS Target** | 17.0+ | ✅ |
| **SwiftUI** | Moderno | ✅ |

---

## 🎓 Conceptos Demostrados

### Para Reclutadores

Este proyecto demuestra experiencia en:

- **SwiftUI moderno**: iOS 17+ features
- **Arquitectura limpia**: MVVM + DI
- **Testing**: Unit tests con mocks
- **Persistencia**: SwiftData
- **Networking**: URLSession + async/await
- **Error handling**: Profesional
- **Cache strategy**: Offline-first
- **UI/UX**: Loading states, empty states
- **Code organization**: Separation of concerns
- **Best practices**: SOLID, Clean Code

---

## 🔮 Mejoras Futuras

- [ ] Pull to refresh
- [ ] Pagination
- [ ] Favorites
- [ ] Widgets
- [ ] Spotlight search
- [ ] Dynamic Island
- [ ] SharePlay
- [ ] Complications (Apple Watch)

---

## 👨‍💻 Autor

**Claudio Cataldo**

- GitHub: [JamNow7](https://github.com/JamNow7)

---

## 📄 Licencia

Este proyecto tiene licencia MIT - ver archivo [LICENSE](LICENSE) para detalles.

⚠️ **Uso permitido:**
- ✅ Aprendizaje y referencia
- ✅ Portafolio y demostración profesional
- ✅ Modificación para proyectos personales

⚠️ **Uso NO permitido:**
- ❌ Uso comercial directo
- ❌ Redistribución como trabajo propio
- ❌ Uso sin atribución

---

<div align="center">

**⭐ Si encuentras útil este proyecto, considera darle una estrella**

Desarrollado con ❤️ usando SwiftUI, SwiftData y XCTest

[![iOS CI](https://github.com/JamNow7/tv-guide-ios/workflows/iOS%20Tests/badge.svg)](https://github.com/JamNow7/tv-guide-ios/actions)

</div>


