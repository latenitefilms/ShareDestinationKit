# ShareDestinationKit

This is a sample Swift application to demonstrate how to receive media and data through Final Cut Pro Custom Share Destinations.

You can learn more about Custom Share Destinations on [Apple's Developer Site](https://developer.apple.com/documentation/professional_video_applications/content_and_metadata_exchanges_with_final_cut_pro/receiving_media_and_data_through_a_custom_share_destination).

You can find some older documentation [here](https://developer.apple.com/library/archive/documentation/FinalCutProX/Conceptual/FinalCutProXWorkflowsGuide/Exporting/Exporting.html#//apple_ref/doc/uid/TP40013781-CH3-SW21).

---

## SimpleAssetManagerSample

Included in the `SimpleAssetManagerSample` [folder](https://github.com/latenitefilms/ShareDestinationKit/tree/main/Examples/SimpleAssetManagerSample) is an old Apple sample project in Objective-C.

This sample has disappeared from the Internet for some reason, but it still works and is a great reference point.

---

## Example ChatGPT Prompt

Here's an example ChatGPT Prompt:

``````
I am writing a Swift application on Mac.

The application receives Media and Data Through a Final Cut Pro Custom Share Destination.

The Apple documentation explains:

<START DOCUMENTATION>
# Receiving Media and Data Through a Custom Share Destination
## Receive rendered media (movies), editing descriptions for project timelines, library archives, and FCPXML for other Final Cut Pro items in your app.

### Overview
After your users have finished working on their project in Final Cut Pro, they’re ready to bring it over to your app for final processing. Maybe your users plan to upload their project to an asset management server, or perhaps they need to archive or catalog the entire Final Cut Pro library.

With a Final Cut Pro custom share destination (and support from your app), your users can receive rendered output from a Final Cut Pro project, along with FCPXML descriptions for the project’s editing decisions and other items, such as keywords, ratings, and markers. Your app can also request a copy of the library containing these items to use for archiving.

In Final Cut Pro, a share destination provides a set of preconfigured export settings. When a user shares one or more projects or clips, these settings determine the format and other characteristics of the exported media. A custom share destination serves a similar purpose, but it specifies an app that knows how to interact with Final Cut Pro as the target application in the Final Cut Pro export settings.

Once you set up a custom share destination for your users, they see the custom share destination you created as one of the choices for sharing a project in Final Cut Pro.

Setting up your app is the first step in providing a custom share destination for your users. Edit your app’s Info.plist file to indicate that your app is capable of interacting with Final Cut Pro to configure the share operation (see Signal Your App’s Capabilities). Supply the scripting definitions required by Final Cut Pro to interact with your app through Apple events (see Describe Your Scripting Terminology) and add support so your app can respond to the series of Apple events sent by Final Cut Pro (see Provide Responses to Apple Events).

Once you’ve configured your app, create a custom share destination in Final Cut Pro. This is the destination that lets your users share their projects with your app (see Create a Custom Share Destination in Final Cut Pro). You distribute this custom share destination along with your app so users can add it to their own Final Cut Pro installation (see Distribute a Custom Share Destination to Your Users).

When your users have finished editing their projects in Final Cut Pro and want to continue their work in your app, they just select the project in Final Cut Pro, choose File > Share, and select your app’s custom share destination from the list of destinations. (See Intro to sharing projects in Final Cut Pro for more information.) Final Cut Pro conveys the request to your app, and your app responds with the information Final Cut Pro needs to perform the export operation.

> TIP: When you create the custom share destination for your app in Final Cut Pro, use that opportunity to test the communications between Final Cut Pro and your app. As your own first user, you can identify and fix any bugs before you distribute the custom share destination file to your users.

### Signal Your App’s Capabilities
Your app must advertise its ability to interact with Final Cut Pro and provide the information necessary for sharing a project. Add the following entry to the Info.plist file in your app’s bundle:

```
<key>com.apple.proapps.MediaAssetProtocol</key>
<dict>
</dict>
```

### Describe Your Scripting Terminology
Your app must supply scripting definitions for the events, object classes, and associated properties that Final Cut Pro uses to interact with your app. Specifically, your app must:

- Create scripting definitions for events, object classes, and record types. This includes definitions for the asset class as a representation of the media in your app. It also includes the make event that Final Cut Pro sends to tell your app to create an asset object as a placeholder. (See Creating Scripting Definitions for Custom Share Destinations for the scripting definitions you need to provide.)
- Implement the command-handler classes that are referenced from the scripting definitions. Specifically, implement the command handler for the make event using the Cocoa class name specified in your scripting definition. (See Cocoa Scripting Guide for more information.)
- Implement the object classes and associated properties according to key-value coding (KVC) and other conventions. Specifically, implement the object class for the asset object class, using the Cocoa class name specified in the scripting definition. (See Cocoa Scripting Guide for details.) Cocoa Scripting support gets the properties' values when Final Cut Pro asks for those properties through Get Property Apple events.

### Provide Responses to Apple Events
Once Final Cut Pro confirms that your app can interact with it through Apple events, it sends your app a series of Apple events. Your app responds by telling Final Cut Pro what kind of data your users want to receive and by providing a location for the data. Specifically, Final Cut Pro uses Apple events to find out:

- Whether your user wants to receive rendered media, editing decisions in FCPXML, or both
- Whether your user wants a library archive
- Which share metadata keys and values your user wants in the exported media files
- Which DTD version to use for the exported media files
- What Final Cut Pro metadata view to use to filter the metadata keys included in the exported media files
- For information about responding to each of these Apple events, see Responding to Apple Events from Final Cut Pro.

---

### Create a Custom Share Destination in Final Cut Pro
Once your app is set up to interact with Final Cut Pro, it’s time to create the actual share destination that your users will select in Final Cut Pro. (For more information, see Create share destinations in Final Cut Pro.)

1. Create a new custom share destination. In Final Cut Pro, choose File > Share > Add Destination. Drag the Export File destination from the right side of the Destinations list to the left side.
2. Give the new destination a name and specify the format and other settings. Choose the format your app requires and then specify the related settings, such as Video codec and Resolution. (For details about each option, see Export File destination in Final Cut Pro.)
3. Designate your app as the target application. From the “Open with” pop-up menu, choose Other. In the Applications folder, select your app and click Open.

---

# Responding to Apple Events from Final Cut Pro
## Tell Final Cut Pro about the kind of data your users want to receive in your app through a custom share destination.

### Overview
An Apple event is a type of interprocess message that can specify complex operations and data. Apple events provide a message transport through which an app can send a request to another app and receive an answer. (For more information about Apple events, see NSAppleEventManager.)

> IMPORTANT: The information in this article applies only to situations in which your app is receiving projects or clips from Final Cut Pro through a custom share destination.

Your app must tell Final Cut Pro what kind of information your users want to receive and must provide a location for that data. Final Cut Pro uses the following Apple events (in the order shown) to get this information from your app.

1. Create Asset. Tells your app to identify a newly created asset object to serve as a placeholder. For more information, see Respond to the Create Asset Apple Event.
2. Get Location Info Property. Your app should return an asset location record that tells Final Cut Pro where to put the exported output files and indicate whether it wants to receive rendered media, project editing decisions (in FCPXML), or both. For more information, see Respond to the Get Location Info Property Apple Event.
3. Get Library Info Property. Your app should return a library location record that tells Final Cut Pro where to put the library archive, if your user wants one. For more information, see Respond to the Get Library Info Property Apple Event.
4. Get Metadata Property. Your app should return a user record containing the share metadata keys and values for the share metadata your users want to receive. For more information, see Respond to the Get Metadata Property Apple Event.
5. Get Data Options Property . Your app should return a user record with key-value pairs that specify the DTD version and the metadata view to use for the exported files. For more information, see Respond to the Get Data Options Property Apple Event.
6. Open Document. When the export process is complete, Final Cut Pro sends an Open Document Apple event to notify your app that the export output files are available, and includes URLs to the files. For more information, see Respond to the Open Document Apple Event.

> NOTE: The synopsis for each Apple event is represented in AppleScript syntax; for more information, see the AppleScript Language Guide. For more information about handling Apple events in your app, see the Cocoa Scripting Guide.

When responding to Apple events, you should also know how to:
- Avoid conflicts with automated workflows by checking user interaction levels. See Monitor User Interaction Levels When Using Apple Events.
- Support conversions between the Apple event descriptor types used by Final Cut Pro and the respective Foundation object classes. See Supporting Conversions with Scripting Class Extensions.
- Use an AppleScript script to test your app and its ability to interact with Final Cut Pro. See Test Your App with AppleScript.

---

### Respond to the Create Asset Apple Event
When a Final Cut Pro user chooses File > Share and selects your app’s custom share destination, Final Cut Pro inspects your app’s info.plist file to see if your app can respond to Apple events from Final Cut Pro. (See Signal Your App’s Capabilities.) Once it confirms your app’s capability, Final Cut Pro sends your app a Create Asset Apple event containing the name of the asset, the set of share metadata, and a list of metadata views.

```
make new asset with properties { name: <asset name>, metadata: <metadata record>, data options: <options record> }
```

In response to a Create Asset event, your app should:

- Create a placeholder asset object with which to associate the exported data.
- Return an object specifier that identifies the newly created placeholder asset. Final Cut Pro uses the object specifier to reference this asset object in subsequent events.

The properties for the Create Asset Apple event include the following:

Property     | Description
-------------|------------------------------
name         | The asset name. Final Cut Pro derives this information from the project name.
metadata     | A record representing the set of share metadata, where the keys are reverse DNS-style metadata keys and the values are the associated metadata values. (For more information, see Associating Ratings, Keywords, Markers, and Metadata with Media.)
data options | A record containing the possible options for the exported output. This record holds the available choices for these data options:
             | - `availableMetadataSets (list)`: A list of available metadata views in Final Cut Pro.
             | - `availableDescriptionVersions (list)`: A list of available document type definition (DTD) versions that Final Cut Pro can export.
             | Your app indicates its choices in response to the Get Data Options Property Apple event (sent later) that asks for the value of the data options property.

While handling the Create Asset event, your app can bring up its UI before Final Cut Pro starts a possibly time-consuming transcoding operation. Use this opportunity to request information relevant to the operation your app is about to perform, such as which custom metadata is stored along with the media or the location of the exported output.

To avoid initiating user interactions while your app is handling Apple events as part of an automated workflow, be sure to check the user interaction levels for incoming Apple events. See Monitor User Interaction Levels When Using Apple Events.

---

### Respond to the Get Location Info Property Apple Event
Final Cut Pro sends a Get Location Info Property Apple event to ask your app for the location of the exported output files.

```
get location info of <asset object specifier>
```

Your app should return an asset location record as described in Creating Scripting Definitions for Custom Share Destinations.

The record’s folder property specifies the location of the folder to contain the exported output files. The base name property provides the base name for the exported output files: Exported media files have an extension that reflects their file format, and exported FCPXML files have an .fcpxml extension.

If your user wants an FCPXML file, be sure to set the has description property in the asset location record to true. If your user wants a media file, set the has media property in the asset location record to true.

---

### Respond to the Get Library Info Property Apple Event
Final Cut Pro sends a Get Library Info Property event asking for the location of the library output files.

```
get library info of <asset object specifier>
```

Your app should return a library location record as described in Creating Scripting Definitions for Custom Share Destinations.

The record’s library folder property should specify the location of the folder for the exported library output files. The library base name property provides the base name for the exported library output files: The exported library archive file has an .fcpbundle extension, and the exported FCPXML file has an .fcpxml extension.

If your user wants library files, be sure to set the has archive and has library description properties to true in the library location record. If you don’t specify the library folder property, Final Cut Pro uses the asset location folder. If you don’t specify the library base name property, Final Cut Pro uses the asset name with a suffix to show that it is the FCPXML for the library, such as MyProject-Library. If your app doesn’t respond to this event, Final Cut Pro assumes your user doesn’t want library files.

---

### Respond to the Get Metadata Property Apple Event
Final Cut Pro sends a Get Metadata Property event to get an updated set of share metadata. Final Cut Pro supplied the original set of metadata through the Create Asset event.

```
get metadata of <asset object specifier>
```

Your app must return a user record containing the share metadata keys and their values. Final Cut Pro updates the project being shared and includes the returned share metadata in the exported output. If the user record that your app returns contains keys for metadata other than the share metadata, those keys are ignored. (For a list of share metadata keys, see Review Share Metadata.)

Specifically, your app can generate a unique ID using the com.apple.proapps.share.id metadata key that represents the unique ID for the media asset your user is sharing (usually a project). Final Cut Pro includes the metadata for that key in the exported media files so your app can track the files associated with the asset.

---

### Respond to the Get Data Options Property Apple Event
Final Cut Pro sends a Get Data Options Property Apple event to request the data options to be used when it generates the exported output.

```
get data options of <asset object specifier>
```

Your app should return a user record with the following keys and their associated values:

Key                | Type | Description
-------------------|------|-------------
descriptionVersion | text | The DTD (document type definition) version to use for the FCPXML export. The default is the version used in the last FCPXML export.
metadataSet        | text | The name of the metadata view containing the metadata item to be included in the project FCPXML.

If no metadata view is specified, Final Cut Pro uses the currently selected metadata view to filter the share metadata. (For a list of keys for share metadata, see Review Share Metadata.)

---

### Respond to the Open Document Apple Event
Once Final Cut Pro completes exporting the files your app requested, it sends an Open Document Apple event to notify your app that output files are available.

```
open <list of export output files>
```

The Open Document Apple event contains URLs to the exported output files. Your app should return the object specifier for the asset object and associate the files to the asset object it has created, matching the base name of the files with the asset’s location information.

Because Cocoa scripting handles the Open Document Apple event, your app doesn’t need a command-handler class specifically for the event. If your asset object class is a subclass of NSDocument, Cocoa scripting support instantiates the class according to standard conventions. Alternatively, you can intercept the request by implementing an appropriate NSApplicationDelegate method that is involved when Final Cut Pro asks your app to open the URLs.

In some cases, Final Cut Pro creates multiple media files (for example, when your custom share destination is configured to export each role as a separate file). In these cases, the export filename is the asset name returned as the base name property of the asset location record, followed by a hyphen (-) and a suffix that indicates the role of the data, such as dialogue or effect.

---

### Monitor User Interaction Levels When Using Apple Events
To avoid initiating user interactions while handling Apple events sent by an automated workflow, make sure your app checks the user interaction level of the Apple events before initiating your user interaction. In the scripting command handler for the make command (or the Create Asset Apple event), get the current Apple event and its keyInteractLevelAttr attribute to check the user interaction level.

The value of the `keyInteractLevelAttr` attribute can be one of the following:

```
kAENeverInteract    = 0x00000010, /* server should not interact with user */
kAECanInteract      = 0x00000020, /* server may try to interact with user */
kAEAlwaysInteract   = 0x00000030, /* server should always interact with user where appropriate */
kAECanSwitchLayer   = 0x00000040, /* interaction may switch layer */
```

---

### Test Your App with AppleScript

Use the following AppleScript script to test your app’s ability to interact with Final Cut Pro.

```
tell application "SimpleAssetManager"
    make new asset with properties ¬
        {name:"MyNewAsset", metadata:{|com.apple.proapps.share.episodeID|:"MyNewEpisode"}, data options:{|availableMetadataSets|:{"Camera View", "General View"}}} ¬

    set newAsset to result
    set theLocation to location info of newAsset
    set theLibraryLocation to library info of newAsset
    set theMetadata to metadata of newAsset
    set theDataOptions to data options of newAsset
end tell
```

The following Apple event trace outlines the events and replies you get from running the previous AppleScript script:

```
tell application "SimpleAssetManager"
    make new asset with properties {name:"MyNewAsset", metadata:{|com.apple.proapps.share.episodeid|:"MyNewEpisode"}, data options:{availableMetadataSets:{"Camera View", "General View"}}}
        --> asset id "SSO-29842-2" of document "Untitled"
    get location info of asset id "SSO-29842-2" of document "Untitled"
        --> {has media:true, has description:true, base name:"MyNewAsset", folder:file "Lucca:Users:jane:Movies:"}
    get library info of asset id "SSO-29842-2" of document "Untitled"
        --> {has library description:true, has archive:true, library folder:file "Lucca:Users:jane:Movies:", library base name:"MyNewAssetLibrary"}
    get metadata of asset id "SSO-29842-2" of document "Untitled"
        --> {|com.apple.simpleassetmanager.preparedasset|:"1", |com.apple.simpleassetmanager.managedasset|:"1", |com.apple.quicktime.description|:"", |com.apple.simpleassetmanager.expeirationdate|:"2016-09-30 00:57:09 +0000", |com.apple.proapps.share.episodeid|:"MyNewEpisode", |com.apple.proapps.share.id|:"", |com.apple.proapps.share.episodenumber|:"0"}
    get data options of asset id "SSO-29842-2" of document "Untitled"
        --> {metadataSet:"None", descriptionVersion:"Previous Version"}
end tell

Result:
{metadataSet:"None", descriptionVersion:"Previous Version"}
```

---

# Supporting Conversions with Scripting Class Extensions
## Support conversions between the Apple event descriptor types and Foundation object classes.

### Overview
If your app uses Cocoa Scripting support to handle Apple events sent by Final Cut Pro, it must support conversions between certain Apple event descriptor types used by Final Cut Pro and the respective Foundation classes. These conversions are not supported by Cocoa Scripting.

The following code snippets provide interfaces for the required conversions.

Apple event record descriptor (typeAERecord) and NSDictionary:

```
@interface NSDictionary (UserDefinedRecord)
  +(NSDictionary*)scriptingUserDefinedRecordWithDescriptor:(NSAppleEventDescriptor*)desc;
  -(NSAppleEventDescriptor*)scriptingUserDefinedRecordDescriptor;
@end
```

Apple event list descriptor (typeAEList) and NSArray:

```
@interface NSArray (UserList)
  +(NSArray*)scriptingUserListWithDescriptor:(NSAppleEventDescriptor*)desc;
  -(NSAppleEventDescriptor*)scriptingUserListDescriptor;
@end
```

Apple event generic descriptor (list, record, and so on) and id:

```
@interface NSAppleEventDescriptor (GenericObject)
  +(NSAppleEventDescriptor*)descriptorWithObject:(id)object;
  -(id)objectValue;
@end
```

The following is an example implementation of the above interface. For more information, see the NSAppleEventDescriptor Class Reference.

```
/*
 File: ScriptingSupportCategories.m
 Abstract: Cocoa Scripting Support Categories implementations
 Version: 1.7

 Copyright (C) 2019 Apple Inc. All Rights Reserved.

 */

#import "ScriptingSupportCategories.h"

#import <Carbon/Carbon.h>


@implementation NSDictionary (UserDefinedRecord)

+(NSDictionary*)scriptingUserDefinedRecordWithDescriptor:(NSAppleEventDescriptor*)desc
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSAppleEventDescriptor* userFieldItems = [desc descriptorForKeyword:keyASUserRecordFields];
    NSInteger numItems = [userFieldItems numberOfItems];

    for ( NSInteger itemIndex = 1; itemIndex <= numItems - 1; itemIndex += 2 ) {
        NSAppleEventDescriptor* keyDesc = [userFieldItems descriptorAtIndex:itemIndex];
        NSAppleEventDescriptor* valueDesc = [userFieldItems descriptorAtIndex:itemIndex + 1];
        NSString* keyString = [keyDesc stringValue];
        id value = [valueDesc objectValue];

        if ( keyString != nil && value != nil )
            [dict setObject:value forKey:keyString];
    }

    return [NSDictionary dictionaryWithDictionary:dict];
}

-(NSAppleEventDescriptor*)scriptingUserDefinedRecordDescriptor
{
    NSAppleEventDescriptor* recordDesc = [NSAppleEventDescriptor recordDescriptor];
    NSAppleEventDescriptor* userFieldDesc = [NSAppleEventDescriptor listDescriptor];
    NSInteger userFieldIndex = 1;

    for ( id key in self ) {
        if ( [key isKindOfClass:[NSString class]] ) {
            NSString* valueString = nil;
            id value = [self objectForKey:key];

            if ( ! [value isKindOfClass:[NSString class]] )
                valueString = [NSString stringWithFormat:@"%@", value];
            else
                valueString = value;

            NSAppleEventDescriptor* valueDesc = [NSAppleEventDescriptor descriptorWithString:valueString];
            NSAppleEventDescriptor* keyDesc = [NSAppleEventDescriptor descriptorWithString:key];

            if ( valueDesc != nil && keyDesc != nil ) {
                [userFieldDesc insertDescriptor:keyDesc atIndex:userFieldIndex++];
                [userFieldDesc insertDescriptor:valueDesc atIndex:userFieldIndex++];
            }
        }
    }

    [recordDesc setDescriptor:userFieldDesc forKeyword:keyASUserRecordFields];

    return recordDesc;
}


@end

@implementation NSArray (UserList)

+(NSArray*)scriptingUserListWithDescriptor:(NSAppleEventDescriptor*)desc
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    NSInteger numItems = [desc numberOfItems];

    for ( NSInteger itemIndex = 1; itemIndex <= numItems; itemIndex++ ) {
        NSAppleEventDescriptor* itemDesc = [desc descriptorAtIndex:itemIndex];

        [array addObject:[itemDesc objectValue]];
    }

    return [NSArray arrayWithArray:array];
}

-(NSAppleEventDescriptor*)scriptingUserListDescriptor
{
    NSAppleEventDescriptor* listDesc = [NSAppleEventDescriptor listDescriptor];
    NSInteger itemIndex = 1;

    for ( id item in self ) {
        NSAppleEventDescriptor* itemDesc = [NSAppleEventDescriptor descriptorWithObject:item];

        [listDesc insertDescriptor:itemDesc atIndex:itemIndex++];
    }

    return listDesc;
}

@end


@implementation NSAppleEventDescriptor (GenericObject)

+(NSAppleEventDescriptor*)descriptorWithObject:(id)object
{
    NSAppleEventDescriptor* desc = nil;

    if ( [object isKindOfClass:[NSArray class]] ) {
        NSArray*    array = (NSArray*)object;

        desc = [array scriptingUserListDescriptor];
    }
    else if ( [object isKindOfClass:[NSDictionary class]] ) {
        NSDictionary*   dict = (NSDictionary*)object;

        desc = [dict scriptingUserDefinedRecordDescriptor];
    }
    else if ( [object isKindOfClass:[NSString class]] ) {
        desc = [NSAppleEventDescriptor descriptorWithString:(NSString*)object];
    }
    else if ( [object isKindOfClass:[NSURL class]] ) {
        desc = [NSAppleEventDescriptor descriptorWithURL:(NSURL*)object];
    }
    else {
        NSString* valueString = [NSString stringWithFormat:@"%@", object];

        desc = [NSAppleEventDescriptor descriptorWithString:valueString];
    }

    return desc;
}

-(id)objectValue
{
    DescType    descType = [self descriptorType];
    DescType    bigEndianDescType = 0;
    id          object = nil;


    switch ( descType ) {
        case typeUnicodeText:
        case typeUTF8Text:
            object = [self stringValue];
            break;
        case typeFileURL:
            object = [self fileURLValue];
            break;
        case typeAEList:
            object = [NSArray scriptingUserListWithDescriptor:self];
            break;
        case typeAERecord:
            object = [NSDictionary scriptingUserDefinedRecordWithDescriptor:self];
            break;
        case typeSInt16:
        case typeUInt16:
        case typeSInt32:
        case typeUInt32:
        case typeSInt64:
        case typeUInt64:
            object = [NSNumber numberWithInteger:(NSInteger)[self int32Value]];
            break;
        default:
            bigEndianDescType = EndianU32_NtoB(descType);
            NSLog(@"Creating NSData for AE desc type %.4s.", (char*)&bigEndianDescType);
            object = [self data];
            break;
    }

    return object;
}

@end
```
---

# Creating Scripting Definitions for Custom Share Destinations
## Define the record types, object classes, and event types that let your app interact with Final Cut Pro.

### Overview
As the target application of a Final Cut Pro custom share destination, your app must respond to the Apple events that Final Cut Pro sends to get information about the kind of data your users want. (See Responding to Apple Events from Final Cut Pro.) Your app must also supply scripting definitions to define the Apple events along with their associated objects and record types. The tables in the following sections describe the definitions your app needs for its interactions with Final Cut Pro.

> NOTE: For an example of a complete scripting definition, see Review a Scripting Definition Example: Asset Management Suite.

---

### Define Record Types
`asset location` — Describes the location of the files associated with an object of a class asset. (See Define Object Classes.)

Property        | Type    | Description
----------------|---------|------------------------------
folder          | file    | The containing folder path.
base name       | text    | The base name for the exported output files. This name must match the asset name.
has description | boolean | Set to true if the app requires FCPXML as the exported output.
has media       | boolean | Set to true if the app requires media as the exported output.

`library location` — Describes the location of the library files associated with an asset.

Property                | Type    | Description
------------------------|---------|------------------------
library folder          | file    | The containing folder path.
library base name       | text    | The base name for the exported output files.
has archive             | boolean | Set to true if the application requires a library archive as the exported output.
has library description | boolean | Set to true if the application requires FCPXML as the exported output.

---

### Define Object Classes

`asset` — Represents an asset object that corresponds to the exported output from Final Cut Pro.

Property      | Type                | Description
--------------|---------------------|-----------------------------------
id            | text                | The unique asset identifier.
name          | text                | The asset name.
location info | asset location      | The location of files associated with the asset.
library info  | library location    | The location of the library files associated with the asset.
metadata      | user defined record | The shared metadata set associated with the asset.
data options  | user defined record | The options set for the asset data.

The protocol between Final Cut Pro and your app through Apple events should be agnostic to your app’s object containment hierarchy. For example, the scripting definition in the Asset Management Suite Example defines an asset as a document element, but it could also define an asset as an element of a larger entity, such as a media asset database.

Your app needs only to return an object specifier with which Final Cut Pro can access a specific asset object. (See Review a Scripting Definition Example: Asset Management Suite.)

When an asset object is not a document, handling an Open Document Apple event to associate files to an asset might be a bit awkward. Because Cocoa Scripting handles the Open Document Apple event, you need a custom document controller to override the behavior of Cocoa when your app opens a file and when it associates a file (based on matching the URL) with either an existing asset object or with a new asset object. You may need some customization to ensure that the files handled through the Open Document Apple event are properly associated to the asset object.

---

### Define Event Types

`make` — Creates a new asset object.

Property        | Type               | Description
----------------|--------------------|-------------------------------
new             | type               | The new object’s class.
at              | location specifier | The location in which to insert the new object.*
with data       | any                | The initial contents of the object.*
with properties | record             | A list of object properties used to initialize the new object:
                |                    |  - name (text)—The asset name.
                |                    |  - metadata (record)—The metadata set associated with the asset object.
                |                    |  - data options (record)—The option set used to create the asset data.

* Final Cut Pro doesn’t use the `at` and `with data` parameters itself, but they are inherited from the respective event definitions (or make event definitions) in the standard suite. They’re included here in case your app needs to support these parameters for other clients.

---

### Specify an Access Group for Your App

To enable access from a sandboxed application to the objects and events in your app, your app must specify com.apple.assetmanagement.import as the access group for:

- The object class for media assets
- The respective element in its container
- The Create Asset event

The Cocoa Scripting Guide describes how to use classes and categories to create scriptable apps (referred to as Cocoa scripting) in the Cocoa application framework.

---

### Review a Scripting Definition Example: Asset Management Suite

An app that interacts with Final Cut Pro must support the events and object classes described in the previous tables. The following code shows a complete example of a scripting definition used by an asset-management app.

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE dictionary SYSTEM "file://localhost/System/Library/DTDs/sdef.dtd">

<!--

   File: AssetManagementSuite.sdef
 Abstract: Asset Management suite scripting definitions
     for the SimpleAssetManager sample code.
  Version: 1.6


    Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc. ("Apple") in consideration of your agreement to the followin terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.
    In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple's copyrights in this original Apple software (the "Apple Software"), to use, reproduce, modify and redistribute the AppleSoftware, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.
    Neither the name, trademarks, service marks or logos of Apple Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.
    The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
    IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


Copyright (C) 2011-2019 Apple Inc. All Rights Reserved.

-->


<!-- declare the namespace for using XInclude so you can include the standard suite -->
<dictionary xmlns:xi="http://www.w3.org/2003/XInclude">

  <!-- use XInclude to include the standard suite -->
  <xi:include href="file:///System/Library/ScriptingDefinitions/CocoaStandard.sdef" xpointer="xpointer(/dictionary/suite)"/>

  <!-- specific suite(s) for the application follow... -->
  <suite name="ProVideo Asset Management" code="pvam" description="Scripting terminology for Pro Video Asset Management applications.">

    <record-type name="asset location" code="aslc">
      <access-group identifier="com.apple.proapps.assetmanagement.import" access="rw"/>
      <property name="folder" code="asfd" type="file" description="Directory in which the asset files exist.">
        <cocoa key="folder"/>
      </property>
      <property name="base name" code="asbn" type="text" description="Base file name of the asset files.">
        <cocoa key="basename"/>
      </property>
      <property name="has media" code="ashm" type="boolean" description="Whether the asset has rendered media">
        <cocoa key="hasMedia"/>
      </property>
      <property name="has description" code="ashd" type="boolean" description="Whether the asset has an XML description">
        <cocoa key="hasDescription"/>
      </property>
    </record-type>

    <!-- record type for library access -->
    <record-type name="library location" code="lblc">
      <access-group identifier="com.apple.proapps.assetmanagement.import" access="rw"/>
      <property name="library folder" code="lbfd" type="file" description="Directory in which the library files exist.">
        <cocoa key="folder"/>
      </property>
      <property name="library base name" code="lbbn" type="text" description="Base file name of the library files.">
        <cocoa key="basename"/>
      </property>
      <property name="has archive" code="lbha" type="boolean" description="Whether the library has data for archive.">
        <cocoa key="hasArchive"/>
      </property>
      <property name="has library description" code="lbhd" type="boolean" description="Whether the library has an XML description.">
        <cocoa key="hasDescription"/>
      </property>
    </record-type>

    <value-type name="user defined record" code="usrf">
      <cocoa class="NSDictionary"/>
    </value-type>

    <command name="open" code="aevtodoc" description="Open a document.">
      <access-group identifier="com.apple.proapps.assetmanagement.import" access="rw"/>
      <direct-parameter description="The file(s) to be opened.">
        <type type="file"/>
        <type type="file" list="yes"/>
      </direct-parameter>
      <result description="The opened document(s).">
        <type type="document"/>
        <type type="document" list="yes"/>
      </result>
    </command>

    <command name="make" code="corecrel" description="Create a new object.">
      <access-group identifier="com.apple.proapps.assetmanagement.import" access="rw"/>
      <cocoa class="SAMMakeCommand"/>
      <parameter name="new" code="kocl" type="type" description="The class of the new object.">
        <cocoa key="ObjectClass"/>
      </parameter>
      <parameter name="at" code="insh" type="location specifier" optional="yes" description="The location at which to insert the object.">
        <cocoa key="Location"/>
      </parameter>
      <parameter name="with data" code="data" type="any" optional="yes" description="The initial contents of the object.">
        <cocoa key="ObjectData"/>
      </parameter>
      <parameter name="with properties" code="prdt" type="record" optional="yes" description="The initial values for properties of the object.">
        <cocoa key="KeyDictionary"/>
      </parameter>
      <result type="specifier" description="The new object."/>
    </command>

    <class-extension name="application" extends="application">
      <access-group identifier="com.apple.proapps.assetmanagement.import" access="rw"/>
      <cocoa class="NSApplication"/>
      <property name="name" code="pnam" type="text" access="r" description="The name of the application.">
        <access-group identifier="com.apple.proapps.assetmanagement.import" access="rw"/>
      </property>
      <element type="document">
        <access-group identifier="com.apple.proapps.assetmanagement.import" access="rw"/>
      </element>
    </class-extension>

    <class name="document" code="docu" description="A document." inherits="document">
      <access-group identifier="com.apple.proapps.assetmanagement.import" access="rw"/>
      <cocoa class="SAMDocument"/>
      <property name="name" code="pnam" type="text" access="r" description="The name of the application.">
        <access-group identifier="com.apple.assetmanagement.import" access="rw"/>
      </property>
      <property name="id" code="ID  " type="text" access="r" description="The unique identifier of the asset">
        <access-group identifier="com.apple.assetmanagement.import" access="rw"/>
      </property>
      <element type="asset">
        <access-group identifier="com.apple.assetmanagement.import" access="rw"/>
        <cocoa key="assets"/>
      </element>
    </class>

    <class name="asset" code="aset" description="A media asset.">
      <access-group identifier="com.apple.assetmanagement.import" access="rw"/>
      <cocoa class="SAMAsset"/>
      <property name="id" code="ID  " type="text" access="r" description="The unique identifier of the asset">
        <access-group identifier="com.apple.assetmanagement.import" access="rw"/>
        <cocoa key="uniqueID"/>
      </property>
      <property name="name" code="pnam" type="text" access="r" description="Its name.">
        <access-group identifier="com.apple.assetmanagement.import" access="rw"/>
        <cocoa key="name"/>
      </property>
      <property name="location info" code="locn" type="asset location" access="r" description="Location information of the asset.">
        <access-group identifier="com.apple.assetmanagement.import" access="rw"/>
        <cocoa key="locationInfo"/>
      </property>
      <property name="library info" code="lbry" type="library location" access="r" description="Location information of the containing library in the source.">
        <access-group identifier="com.apple.assetmanagement.import" access="rw"/>
        <cocoa key="libraryInfo"/>
      </property>
      <property name="metadata" code="meta" type="user defined record" access="rw" description="Metadata associated to the asset.">
        <access-group identifier="com.apple.assetmanagement.import" access="rw"/>
        <cocoa key="metadata"/>
      </property>
      <property name="data options" code="dopt" type="user defined record" access="rw" description="Data creation options for the asset.">
        <access-group identifier="com.apple.assetmanagement.import" access="rw"/>
        <cocoa key="dataOptions"/>
      </property>
    </class>
    <enumeration name="saveable file format" code="savf">
      <enumerator name="document" code="docu" description="A document."/>
    </enumeration>
  </suite>
</dictionary>
```
<END DOCUMENTATION>

I've added this to my `Info.plist`:

```
<key>OSAScriptingDefinition</key>
<string>OSAScriptingDefinition.sdef</string>
<key>com.apple.proapps.MediaAssetProtocol</key>
<dict></dict>
```

And I've added `OSAScriptingDefinition.sdef` to my Xcode project as per Apple's documentation above.

All the correct permissions and entitlements are set.

My current Swift code is:

```
<<<PUT YOUR LATEST CODE HERE>>>
```

<<<INSERT YOUR QUESTION HERE>>>

Please make sure the Swift code is for Mac, and is clean, logical, documented and uses `NSLog` to verbosely note what's happening.

Please just supply the new, complete code, with no explanation or commentary required.
``````