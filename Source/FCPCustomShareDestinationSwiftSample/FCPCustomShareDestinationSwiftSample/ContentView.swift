//
//  ContentView.swift
//  FCPCustomShareDestinationSwiftSample
//
//  Created by Chris Hocking on 10/12/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "film.stack")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding()
            
            Text("Receiving Media and Data Through a Custom Share Destination Sample")
                .fontWeight(.bold)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
