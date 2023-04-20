//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Ivan Trajanovski on 20.04.23.
//

import SwiftUI

@main
struct HabitTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
