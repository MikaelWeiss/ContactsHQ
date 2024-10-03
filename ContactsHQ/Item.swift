//
//  Item.swift
//  ContactsHQ
//
//  Created by Mikael Weiss on 10/3/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
