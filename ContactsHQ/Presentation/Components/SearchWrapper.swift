//
//  SearchWrapper.swift
//  Strive
//
//  Created by Mikael Weiss on 8/19/24.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import SwiftUI

struct SearchWrapper<T: View>: View {
    @State private var search = ""
    let content: (String) -> T

    var body: some View {
        content(search)
            .searchable(text: $search)
    }
}
