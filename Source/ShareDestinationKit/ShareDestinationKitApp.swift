//
//  ShareDestinationKitApp.swift
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

import Cocoa
import SwiftUI
import Foundation

@main
struct ShareDestinationKitApp: App {
    @NSApplicationDelegateAdaptor(ApplicationDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

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
        .preferredColorScheme(.dark)
    }
}
