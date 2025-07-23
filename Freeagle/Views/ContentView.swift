//
//  ContentView.swift
//  Freeagle
//
//  Created by Gabriele Zito on 19/07/25.
//

import SwiftUI

// controllo se nickname è presente in userdefaults
// se si -> ListView
// se no -> LoginView

struct ContentView: View {
    
    @State private var isLoggedIn: Bool = false
    @State private var isLoading: Bool = true
    
    var body: some View {
        VStack{
            if isLoading{
                Text("Loading...")
            }else if isLoggedIn{
                MainView()
            }else {
                LoginView()
            }
        }.onAppear{
            checkUserStatus()
        }

    }
    
    private func checkUserStatus(){
        isLoggedIn = UserDefaults.standard.string(forKey: "username") != nil
        isLoading = false
    }
    
}

#Preview {
    ContentView()
}
