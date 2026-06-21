//
//  TVGuideViewModel.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//  ViewModel con DI, error handling, búsqueda y cache
//

import Foundation
import SwiftData

@MainActor
final class TVGuideViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Lista completa de programas cargados
    @Published var programs: [TVProgram] = []

    /// Estado de carga actual
    @Published var isLoading = false

    /// Error actual si existe
    @Published var error: TVServiceError?

    /// Canal/filtro actualmente seleccionado (nil = todos)
    @Published var selectedNetwork: String? = nil

    /// Lista de canales disponibles extraídos de los programas
    @Published var availableNetworks: [String] = []

    /// Texto de búsqueda actual
    @Published var searchText: String = ""

    /// Indica si los datos mostrados vienen de cache
    @Published var isUsingCache = false

    /// Mensaje informativo sobre el estado del cache
    @Published var cacheStatusMessage: String?

    // MARK: - Dependencies

    private let service: TVServiceProtocol
    private let cacheService: CacheService?

    // MARK: - Computed Properties

    /// Programas filtrados por búsqueda y selección de canal
    var filteredPrograms: [TVProgram] {
        var result = programs

        // 1. Filtrar por búsqueda de texto
        if !searchText.isEmpty {
            let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
            result = result.filter { program in
                program.name.lowercased().contains(query) ||
                program.showName.lowercased().contains(query)
            }
        }

        // 2. Filtrar por canal seleccionado
        if let network = selectedNetwork {
            result = result.filter { $0.networkName == network }
        }

        return result
    }

    /// Indica si hay resultados después de filtrar
    var hasFilteredResults: Bool {
        !filteredPrograms.isEmpty
    }

    /// Mensaje de estado actual para la UI
    var statusMessage: String? {
        if isLoading {
            return "Cargando programación..."
        }

        if let error = error {
            return error.errorDescription
        }

        if !hasFilteredResults && !searchText.isEmpty {
            return "No se encontraron programas que coincidan con \"\(searchText)\""
        }

        if !hasFilteredResults && selectedNetwork != nil {
            return "No hay programas para este canal"
        }

        return nil
    }

    // MARK: - Initialization

    /// Inicializador con inyección de dependencia
    /// - Parameters:
    ///   - service: Servicio de TV
    ///   - cacheService: Servicio de cache opcional
    init(
        service: TVServiceProtocol,
        cacheService: CacheService? = nil
    ) {
        self.service = service
        self.cacheService = cacheService
    }

    // MARK: - Public Methods

    /// Carga la programación desde la API o cache
    func load() async {
        isLoading = true
        error = nil

        do {
            // Intentar fetch desde API
            let fetchedPrograms = try await service.fetchSchedule()

            // Guardar en cache si existe
            cacheService?.savePrograms(fetchedPrograms)

            // Actualizar estado
            programs = fetchedPrograms
            isUsingCache = false
            extractAvailableNetworks()

        } catch let tvError as TVServiceError {
            // Si falla API, intentar usar cache
            if let cachedPrograms = cacheService?.getCachedPrograms(), !cachedPrograms.isEmpty {
                programs = cachedPrograms
                isUsingCache = true
                extractAvailableNetworks()
                self.error = tvError // Mantener el error para mostrar estado offline
            } else {
                self.error = tvError
            }
        } catch {
            self.error = TVServiceError(from: error)
        }

        isLoading = false
        updateCacheStatus()
    }

    /// Reintenta la carga después de un error
    func retry() {
        Task { @MainActor in
            await load()
        }
    }

    /// Limpia todos los filtros
    func clearFilters() {
        selectedNetwork = nil
        searchText = ""
    }

    /// Limpia solo el texto de búsqueda
    func clearSearch() {
        searchText = ""
    }

    /// Limpia el cache manualmente
    func clearCache() {
        cacheService?.clearCache()
        cacheStatusMessage = "Cache limpiado"
    }

    /// Fuerza recarga desde API ignorando cache
    func forceRefresh() async {
        await load()
    }

    // MARK: - Private Methods

    /// Extrae y ordena los canales disponibles de los programas cargados
    private func extractAvailableNetworks() {
        availableNetworks = Array(Set(programs.compactMap { $0.networkName }))
            .sorted()
    }

    /// Actualiza el mensaje de estado del cache
    private func updateCacheStatus() {
        if let cacheService = cacheService {
            if cacheService.hasValidCache {
                let stats = cacheService.cacheStats
                if let age = stats.age, age > 0 {
                    let minutes = Int(age / 60)
                    cacheStatusMessage = "Cache actualizado hace \(minutes)m"
                } else {
                    cacheStatusMessage = "Cache actualizado recientemente"
                }
            } else {
                cacheStatusMessage = nil
            }
        }
    }
}
