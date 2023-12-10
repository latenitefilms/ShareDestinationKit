//
//  MakeCommand.m
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#import "MakeCommand.h"
#import "DocumentController.h"
#import "Document.h"
#import "Asset.h"
#import "ScriptingSupportCategories.h"

@implementation MakeCommand

// ------------------------------------------------------------
// Perform Default Implementation:
// ------------------------------------------------------------
- (id)performDefaultImplementation {
    id		result = nil;
    
    NSLog(@"[ShareDestinationKit] INFO - MakeCommand performDefaultImplementation");
    
    NSDictionary * theArguments = [self evaluatedArguments];
    
    // ------------------------------------------------------------
    // Show the direct parameter and arguments:
    // ------------------------------------------------------------
    NSLog(@"[ShareDestinationKit] INFO - The direct parameter is: '%@'", [self directParameter]);
    NSLog(@"[ShareDestinationKit] INFO - The other parameters are: '%@'", theArguments);
    
    id classParameter = [theArguments objectForKey:@"ObjectClass"];
    NSDictionary* properties = [theArguments objectForKey:@"KeyDictionary"];
    
    if ( classParameter == nil ) {
        NSLog(@"[ShareDestinationKit] INFO - No object class specified");
        [self setScriptErrorNumber:errAEParamMissed];
        
        return nil;
    }
    
    FourCharCode classCode = (FourCharCode)[classParameter integerValue];
    
    if ( [[NSScriptClassDescription classDescriptionForClass:[Asset class]] matchesAppleEventCode:classCode] ) {
        
        DocumentController *docController = [DocumentController sharedDocumentController];
        Document *currentDocument = [docController currentDocument];
        
        if ( currentDocument == nil ) {
            NSArray *documents = [docController documents];
            
            if ( [documents count] > 0 )
                // ------------------------------------------------------------
                // Pick up the first document if current document is nil:
                // ------------------------------------------------------------
                currentDocument = [documents objectAtIndex:0];
            else
                // ------------------------------------------------------------
                // Create an untitled document:
                // ------------------------------------------------------------
                currentDocument = [docController openUntitledDocumentAndDisplay:YES error:nil];
        }
        
        // ------------------------------------------------------------
        // Invoke the new asset sheet and suspend script execution:
        // ------------------------------------------------------------
        id nameParameter = nil;
        id metadataParameter = nil;
        id dataOptionsParameter = nil;
        
        if ( properties != nil ) {
            nameParameter = [properties objectForKey:@"name"];
            metadataParameter = [properties objectForKey:@"metadata"];
            dataOptionsParameter = [properties objectForKey:@"dataOptions"];
        }
        
        // ------------------------------------------------------------
        // Get the user interaction level and see if we can bring up
        // our user interface:
        // ------------------------------------------------------------
        NSUInteger interactionLevel = [self appleEventUserInteractionLevel];
        
        if ( interactionLevel == kAECanInteract ||
            interactionLevel == kAEAlwaysInteract ||
            interactionLevel == kAECanSwitchLayer ) {
            //SAMWindowController *currentWindowController = currentDocument.primaryWindowController;
            
            // ------------------------------------------------------------
            // Suspend the script execution and invoke the user interface:
            // ------------------------------------------------------------
            [self suspendExecution];
            
            /*
            [currentWindowController newAssetWithName:nameParameter
                                             metadata:metadataParameter
                                          dataOptions:dataOptionsParameter
                                    completionHandler:^(SAMAsset *newAsset) {
                if ( newAsset != nil ) {
                    NSScriptObjectSpecifier *theSpec = [newAsset objectSpecifier];
                    
                    // resume the execution with the result
                    [self resumeExecutionWithResult:theSpec];
                }
                else {
                    // indicate that the user has canceled the operation and resume script execution
                    [self setScriptErrorNumber:userCanceledErr];
                    [self resumeExecutionWithResult:nil];
                }
            }];
             */
        }
        else {
            // ------------------------------------------------------------
            // Create a new asset at a default location if user
            // interaction is not allowed:
            // ------------------------------------------------------------
            NSDictionary *defaultLocation = [currentDocument defaultAssetLocation];
            NSInteger assetIndex = [currentDocument addAssetAtLocation:defaultLocation
                                                               content:FALSE
                                                              metadata:metadataParameter
                                                           dataOptions:dataOptionsParameter];
            Asset *newAsset = [currentDocument.assets objectAtIndex:assetIndex];
            
            result = [newAsset objectSpecifier];
        }
    }
    else {
        // ------------------------------------------------------------
        // Invoke the standard implementation by the super class:
        // ------------------------------------------------------------
        result = [super performDefaultImplementation];
    }
    
    return result;
}

// ------------------------------------------------------------
// Apple Event User Interaction Level:
// ------------------------------------------------------------
- (NSUInteger)appleEventUserInteractionLevel
{
    NSAppleEventManager     *aem = [NSAppleEventManager sharedAppleEventManager];
    NSAppleEventDescriptor  *currentEvent = [aem currentAppleEvent];
    NSAppleEventDescriptor  *interactionLevel = [currentEvent attributeDescriptorForKeyword:keyInteractLevelAttr];
    return [interactionLevel int32Value];
}

@end

