//
//  ParkinsonHelperApp.swift
//  ParkinsonHelper
//
//  Created by Mark on 4/9/25.
//

import SwiftUI

@main
struct ParkinsonHelperApp: App {
    @StateObject private var scheduleManager = ScheduleManager()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LanguageControllerView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(scheduleManager)
        }
    }
}
