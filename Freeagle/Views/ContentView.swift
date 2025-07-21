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
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
