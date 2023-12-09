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
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
        .preferredColorScheme(.dark)
    }
}

class AppleEventHandler: NSObject {
    // Placeholder for storing asset information
    var assets: [String: Asset] = [:]

    override init() {
        NSLog("Initializing AppleEventHandler")
        super.init()
        setupAppleEventHandlers()
    }

    private func setupAppleEventHandlers() {
        NSLog("setupAppleEventHandlers triggered")
        
        // Register handlers for various Apple Events
        registerHandler(forEventID: kAECreateElement, selector: #selector(handleCreateAssetEvent(_:withReplyEvent:)))
        registerHandler(forEventID: kAEGetData, selector: #selector(handleGetLocationInfoEvent(_:withReplyEvent:)))
        registerHandler(forEventID: kAEGetData, selector: #selector(handleGetLibraryInfoEvent(_:withReplyEvent:)))
        registerHandler(forEventID: kAEGetData, selector: #selector(handleGetMetadataEvent(_:withReplyEvent:)))
        registerHandler(forEventID: kAEGetData, selector: #selector(handleGetDataOptionsEvent(_:withReplyEvent:)))
        registerHandler(forEventID: kAEOpenDocuments, selector: #selector(handleOpenDocumentEvent(_:withReplyEvent:)))
    }

    private func registerHandler(forEventID eventID: AEEventID, selector: Selector) {
        NSAppleEventManager.shared().setEventHandler(self,
                                                     andSelector: selector,
                                                     forEventClass: AEEventClass(kCoreEventClass),
                                                     andEventID: AEEventID(eventID))
    }

    @objc func handleCreateAssetEvent(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        DispatchQueue.global(qos: .userInitiated).async {
            NSLog("Create Asset Event Received")
            
            // Extract details from event and create a placeholder asset
            let assetName = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue ?? "Unknown"
            let asset = Asset(name: assetName)
            self.assets[assetName] = asset

            // Respond with the placeholder asset
            // TODO: Send the appropriate reply
            NSLog("Asset created with name: \(assetName)")
        }
    }

    @objc func handleGetLocationInfoEvent(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        DispatchQueue.global(qos: .userInitiated).async {
            NSLog("Get Location Info Event Received")
            // TODO: Extract asset information and handle the event
        }
    }

    @objc func handleGetLibraryInfoEvent(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        DispatchQueue.global(qos: .userInitiated).async {
            NSLog("Get Library Info Event Received")
            // TODO: Extract asset information and handle the event
        }
    }

    @objc func handleGetMetadataEvent(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        DispatchQueue.global(qos: .userInitiated).async {
            NSLog("Get Metadata Event Received")
            // TODO: Extract asset information and handle the event
        }
    }

    @objc func handleGetDataOptionsEvent(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        DispatchQueue.global(qos: .userInitiated).async {
            NSLog("Get Data Options Event Received")
            // TODO: Extract asset information and handle the event
        }
    }

    @objc func handleOpenDocumentEvent(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        DispatchQueue.global(qos: .userInitiated).async {
            NSLog("Open Document Event Received")
            // TODO: Extract asset information and handle the event
        }
    }
}

// Define the Asset class to hold the asset information
class Asset {
    var name: String
    // Add other properties as necessary

    init(name: String) {
        self.name = name
    }

    // Add methods to handle asset-related operations
}