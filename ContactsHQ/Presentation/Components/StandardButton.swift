//
//  StandardButton.swift
//  Strive
//
//  Created by Mikael Weiss on 10/21/23.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import SwiftUI

struct StandardButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.accentColor)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .overlay(
                    Text(title.uppercased())
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.background)
                )
        }
    }
}
#Preview {
    StandardButton(title: "Test", action: {})
}
