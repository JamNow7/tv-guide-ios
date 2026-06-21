//
//  CacheService.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//  Servicio de cache con SwiftData para persistencia local
//

import Foundation
import SwiftData

/// Servicio de cache que maneja persistencia local de programas
/// Permite mostrar datos offline y mejora performance
@MainActor
final class CacheService {

    // MARK: - Properties

    private let modelContext: ModelContext

    /// Timestamp de última actualización de cache
    private(set) var lastUpdateTime: Date?

    /// Duración máxima de cache en segundos (default: 1 hora)
    private let cacheExpiration: TimeInterval

    // MARK: - Initialization

    init(modelContext: ModelContext, cacheExpiration: TimeInterval = 3600) {
        self.modelContext = modelContext
        self.cacheExpiration = cacheExpiration
        self.lastUpdateTime = loadLastUpdateTime()
    }

    // MARK: - Public Methods

    /// Guarda programas en cache
    /// - Parameter programs: Programas a guardar
    func savePrograms(_ programs: [TVProgram]) {
        do {
            // Limpiar cache anterior
            try modelContext.delete(model: TVProgram.self)

            // Insertar nuevos programas
            for program in programs {
                modelContext.insert(program)
            }

            // Guardar cambios
            try modelContext.save()

            // Actualizar timestamp
            lastUpdateTime = Date()
            saveLastUpdateTime(Date())

            print("✅ Cache guardado: \(programs.count) programas")

        } catch {
            print("❌ Error guardando cache: \(error)")
        }
    }

    /// Obtiene programas desde cache
    /// - Returns: Array de programas en cache, o array vacío si no hay cache
    func getCachedPrograms() -> [TVProgram] {
        do {
            let descriptor = FetchDescriptor<TVProgram>(
                sortBy: [SortDescriptor(\TVProgram.airdate), SortDescriptor(\TVProgram.airtime)]
            )
            let programs = try modelContext.fetch(descriptor)

            print("📦 Cache recuperado: \(programs.count) programas")
            return programs

        } catch {
            print("❌ Error leyendo cache: \(error)")
            return []
        }
    }

    /// Verifica si existe cache válido
    /// - Returns: true si hay cache y no ha expirado
    var hasValidCache: Bool {
        guard let lastUpdate = lastUpdateTime else {
            return false
        }

        let isValid = Date().timeIntervalSince(lastUpdate) < cacheExpiration
        print("📋 Cache válido: \(isValid) (expira en \(Int(cacheExpiration - Date().timeIntervalSince(lastUpdate)))s)")

        return isValid
    }

    /// Verifica si existe cualquier cache (sin validar expiración)
    var hasCache: Bool {
        do {
            let descriptor = FetchDescriptor<TVProgram>()
            let count = try modelContext.fetchCount(descriptor)
            return count > 0
        } catch {
            return false
        }
    }

    /// Limpia todo el cache
    func clearCache() {
        do {
            try modelContext.delete(model: TVProgram.self)
            try modelContext.save()
            lastUpdateTime = nil
            saveLastUpdateTime(nil)

            print("🗑️ Cache limpiado")
        } catch {
            print("❌ Error limpiando cache: \(error)")
        }
    }

    /// Obtiene estadísticas del cache
    var cacheStats: (count: Int, age: TimeInterval?) {
        do {
            let descriptor = FetchDescriptor<TVProgram>()
            let count = try modelContext.fetchCount(descriptor)

            let age: TimeInterval? = lastUpdateTime.map { Date().timeIntervalSince($0) }

            return (count, age)
        } catch {
            return (0, nil)
        }
    }

    // MARK: - Private Methods

    /// Guarda timestamp de última actualización en UserDefaults
    private func saveLastUpdateTime(_ date: Date?) {
        UserDefaults.standard.set(date, forKey: "TVCacheLastUpdate")
    }

    /// Carga timestamp de última actualización desde UserDefaults
    private func loadLastUpdateTime() -> Date? {
        UserDefaults.standard.object(forKey: "TVCacheLastUpdate") as? Date
    }
}

// MARK: - Cache Statistics Extension

extension CacheService {
    /// Descripción legible de estadísticas del cache
    var cacheDescription: String {
        let stats = cacheStats

        var description = "Programas en cache: \(stats.count)"

        if let age = stats.age {
            let minutes = Int(age / 60)
            if minutes < 60 {
                description += "\nActualizado hace: \(minutes)m"
            } else {
                let hours = minutes / 60
                description += "\nActualizado hace: \(hours)h"
            }
        }

        return description
    }
}
