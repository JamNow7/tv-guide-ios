//
//  EmptyStateView.swift
//  Guía TV
//
//  Created por Claudio Cataldo on 19-06-26.
//  Vista de estado vacío con diferentes tipos de mensajes y acciones
//

import SwiftUI

/// Vista de estado vacío que maneja diferentes escenarios:
/// - Sin conexión a internet
/// - Error del servidor
/// - Sin resultados de búsqueda
/// - Datos no disponibles
struct EmptyStateView: View {
    // MARK: - Properties

    /// Error actual si existe
    let error: TVServiceError?

    /// Acción a ejecutar al presionar retry
    let onRetry: () -> Void

    /// Acción para limpiar filtros/búsqueda
    let onClearFilters: (() -> Void)?

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icono según tipo de estado
            iconView
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            // Título
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            // Mensaje de detalle
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Botones de acción
            actionButtons

            Spacer()
        }
        .padding()
    }

    // MARK: - Subviews

    /// Icono según el tipo de error o estado
    @ViewBuilder
    private var iconView: some View {
        Group {
            switch error {
            case .noConnection:
                Image(systemName: "wifi.slash")
            case .serverError:
                Image(systemName: "server.disconnect")
            case .decodingError, .invalidURL:
                Image(systemName: "exclamationmark.triangle")
            case .unknown:
                Image(systemName: "exclamationmark.circle")
            case nil:
                Image(systemName: "magnifyingglass")
            }
        }
        .symbolEffect(.bounce, value: error)
    }

    /// Título según el estado
    private var title: String {
        if let error = error {
            switch error {
            case .noConnection:
                return "Sin Conexión"
            case .serverError:
                return "Error del Servidor"
            case .decodingError:
                return "Error de Datos"
            case .invalidURL:
                return "Error de Configuración"
            case .unknown:
                return "Algo Salió Mal"
            }
        } else {
            return "Sin Resultados"
        }
    }

    /// Mensaje detallado según el estado
    private var message: String {
        if let error = error {
            return error.errorDescription ?? ""
        } else {
            return "No se encontraron programas que coincidan con tu búsqueda o filtro actual."
        }
    }

    /// Botones de acción según el estado
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Botón de retry si hay error
            if error != nil {
                Button(action: onRetry) {
                    Label(
                        title: { Text("Reintentar") },
                        icon: { Image(systemName: "arrow.clockwise") }
                    )
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }

            // Botón para limpiar filtros
            if onClearFilters != nil && error == nil {
                Button(action: {
                    onClearFilters?()
                }) {
                    Text("Limpiar Filtros")
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

extension EmptyStateView {
    /// Inicializador para error con retry
    init(error: TVServiceError, onRetry: @escaping () -> Void) {
        self.error = error
        self.onRetry = onRetry
        self.onClearFilters = nil
    }

    /// Inicializador para sin resultados con acción opcional
    init(onRetry: @escaping () -> Void, onClearFilters: (() -> Void)? = nil) {
        self.error = nil
        self.onRetry = onRetry
        self.onClearFilters = onClearFilters
    }
}

// MARK: - Preview

#Preview {
    EmptyStateView(error: TVServiceError.noConnection) {
        print("Retry tapped")
    }
}
