//
//  EventCardGroups.swift
//  Freeagle
//
//  Created by Gabriele Zito on 28/07/25.
//

import SwiftUI

struct EventCardGroups: View {
    let event: Event
    
    var body: some View {
        NavigationLink(destination: EventDetailView2(event: event)){
            HStack(spacing: 16) {
                // Immagine con shadow e corner radius
                Image(event.category)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 90)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Contenuto testuale
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("Palermo, Sicily")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                // Freccia indicatore
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )

        }
    }
}
