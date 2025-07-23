//
//  EventDetailView2.swift
//  Freeagle
//
//  Created by Gabriele Zito on 23/07/25.
//

import SwiftUI

struct EventDetailView2: View {
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
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 50, height: 50)
                            .font(.system(size: 30, weight: .bold))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.blue, style: StrokeStyle(lineWidth: 4)))
                        
                        
                        
                    }
                    .frame(maxWidth:.infinity, alignment: .trailing)
                    .padding(.trailing, 30)
                    .padding(.top, 40)
                }
                Spacer()
                    .frame(height: 20)
                ScrollView {
                    Text("Details")
                        .font(.headline)
                    
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit varius nulla, sed vehicula lacus hendrerit nec. Nam augue nunc, dapibus et luctus eu, facilisis a ligula. Ut eget orci lacinia nulla elementum varius. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer egestas lectus id auctor congue. Donec consequat odio at euismod convallis. Vivamus vitae justo dapibus, ornare sapien id, molestie purus. Suspendisse gravida interdum hendrerit. Suspendisse potenti. Ut faucibus enim in ex sollicitudin, varius luctus diam vestibulum. Curabitur fringilla orci risus. Donec id iaculis felis, et tincidunt mauris..")
                    
                    Spacer()
                    
                    
                }
                
                NavigationStack {
                List{
                    ForEach(1...5, id: \.self){ index in
                        HStack{
                            Text("Item \(index)")
                            
                        }
                            
                        }
                    }
                }
                .padding()
                
            }
        }
}

#Preview {
    EventDetailView2()
}
