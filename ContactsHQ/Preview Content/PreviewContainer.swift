//
//  PreviewContainer.swift
//  Strive
//
//  Created by Mikael Weiss on 11/11/23.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import SwiftData

extension ModelContainer {
    @MainActor
    static func previewContainer() -> ModelContainer {
        let modelContainer = try! ModelContainer(
            for: Person.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
//        let modelContext = modelContainer.mainContext
//        if try! modelContext.fetch(FetchDescriptor<Person>()).isEmpty {
//            PreviewData.samplePeople.forEach { modelContext.insert($0) }
//        }
        return modelContainer
    }
}
