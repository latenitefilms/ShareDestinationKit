//
//  ShareDestinationKitApp.swift
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

import Cocoa
import SwiftUI
import Foundation
import AVFoundation
import UniformTypeIdentifiers

@main
struct ShareDestinationKitApp: App {
    @NSApplicationDelegateAdaptor(ApplicationDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 700, height: 180)
        }
        .windowResizabilityContentSize()
    }
}

class ApplicationDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            // ------------------------------------------------------------
            // Media File & FCPXML Received:
            // ------------------------------------------------------------
            NSLog("File Received: \(url.path)")

            // ------------------------------------------------------------
            // Create an alert:
            // ------------------------------------------------------------
            let alert = NSAlert()
            alert.messageText = "File Received"
            alert.informativeText = "File Received: \(url.path)"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")

            // ------------------------------------------------------------
            // Display the alert:
            // ------------------------------------------------------------
            alert.runModal()
        }
    }
}

struct AppIconView: View {
    var body: some View {
        Image(nsImage: NSImage(named: "AppIcon")!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150)
    }
}

struct MainTextView: View {
    var body: some View {
        Text("ShareDestinationKit's Custom Share Destination has now been installed.\n\nYou can now select ShareDestinationKit as an 'action' in the Final Cut Pro Destinations panel.")
            .font(.body)
            .foregroundColor(.primary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(4)
    }
}

struct LaunchFCPButton: View {
    var body: some View {
        Button("Launch Final Cut Pro") {
            if let fcpURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.FinalCut") {
                NSWorkspace.shared.open(fcpURL)
                //NSApplication.shared.terminate(nil)
            }
        }
        .padding(.top)
    }
}

struct NewCollection: View {
    var body: some View {
        Button("New Collection") {
            NSLog("[ShareDestinationKit] Opening a New Collection...")
            let documentController = NSDocumentController.shared
            documentController.newDocument(self)
        }
        .padding(.top)
    }
}


struct ContentView: View {
    var body: some View {
        HStack {
            AppIconView()
                .padding()
            Spacer()
            VStack(alignment: .leading) {
                MainTextView()
                HStack {
                    NewCollection()
                    LaunchFCPButton()
                }
            }.padding()
        }
        .preferredColorScheme(.dark)
    }
}

extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}
