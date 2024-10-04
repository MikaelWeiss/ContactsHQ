//
//  MapView.swift
//  Strive
//
//  Created by Mikael Weiss on 6/7/24.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var markers: [MarkerInfo]
    @State var selectedMarker: UUID?
    
    var body: some View {
        NavigationStack {
            Map(selection: $selectedMarker) {
                ForEach(markers) { marker in
                    switch marker.typeOfMarker {
                        case .person:
                            Marker("Friend", systemImage: "person.fill", coordinate: marker.location)
                                .tag(marker.id)
                        case .meta:
                            Marker("Meta", systemImage: "mountain.2.fill", coordinate: marker.location)
                                .tag(marker.id)
                    }
                }
            }
            .onChange(of: selectedMarker) { oldValue, newValue in
                markers.forEach { markerInfo in
                    if markerInfo.id == newValue {
                        markerInfo.onTap()
                    }
                }
            }
            .navigationTitle("Map")
        }
    }
    
    struct MarkerInfo: Identifiable {
        let id = UUID()
        let typeOfMarker: TypeOfMarker
        let location: CLLocationCoordinate2D
        let onTap: () -> Void
        
        enum TypeOfMarker {
            case person, meta
        }
    }
}

#Preview {
    MapView(
        markers: .constant([
            .init(typeOfMarker: .person, location: .init(latitude: 40.77044, longitude: 111.89187), onTap: {}),
            .init(typeOfMarker: .meta, location: .init(latitude: 41.77044, longitude: 112.89187), onTap: {}),
            .init(typeOfMarker: .meta, location: .init(latitude: 40.77044, longitude: 113.89187), onTap: {}),
            .init(typeOfMarker: .person, location: .init(latitude: 41.77044, longitude: 114.89187), onTap: {})
        ]))
}
