//
//  FCPCustomShareDestinationSwiftSampleApp.swift
//  FCPCustomShareDestinationSwiftSample
//
//  Created by Chris Hocking on 10/12/2023.
//

import Cocoa
import SwiftUI
import Foundation

@main
struct FCPCustomShareDestinationSwiftSampleApp: App {
    var appleEventHandler = AppleEventHandler()

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
    }
}

class AppleEventHandler: NSObject {
    override init() {
        super.init()
        setupAppleEventHandlers()
    }

    private func setupAppleEventHandlers() {
        let eventManager = NSAppleEventManager.shared()
        let eventClass = AEEventClass(kCoreEventClass)
        
        eventManager.setEventHandler(self,
                                     andSelector: #selector(handleCreateAssetEvent(_:withReplyEvent:)),
                                     forEventClass: eventClass,
                                     andEventID: AEEventID(kAECreateElement))
        
        eventManager.setEventHandler(self,
                                     andSelector: #selector(handleGetLocationInfoEvent(_:withReplyEvent:)),
                                     forEventClass: eventClass,
                                     andEventID: AEEventID(kAEGetData))

        // Set up handlers for other Apple Events
        // Add more event handlers here as per documentation...
    }

    @objc func handleCreateAssetEvent(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        NSLog("Create Asset Event Received")
        // Process the received event and extract necessary data
        // Respond back to Final Cut Pro
        // Example: Extract asset name and log it
        // ...

        // Example response to Final Cut Pro
        let replyRecord = NSAppleEventDescriptor.record()
        // Populate the replyRecord with the necessary response
        reply.setDescriptor(replyRecord, forKeyword: keyDirectObject)
    }

    @objc func handleGetLocationInfoEvent(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        NSLog("Get Location Info Event Received")
        // Process the received event and extract necessary data
        // Respond back to Final Cut Pro
        // Example: Extract location info and log it
        // ...

        // Example response to Final Cut Pro
        let replyRecord = NSAppleEventDescriptor.record()
        // Populate the replyRecord with the necessary response
        reply.setDescriptor(replyRecord, forKeyword: keyDirectObject)
    }

    // Implement other handlers for different Apple Events
    // ...

    // Helper functions...
    private func fourCharCode(from string: String) -> AEKeyword {
        var result: UInt32 = 0
        if let data = string.data(using: .macOSRoman, allowLossyConversion: true) {
            for i in 0..<min(4, data.count) {
                result = result << 8 + UInt32(data[i])
            }
        }
        return result
    }
}
