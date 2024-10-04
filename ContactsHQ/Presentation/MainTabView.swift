//
//  MainTabView.swift
//  ContactsHQ
//
//  Created by Mikael Weiss on 10/3/24.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @Query var people: [Person]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            if people.count == 0 {
                ViewPeople(search: "")
                    .tabItem {
                        Image(systemName: "person.crop.circle.fill")
                        Text("People")
                    }
                    .tag(0)
            } else {
                SearchWrapper {
                    ViewPeople(search: $0)
                }
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("People")
                }
                .tag(0)
            }
            Text("Maps View")
                .tabItem {
                    Image(systemName: "map.circle.fill")
                    Text("Map")
                }
                .tag(1)
//            MapsView()
        }
    }
}

#Preview {
    MainTabView()
}
