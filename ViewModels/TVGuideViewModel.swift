//
//  TVGuideViewModel.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//

import Foundation

@MainActor
final class TVGuideViewModel: ObservableObject {
    @Published var programs: [TVProgram] = []
    @Published var isLoading = false
    @Published var selectedNetwork: String? = nil
    @Published var availableNetworks: [String] = []

    private let service = TVService()

    var filteredPrograms: [TVProgram] {
        if let network = selectedNetwork {
            return programs.filter { $0.networkName == network }
        }
        return programs
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            programs = try await service.fetchSchedule()
            // Extraer networks únicos
            availableNetworks = Array(Set(programs.compactMap { $0.networkName })).sorted()
            print("Cargados \(programs.count) programas")
            print("Canales disponibles: \(availableNetworks.count)")
            if let first = programs.first {
                print("Primer programa: \(first.name) - \(first.showName)")
            }
        } catch {
            print("Error:", error)
        }
    }
}
