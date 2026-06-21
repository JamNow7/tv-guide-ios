//
//  DependencyContainer.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//  Container de inyección de dependencias para testing y configuración
//

import Foundation

/// Protocolo para abstracción del servicio de TV
/// Permite mockear en tests y cambiar implementación sin afectar ViewModels
protocol TVServiceProtocol {
    func fetchSchedule() async throws -> [TVProgram]
}

/// Contenedor de dependencias de la aplicación
/// Implementa patrón Singleton para acceso global
final class DependencyContainer {

    // MARK: - Singleton

    static let shared = DependencyContainer()

    // MARK: - Services

    /// Servicio principal de TV
    /// Inyectado en ViewModels para permitir testing con mocks
    lazy var tvService: TVServiceProtocol = {
        return TVService()
    }()

    // MARK: - Initialization

    private init() {}
}
