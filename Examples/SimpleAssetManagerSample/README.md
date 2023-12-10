# Final Cut Pro X Workflows

## Introduction

SimpleAssetManagerSample is a simple application that demonstrate how an application can work with Final Cut Pro X to customize the export process. It provides information Final Cut Pro X needs in performing export operation, such as the location of export output files, whether Final Cut Pro X exports the project XML in addition to the rendered media, and a set of share metadata to be included in the export output. 

Final Cut Pro X sends a series of AppleEvents to the application the user specified requesting the information. SimpleAssetManagerSample replies back with relevant information. Please refer to "Final Cut Pro X Workflow Integration" for an overview of the process as well as detailed requirements. Also refer to "Cocoa Scripting Guide" for general discussion on how an application implements scripting support including handling AppleEvents.

In order for this interaction to work, you need Final Cut Pro X version 10.1.


## Application Functionality

SimpleAssetManagerSample maintains a list of "asset" objects in a document.  An asset can have multiple files associated to it. The expectation is there  is one QuickTime Movie file that has the media and one XML file that has the project description in FCPX XML. The list appears as a scrolling list in the document window. Each item in the list is displayed with its name, duration and some metadata. When you select an item, the name, the file URL for the media file and the description file are shown in the field below the list.

There are three buttons at the bottom of the document window. The "New..." button lets you create a new asset without associated files. It brings up a  sheet through which you specify the location of the files, some metadata,  whether you expect to have a description file, and the metadata set you'd  expect in the FCPX XML. The "Add..." button lets you add existing files as a new asset. It brings up the Open File panel through which you can choose the files to add. The "Remove" button removes the selected items from the list.


## Scripting Support

Final Cut Pro X queries the information through a series of AppleEvents. SimpleAssetManagerSample handles these events through Cocoa Scripting Support. There is a more detailed discussion on this interaction in "Final Cut Pro Workflow Integration." The complete definition of the events and the object classes including the scripting terminology are in OSAScriptingDefintions.sdef.

### Create Asset Event
In response to this event, SimpleAssetManagerSample performs the action it would take when the "New..." button is pressed, bringing up the new asset  sheet and let you specify information on the new asset. It will return the object specifier for the new asset to Final Cut Pro X. Final Cut Pro X uses the object specifier when it asks for additional information on the new asset.

### Get Property Event
Final Cut Pro X asks for a few properties of the asset created above through a series of Get Property events. The properties are, "location info", "metadata", and "data options". The Cocoa Scripting Support handles the Get Property Events and accesses relevant Objective-C properties through KVC.

### Open Document Event
When Final Cut Pro X finishes export, it will send an Open Document event with paths to the export output files. SimpleAssetManagerSample does not handle the Open Document event directly, since Cocoa handles the event. Instead it  customizes the behavior with its custom document controller and application delegate.


## Signaling Application Capabilities

Final Cut Pro X needs to know if the application knows how to responds to the queries it is about to send. An application indicates the capability with an entry in its bundle plist with the following key:

    com.apple.proapps.MediaAssetProtocol

The value is an empty dictionary. SimpleAssetManagerSample has this entry in its bundle plist.


## Application Architecture

SimpleAssetManagerSample is a document based application. SAMDocument is the document object class, and manages the list of assets. SAMWindowController manages the document window and its content including the asset list view and other UI elements. OutlineViewDataSource.[hm] has methods that feeds the data to display in the asset list view.

SAMAsset is the class that represents an asset object. SAMObject implements functionality Cocoa Scripting supports as a base class to keep track of objects. SAMMakeCommand is the scripting command class that handles the Create Asset event.

ScriptingSupportCategories.[hm] has extensions to NSAppleEventDescriptor and a couple other Foundation classes in order to use user defined record and list of arbitrary objects. These are necessary to represent a list of metadata or  data options as key value pairs. While AppleEvent supports these records and lists, Cocoa Scripting Support does not directly support them.

SAMDocumentController is a custom document controller that overrides Cocoa's default behavior in opening a document file. It looks at the type of the file given to the application, and if it's a QuickTime Movie file or a FCPX XML  file, it associates the file to an appropriate asset.

SAMApplicationDelegates also customizes the behavior in opening documents, by  ensuring proper asset object specifiers are returned instead of document  object specifiers when SimpleAssetManagerSample associated files to an asset in response to an Open Document event.


## Application Sandboxing

SimpleAssetManagerSample is a sandboxed application, and has the following entitlement to access files the user specified:

    com.apple.security.files.user-selected.read-write

In order to allow scripting access through AppleEvents from another sandboxed application, it has a scripting access group attached to the events and the object classes. See OSAScriptingDefintions.sdef for the specifics.


## Sample Script

You can drive SampleAssetManager's functionality discussed above through AppleScript. Interaction.scpt has an AppleScript snippet that simulates the series of AppleEvents Final Cut Pro X will send. You can actually run this script in AppleScript Editor, and see each events and results exchanged between Final Cut Pro X and SimpleAssetManagerSample in the log window.


