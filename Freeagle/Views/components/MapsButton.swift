//
//  MapsButton.swift
//  Freeagle
//
//  Created by Gabriele Zito on 28/07/25.
//
import SwiftUI
import MapKit

struct OpenInMapsButton: View {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees

    var body: some View {
        Button(action: {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Destination"
            mapItem.openInMaps(launchOptions: nil)
        }) {
            Image(systemName: "map")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                //.frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .cornerRadius(12)
                .shadow(radius: 4)
        }
        .padding(.horizontal)
    }
}
