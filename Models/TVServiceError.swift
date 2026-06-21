//
//  TVServiceError.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//  Error types profesionales para manejo de errores en capa de servicio
//

import Foundation

/// Tipos de error específicos del servicio de TV
enum TVServiceError: LocalizedError, Equatable {
    case noConnection
    case serverError(statusCode: Int)
    case decodingError
    case invalidURL
    case unknown(Error)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No hay conexión a internet"
        case .serverError(let code):
            return "Error del servidor (código \(code))"
        case .decodingError:
            return "Error al procesar los datos del servidor"
        case .invalidURL:
            return "URL de configuración inválida"
        case .unknown(let error):
            return "Error inesperado: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noConnection:
            return "Verifica tu conexión Wi-Fi o datos móviles e intenta nuevamente"
        case .serverError(let code) where (500...599).contains(code):
            return "El servidor está experimentando problemas. Intenta más tarde"
        case .serverError:
            return "Intenta nuevamente en unos momentos"
        case .decodingError:
            return "Si el problema persiste, contacta soporte"
        case .invalidURL:
            return "Verifica la configuración de la aplicación"
        case .unknown:
            return "Si el problema continúa, reinicia la aplicación"
        }
    }

    // MARK: - Equatable

    static func == (lhs: TVServiceError, rhs: TVServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.noConnection, .noConnection),
             (.decodingError, .decodingError),
             (.invalidURL, .invalidURL):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }

    // MARK: - Convenience Initializers

    init(from error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                self = .noConnection
            default:
                self = .unknown(urlError)
            }
        } else if error is DecodingError {
            self = .decodingError
        } else {
            self = .unknown(error)
        }
    }
}

// MARK: - Helper Extensions

extension Error {
    /// Convierte Error genérico a TVServiceError cuando es posible
    var asTVServiceError: TVServiceError {
        if let tvError = self as? TVServiceError {
            return tvError
        }
        return TVServiceError(from: self)
    }
}
