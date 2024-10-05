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
    @Bindable private var manager = LocationManager.shared
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var searchResults = [MKMapItem]()
    @Binding var markers: [MarkerInfo]
    @State var selectedMarker: UUID?
    @State private var search = ""
    
    var body: some View {
        NavigationStack {
            Map(position: $position, selection: $selectedMarker) {
                ForEach(markers) { marker in
                    switch marker.typeOfMarker {
                        case .person:
                            Marker("Friend", systemImage: "person.fill", coordinate: marker.location)
                                .tag(marker.id)
                        case .meta:
                            Marker("Meta", systemImage: "mountain.2.fill", coordinate: marker.location)
                                .tag(marker.id)
                    }
                    
                    Annotation("Friend", coordinate: marker.location, anchor: .bottom) {
                        // Image of person with dot matching type
                        // No image == dot matching type
                    }
                }
                
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onChange(of: selectedMarker) { oldValue, newValue in
                markers.forEach { markerInfo in
                    if markerInfo.id == newValue {
                        markerInfo.onTap()
                    }
                }
            }
            .onChange(of: searchResults) { oldValue, newValue in
                position = .automatic
            }
            .navigationTitle("Map")
            .searchable(text: $search)
            .onAppear {
                LocationManager.shared.requestLocation()
            }
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
