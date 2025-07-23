//
//  EventDetailView.swift
//  Freeagle
//
//  Created by Gabriele Zito on 21/07/25.
//

import SwiftUI

struct EventDetailView: View {
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
                        Text("Lorem ipsum dolor sit amet. Qui minus explicabo ex ducimus mollitia aut praesentium culpa eos ipsa cupiditate et quod alias et corrupti asperiores hic esse aspernatur. Et voluptas quam aut voluptates rerum ut possimus repudiandae sed aliquid earum est labore commodi rem dolorem blanditiis. Sed nobis voluptates eum deserunt quae et esse velit eum placeat veritatis ut repellat numquam aut nobis labore. Eos culpa eveniet sed vitae galisum qui dolor dolorum aut perferendis adipisci et distinctio maxime ex praesentium maiores est tempora voluptatem? Quo aperiam maiores est natus ullam rem animi voluptate aut suscipit assumenda ea voluptatem dolor et voluptate maiores! Ad optio nihil rem corrupti rerum ut laudantium deleniti et magnam commodi..")

                            
                    }
                }
                .padding()
            
        }
}

#Preview {
    EventDetailView()
}
