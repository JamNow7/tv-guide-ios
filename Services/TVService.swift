//
//  TVService.swift
//  Guía TV
//
//  Servicio de API con manejo de errores profesional y DI
//

import Foundation

// MARK: - Protocol para testabilidad

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// Servicio principal para obtener datos de TV desde TVMaze API
final class TVService: TVServiceProtocol {

    // MARK: - Configuration

    private static let baseURL = "https://api.tvmaze.com/schedule"
    private static let timeout: TimeInterval = 10.0

    /// Session abstracta (mockeable)
    private let session: URLSessionProtocol

    // MARK: - Initialization

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    // MARK: - Public Methods

    func fetchSchedule() async throws -> [TVProgram] {

        guard let url = URL(string: Self.baseURL) else {
            throw TVServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TVServiceError.unknown(URLError(.badServerResponse))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw TVServiceError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            let rawItems = try decoder.decode([TVMazeScheduleItem].self, from: data)
            return rawItems.map { TVProgram(from: $0) }

        } catch {
            throw TVServiceError.decodingError
        }
    }
}
