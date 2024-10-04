//
//  ViewPersonTimeline.swift
//  Strive
//
//  Created by Mikael Weiss on 8/16/24.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import SwiftUI

struct ViewPersonTimeline: View {
    let person: Person
    
    var body: some View {
        Text("Timeline coming soon...")
    }
}

#Preview {
    ViewPersonTimeline(person: Person(givenName: "asdf", type: .acquaintance))
}
