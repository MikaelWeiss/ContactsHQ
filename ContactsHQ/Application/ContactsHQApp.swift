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

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .fontDesign(.rounded)
        }
        .modelContainer(StorageManager.shared.container)
    }
}
