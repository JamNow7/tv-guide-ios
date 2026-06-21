//
//  GuiaTVApp.swift
//  Guía TV
//
//  Created by Claudio Cataldo on 19-06-26.
//  App entry point con configuración de SwiftData
//

import SwiftUI
import SwiftData

@main
struct GuiaTVApp: App {

    // MARK: - SwiftData Container

    /// Contenedor de SwiftData para persistencia local
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([TVProgram.self])

        do {
            return try ModelContainer(
                for: schema
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
