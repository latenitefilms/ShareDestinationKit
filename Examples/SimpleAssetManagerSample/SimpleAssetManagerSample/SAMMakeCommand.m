/*
     File: SAMMakeCommand.m
 Abstract: SimpleAssetManager command class that handles the Create Asset AppleEvent.
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "SAMMakeCommand.h"
#import "SAMDocumentController.h"
#import "SAMDocument.h"
#import "SAMAsset.h"
#import "scriptLog.h"
#import "ScriptingSupportCategories.h"


@implementation SAMMakeCommand

- (id)performDefaultImplementation {
	id		result = nil;
	
    SLOG(@"SAMMakeCommand performDefaultImplementation");
	
	NSDictionary * theArguments = [self evaluatedArguments];
	
	/* show the direct parameter and arguments */
	SLOG(@"The direct parameter is: '%@'", [self directParameter]);
	SLOG(@"The other parameters are: '%@'", theArguments);

	id classParameter = [theArguments objectForKey:@"ObjectClass"];
	NSDictionary* properties = [theArguments objectForKey:@"KeyDictionary"];
	
	if ( classParameter == nil ) {
		SLOG(@"No object class specified");
		[self setScriptErrorNumber:errAEParamMissed];

		return nil;
	}
	
	FourCharCode	classCode = (FourCharCode)[classParameter integerValue];
	
	if ( [[NSScriptClassDescription classDescriptionForClass:[SAMAsset class]] matchesAppleEventCode:classCode] ) {
		
		SAMDocumentController *docController = [SAMDocumentController sharedDocumentController];
		SAMDocument *currentDocument = [docController currentDocument];
		
		if ( currentDocument == nil ) {
			NSArray		*documents = [docController documents];
			
			if ( [documents count] > 0 )
				// pick up the first document if current document is nil
				currentDocument = [documents objectAtIndex:0];
			else
				// create an untitled document
				currentDocument = [docController openUntitledDocumentAndDisplay:YES error:nil];
		}
		
		// invoke the new asset sheet and suspend script execution
		id nameParameter = nil;
        id metadataParameter = nil;
        id dataOptionsParameter = nil;
		
		if ( properties != nil ) {
			nameParameter = [properties objectForKey:@"name"];
            metadataParameter = [properties objectForKey:@"metadata"];
            dataOptionsParameter = [properties objectForKey:@"dataOptions"];
        }

        // get the user interaction level and see if we can bring up our UI
        NSUInteger interactionLevel = [self appleEventUserInteractionLevel];
        
        if ( interactionLevel == kAECanInteract ||
            interactionLevel == kAEAlwaysInteract ||
            interactionLevel == kAECanSwitchLayer ) {
            SAMWindowController *currentWindowController = currentDocument.primaryWindowController;

        // suspend the script execution and invoke the UI
		[self suspendExecution];
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
	}
	else {
            // create a new asset at a default locatino if user interactino is not allowed
            NSDictionary    *defaultLocation = [currentDocument defaultAssetLocation];
            NSInteger       assetIndex = [currentDocument addAssetAtLocation:defaultLocation
                                                                     content:FALSE
                                                                    metadata:metadataParameter
                                                                 dataOptions:dataOptionsParameter];
            SAMAsset        *newAsset = [currentDocument.assets objectAtIndex:assetIndex];
            
            result = [newAsset objectSpecifier];
        }
	}
	else {
		// invokde the standard implementation by the super class
		result = [super performDefaultImplementation];
	}

	return result;
}


- (NSUInteger)appleEventUserInteractionLevel
{
    NSAppleEventManager     *aem = [NSAppleEventManager sharedAppleEventManager];
    NSAppleEventDescriptor  *currentEvent = [aem currentAppleEvent];
    NSAppleEventDescriptor  *interactionLevel = [currentEvent attributeDescriptorForKeyword:keyInteractLevelAttr];
    
    return [interactionLevel int32Value];
}

@end

