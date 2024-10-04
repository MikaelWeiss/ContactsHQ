//
//  ContactsHQApp.swift
//  ContactsHQ
//
//  Created by Mikael Weiss on 10/3/24.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct ContactsHQApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Person.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
