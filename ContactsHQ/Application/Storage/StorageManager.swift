//
//  StorageManager.swift
//  Strive
//
//  Created by Mikael Weiss on 4/18/24.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import Foundation
import SwiftData
import Combine

@MainActor
class StorageManager {
    
    static let shared = StorageManager()
    
    let container: ModelContainer
    
    var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        do {
            container = try ModelContainer(for: Person.self)
        } catch {
            fatalError("Could not initialize the data model container.")
        }
    }
    
    /// Listening to changes
    /// For now this'll be how views refresh when models are inserted or deleted.
    var didChange = PassthroughSubject<Void, Never>()
}

extension StorageManager {
    func insert<T>(_ model: T) where T: PersistentModel {
        mainContext.insert(model)
        try? mainContext.save()
        didChange.send()
    }
    
    func fetch<T>(_ descriptor: FetchDescriptor<T>) -> [T] where T: PersistentModel {
        let models = try? mainContext.fetch(descriptor)
        return models ?? []
    }
    
    func delete<T>(_ model: T) where T: PersistentModel {
        mainContext.delete(model)
        try? mainContext.save()
        didChange.send()
    }
    
    func save() throws {
        try mainContext.save()
    }
}
