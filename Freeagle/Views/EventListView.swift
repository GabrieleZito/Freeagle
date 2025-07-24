//
//  EventListView.swift
//  Freeagle
//
//  Created by Gabriele Zito on 21/07/25.
//

import SwiftUI

struct EventListView: View {
    var username = UserDefaults.standard.object(forKey: "username")
    
    var body: some View {
        
        VStack{
            Text("EventListView")
            Text("username: \(username ?? "")")
        }
        
    }
}

#Preview {
    EventListView()
}
