/****************************************************************************************
 * Copyright 2015-2016 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * ASMakeCommand  $Revision: 6 $
 *
 *		This class is reponsible for responsing to the Apple Script "make" new asset
 *	command.
 *
 * Based on SAMMakeCommand class from the SampleAssetManagerSimple eg from Apple
 *
 *
 ***************************************************************************************/
 
#import "ASMakeCommand.h"
#import "scriptLog.h"

#import "ASAsset.h"
#import "ASApplication.h"
#import "FCPXMetadataKeys.h"

#import "include/misc.h"
#import "files/DFile.h"

@implementation ASMakeCommand

- (id)performDefaultImplementation
{
	id		result = nil;
	
	SLOG(@"ASMakeCommand performDefaultImplementation");
	
	NSDictionary * theArguments = [self evaluatedArguments];
	
	/* show the direct parameter and arguments */
	SLOG(@"The direct parameter is: '%@'", [self directParameter]);
	SLOG(@"The other parameters are: '%@'", theArguments);
	
	id classParameter = [theArguments objectForKey:@"ObjectClass"];
	NSDictionary* properties = [theArguments objectForKey:@"KeyDictionary"];
	
	if ( classParameter == nil ) {
		NSLOG(@"No object class specified");
		[self setScriptErrorNumber:errAEParamMissed];
		
		return nil;
	}
	
	FourCharCode	classCode = (FourCharCode)[classParameter integerValue];
	
	if ( [[NSScriptClassDescription classDescriptionForClass:[MyASAsset class]] matchesAppleEventCode:classCode] )
	{
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
			interactionLevel == kAECanSwitchLayer )
		{
			ASApplication* app = (ASApplication*)[NSApplication sharedApplication] ;
			// [app mainWindow] and its variants all return nil??
			NSArray* windows = [[ASApplication sharedApplication] windows] ;
			NSWindow* window = [windows objectAtIndex:0 ];
			DASSERT(window) ;
//			XMotionController* controller = [window windowController] ;
			
			[self suspendExecution];
			// based on SAMWindowController::selectNewAssetFolder:sender
			NSURL *folderURL = [[[NSFileManager defaultManager] URLForDirectory:NSMoviesDirectory
																	   inDomain:NSUserDomainMask
															  appropriateForURL:nil
																		 create:YES
																		  error:nil]
								URLByResolvingSymlinksInPath];
			// add our own subdirectory
			CStr subFolder = COMPANY_FOLDER_NAME ;
			subFolder += " " ;
			subFolder += OMF_APPLICATION_NAME ;	// really? how old can this get?!
			NSURL* newFolderURL = [folderURL URLByAppendingPathComponent:
								    [[NSString alloc] initWithCString:subFolder.c_str()
															 encoding:NSMacOSRomanStringEncoding]] ;
			// create it! Else FCPX will not do anything!
			DFile folderDF((CFURLRef)newFolderURL) ;
			folderDF.makeFolder() ;
			
			// based on SAMDocument::addAssetAtLocation:content:metadata:dataOptions:
			DASSERT([app asset]) ;
			// RE-DEFINE our SINGLE asset w/ new parameters!
			MyASAsset* newAsset = [[app asset] init:nameParameter
											   at:(NSURL*)newFolderURL
											media:nil
											 desc:@"fcpxml"] ;

			NSMutableDictionary* metadataset = [NSMutableDictionary dictionaryWithCapacity:0];
			[metadataset setObject:@"" forKey:kFCPXMetadataKeyDescription];
			[metadataset setObject:@"DATE" forKey:kASMetadataKeyExpirationDate];
			[metadataset setObject:@"" forKey:kFCPXShareMetadataKeyShareID];
			[metadataset setObject:@"" forKey:kFCPXShareMetadataKeyEpisodeID];
			[metadataset setObject:@([@"0" integerValue]) forKey:kFCPXShareMetadataKeyEpisodeNumber];
			[metadataset setObject:@"1" forKey:kASMetadataKeyPreparedAsset];
			[newAsset setMetadata:metadataset];
			
			NSMutableDictionary*    dataOptions = [NSMutableDictionary dictionaryWithCapacity:0];
//			[dataOptions setObject:@"None" forKey:@"metadataSet"]; // kMediaAssetDataOptionMetadataSetKey
			[dataOptions setObject:@"Settings" forKey:@"metadataSet"]; // kMediaAssetDataOptionMetadataSetKey
			[newAsset setDataOptions:dataOptions];
			
//			[controller setAsset:newAsset] ;
			
			NSScriptObjectSpecifier *theSpec = [newAsset objectSpecifier];
			// resume the execution with the result
			SLOG(@">>> %@", theSpec) ;
			[self resumeExecutionWithResult:theSpec];
		}
		else
		{
			DASSERT(0) ;
		}
	}
	else
	{
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
