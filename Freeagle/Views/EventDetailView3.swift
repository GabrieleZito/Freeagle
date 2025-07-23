//
//  EventDetailView3.swift
//  Freeagle
//
//  Created by Gabriele Zito on 23/07/25.
//

import SwiftUI

struct EventDetailView3: View {
    var body: some View {
            VStack {
                Spacer()
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 25)
                        Text("Back")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                }
                HStack() {
                    Group {
                        Image("palermo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 180, height: 180)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 10)
                        
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Spacer()
                        
                        Text("Event Name")
                            .font(.headline)
                        Spacer()
                            .frame(height: 1)
                        Text("Event Place")
                            .font(.headline)
                        Spacer()
                            .frame(height: 1)
                        Text("Event Date")
                            .font(.headline)
                        Spacer()
                            .frame(height: 1)
                        Text("Event Price")
                            .font(.headline)
                        Spacer()
                            .frame(height: 1)
                        Spacer()
                    }
                    .frame(height: 180)
                    .padding(.horizontal, 5)
                    Spacer()
                }
                VStack {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "checkmark")
                                .frame(width: 50, height: 50)
                                .font(.system(size: 30, weight: .bold))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.blue, style: StrokeStyle(lineWidth: 4))) }
                        .frame(maxWidth:.infinity, alignment: .leading)
                        .padding(.leading, 250)
                        .padding(.top, 5)
                        Button(action: {}) {
                            Image(systemName: "xmark")
                                .frame(width: 50, height: 50)
                                .font(.system(size: 30, weight: .bold))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.blue, style: StrokeStyle(lineWidth: 4))) }
                                
                            .frame(maxWidth:.infinity, alignment: .leading)
                            .padding(.leading, 5)
                            .padding(.top, 5)
                        }
                    
                    Spacer()
                        .frame(height: 20)
                    ScrollView {
                        Text("Details")
                            .font(.headline)
                        
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Lorem ipsum dolor sit amet. Qui minus explicabo ex ducimus mollitia aut praesentium...")
                        
                    }
                }
                .padding()
            }
        }
}

#Preview {
    EventDetailView3()
}
