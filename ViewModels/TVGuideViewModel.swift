//
//  TVGuideViewModel.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//

import Foundation

@MainActor
final class TVGuideViewModel: ObservableObject {
    @Published var programs: [TVProgram] = []
    @Published var isLoading = false
    
    private let service = TVService()
    
    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            programs = try await service.fetchSchedule()
            print(" Cargados \(programs.count) programas")
            if let first = programs.first {
                print("Primer programa: \(first.name) - \(first.showName)")
            }
        } catch {
            print(" Error:", error)
        }
    }
}
