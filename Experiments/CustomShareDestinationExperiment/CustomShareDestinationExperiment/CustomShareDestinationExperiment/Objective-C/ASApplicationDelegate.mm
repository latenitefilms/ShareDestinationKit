/****************************************************************************************
 * Copyright 2001-2015 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * ASApplicationDelegate.mm  $Revision: 1 $
 *
 *		Description
 *
 *
 ***************************************************************************************/
 
#import "ASApplicationDelegate.h"
#import "ScriptingSupportCategories.h"


@implementation ASApplicationDelegate

//
//  Open a list of files
//
//  Also stick a list of object specifiers for opend object, if there is incoming OpenDoc AppleEvent

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	NSAppleEventManager *aemanager = [NSAppleEventManager sharedAppleEventManager];
	NSAppleEventDescriptor *currentEvent = [aemanager currentAppleEvent];
	NSAppleEventDescriptor *currentReply = [aemanager currentReplyAppleEvent];
	NSAppleEventDescriptor *directParams = [currentEvent descriptorForKeyword:keyDirectObject];
	NSAppleEventDescriptor *resultDesc = [currentReply descriptorForKeyword:keyDirectObject];
	
	if ( currentEvent != nil && directParams != nil ) {
		NSArray *urls = [NSArray scriptingUserListWithDescriptor:directParams];
		
		NSLog(@"Open Documement URLs: %@", urls);
	}
	
	if ( resultDesc == nil ) {
		resultDesc = [NSAppleEventDescriptor listDescriptor];
	}
	
	NSDocumentController *docController = [NSDocumentController sharedDocumentController];
	
	[self openFileInFileNameList:filenames
						 atIndex:0
				  withController:docController
					 docDescList:directParams
				  resultDescList:resultDesc];
	
	[currentReply setDescriptor:resultDesc forKeyword:keyDirectObject];
	
	if ( currentReply != nil && resultDesc != nil ) {
		NSLog(@"Opened Objects:%@.", resultDesc);
	}
}

- (void)openFileInFileNameList:(NSArray*)filenames
					   atIndex:(NSUInteger)index
				withController:(NSDocumentController*)docController
				   docDescList:(NSAppleEventDescriptor*)directParams
				resultDescList:(NSAppleEventDescriptor*)resultDesc
{
	if ( index >= [filenames count] )
		return;
	
	NSURL *url = [[NSURL fileURLWithPath:[filenames objectAtIndex:index]] URLByResolvingSymlinksInPath];
	
	[docController openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error){
		
		id opendObject = document;
		NSScriptObjectSpecifier *opendObjectSpec = [opendObject objectSpecifier];
		
		if ( opendObjectSpec != nil ) {
			[resultDesc insertDescriptor:[opendObjectSpec descriptor] atIndex:index + 1];
		}
		
		[self openFileInFileNameList:filenames
							 atIndex:index + 1
					  withController:docController
						 docDescList:directParams
					  resultDescList:resultDesc];
	}];
}


@end

/**************************************************************************************
 * $Log: ASApplicationDelegate.mm $
 * Revision 1 2015/11/25 07:02:02 -0800 harry /FinalCutProX/ADII/harryp
 * init version.
 * 
 *
 *************************************************************************************/
