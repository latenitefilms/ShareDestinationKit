/****************************************************************************************
 * Copyright 2001-2015 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * ASWindowController.mm  $Revision: 2 $
 *
 *		Description
 *
 *
 ***************************************************************************************/
 
#import "ASWindowController.h"
#import "ASAsset.h"
#import "ASDocument.h"

#import "MediaAssetHelperKeys.h"
#import "FCPXMetadataKeys.h"


@interface ASWindowController ()

// UI elements on the document window
@property IBOutlet NSOutlineView  *outlineView;

@property IBOutlet NSTextField    *selectedAssetTitleField;
@property IBOutlet NSTextField    *selectedAssetMediaURLField;
@property IBOutlet NSTextField    *selectedAssetDescURLField;

// the new asset sheet
@property IBOutlet NSWindow       *sheetForNewAsset;
@property IBOutlet NSTextField    *nameFieldForNewAsset;
@property IBOutlet NSPopUpButton  *locationTypePopupForNewAsset;
@property IBOutlet NSTextField    *locationFolderURLFieldForNewAsset;

// metadata pane
@property IBOutlet NSTextField    *descriptionFieldForNewAsset;
@property IBOutlet NSDatePicker   *expirationDatePickerForNewAsset;
@property IBOutlet NSTextField    *shareIDFieldForNewAsset;
@property IBOutlet NSTextField    *episodeIDFieldForNewAsset;
@property IBOutlet NSTextField    *episodeNumberFieldForNewAsset;

// data options pane
@property IBOutlet NSPopUpButton  *metadataSetPopupForNewAsset;
@property IBOutlet NSButton       *hasDecriptionCheckBoxForNewAsset;

// the wait sheet
@property /*(weak)*/ IBOutlet NSWindow              *FCPXWaitSheet;
@property IBOutlet NSProgressIndicator	*FCPXWaitIndicator;

@end


@implementation ASWindowController
{
	BOOL                    askUserNewAssetPath;
	BOOL                    newAssetWantsDescription;
}

- (instancetype)init
{
	self = [super initWithWindowNibName:DOCUMENT_NIB_NAME];
	if (self) {
		// add more initialization if any
	}
	
	return self;
}

- (instancetype)initWithWindow:(NSWindow *)window
{
	self = [super initWithWindow:window];
	if (self) {
		// add more initialization if any
	}
	
	return self;
}

/*
 update user interface on load
 */
- (void)windowDidLoad
{
	[self updateSelectionDetailFields];
}


#pragma mark <<< Managing Text Fields >>>

/*
 update the outline view
 */
- (void)updateOutlineView:(id)sendor
{
	[self.outlineView reloadData];
	[self.outlineView deselectAll:sendor];
}

/*
 update the text fields that display details about the selected item
 */
- (void)clearDetailFields
{
	// these should be localized, but use string constants here for clarity
	[self.selectedAssetTitleField setStringValue:@"No selection"];
	[self.selectedAssetTitleField setSelectable:NO];
	[self.selectedAssetMediaURLField setStringValue:@"No selection"];
	[self.selectedAssetMediaURLField setSelectable:NO];
	[self.selectedAssetDescURLField setStringValue:@"No selection"];
	[self.selectedAssetDescURLField setSelectable:NO];
}

- (void)setDetailFieldsWithName:(NSString*)name mediaURL:(NSURL*)mediaURL descURL:(NSURL*)descURL
{
	NSString*       URLString = nil;
	
	[self.selectedAssetTitleField setStringValue:name];
	[self.selectedAssetTitleField setEditable:YES];
	
	if ( mediaURL != nil ) {
		URLString = [mediaURL absoluteString];
	}
	else {
		URLString = @"No URL";
	}
	[self.selectedAssetMediaURLField setStringValue:URLString];
	[self.selectedAssetMediaURLField setEditable:YES];
	
	if ( descURL != nil ) {
		URLString = [descURL absoluteString];
	}
	else {
		URLString = @"No URL";
	}
	[self.selectedAssetDescURLField setStringValue:URLString];
	[self.selectedAssetDescURLField setEditable:YES];
}

- (void)updateSelectionDetailFields
{
	NSInteger selectedRow = [self.outlineView selectedRow];
	if (selectedRow == -1)
	{
		[self clearDetailFields];
	}
	else
	{
		id selectedItem = [self.outlineView itemAtRow:selectedRow]; // [self.assets objectAtIndex:selectedRow];
		
		if ( selectedItem != nil ) {
			if ( [selectedItem isMemberOfClass:[ASAsset class]] ) {
				ASAsset* selectedAsset = (ASAsset*)selectedItem;
				
				[self setDetailFieldsWithName:[selectedAsset name] mediaURL:[selectedAsset mediaFile] descURL:[selectedAsset descFile]];
			}
		}
	}
}

#pragma mark <<< New Asset >>>

- (IBAction)newAsset:sender
{
	[self newAssetWithName:nil
				  metadata:nil
			   dataOptions:nil
		 completionHandler:^(ASAsset *newAsset) {
			 if ( newAsset != nil ) {
				 // update the UI
				 [self updateOutlineView:nil];
				 [self updateSelectionDetailFields];
			 }
		 }];
}

- (void)newAssetWithName:(NSString*)assetName
				metadata:(NSDictionary*)assetMetadata
			 dataOptions:(NSDictionary*)assetDataOptions
	   completionHandler:(void (^)(ASAsset* newAsset))handler
{
	if ( assetName ==nil )
		assetName = @"Untitled";
	
	// bring up the custom sheet
	[self invokeNewAssetSheetNamed:assetName
						  metadata:assetMetadata
					   dataOptions:assetDataOptions
						  delegate:self
					didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
					   contextInfo:(void*)CFBridgingRetain(handler)];
}


#pragma mark <<< New Asset Sheet >>>

- (void)invokeNewAssetSheetNamed:(NSString*)assetName
						metadata:(NSDictionary*)assetMetadata
					 dataOptions:(NSDictionary*)assetDataOptions
						delegate:(id)modalDelegate
				  didEndSelector:(SEL)didEndSelector contextInfo:(void*)contextInfo
{
	ASDocument*        document = [self document];
	
	if ( !self.sheetForNewAsset ) {
#if 0
		[[NSBundle mainBundle] loadNibNamed:@"SAMNewAssetSheet" owner:self topLevelObjects:NULL];
#else
		// 10.7 SDK
		[NSBundle loadNibNamed:@"SAMNewAssetSheet" owner:self];
#endif
	}
	
	[self.nameFieldForNewAsset setStringValue:assetName];
	[self populateAssetLocation:document.defaultAssetLocation];
	[self populateNewAssetMetadata:assetMetadata];
	[self populateNewAssetDataOptions:assetDataOptions];
	[self selectNewAssetFolder:nil];
	[self updateNewAssetWantsDescription:nil];
	
	NSWindow* docWindow = [self window];
	
	[NSApp beginSheet: self.sheetForNewAsset
	   modalForWindow: docWindow
		modalDelegate: modalDelegate
	   didEndSelector: didEndSelector
		  contextInfo: contextInfo];
}

- (IBAction)finishNewAssetSheet:sender
{
	[NSApp endSheet:self.sheetForNewAsset returnCode:NSAlertDefaultReturn];
	
	//printf("** finishNewAssetSheet: done\n") ;
}

- (IBAction)cancelNewAssetSheet:sender
{
	[NSApp endSheet:self.sheetForNewAsset returnCode:NSAlertAlternateReturn];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	ASAsset*       newAsset = nil;
	ASDocument*    document = [self document];
	
	if ( returnCode == NSAlertDefaultReturn ) {
		NSDictionary    *newAssetLocationInfo = [self collectAssetLocation];
		NSUInteger      assetIndex = [document addAssetAtLocation:newAssetLocationInfo
														  content:NO
														 metadata:[self collectNewAssetMetadata]
													  dataOptions:[self collectNewAssetDataOptions]];
		document.defaultAssetLocation = newAssetLocationInfo;
		newAsset = [document.assets objectAtIndex:assetIndex];
	}
	[sheet orderOut:self];
	
	// update UI
	[self updateOutlineView:nil];
	[self updateSelectionDetailFields];
	
	// invoke the user completion handler
	((void(^)(ASAsset*))CFBridgingRelease(contextInfo))(newAsset);
}

- (IBAction)selectNewAssetFolder:sender
{
	NSSearchPathDirectory dirSelector = NSDemoApplicationDirectory;	// will imply undefined!
	
	switch ( [self.locationTypePopupForNewAsset indexOfSelectedItem] ) {
		case 0: dirSelector = NSMoviesDirectory; break;
		case 1: dirSelector = NSPicturesDirectory; break;
		case 2: dirSelector = NSDocumentDirectory; break;
		case 3: dirSelector = NSMusicDirectory; break;
	}
	
	if ( dirSelector == NSDemoApplicationDirectory )
	{
		// bring up the open panel when invoked from UI
		// otherwise leave the chosen location alone
		if ( sender != nil ) {
			NSOpenPanel     *openPanel = [NSOpenPanel openPanel];
			
			[openPanel setAllowsMultipleSelection:NO];
			[openPanel setCanChooseDirectories:YES];
			[openPanel setCanChooseFiles:NO];
			[openPanel beginSheetModalForWindow:self.sheetForNewAsset completionHandler:^(NSInteger result) {
				NSURL*          folderURL = [[openPanel URLs] objectAtIndex:0];
				
				[self.locationFolderURLFieldForNewAsset setStringValue:[folderURL absoluteString]];
			}];
		}
	}
	else {
		NSURL *folderURL = [[[NSFileManager defaultManager] URLForDirectory:dirSelector inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil] URLByResolvingSymlinksInPath];
		
		[self.locationFolderURLFieldForNewAsset setStringValue:[folderURL absoluteString]];
	}
}

/*
 Asset location
 */

- (NSDictionary*)collectAssetLocation
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSURL URLWithString:[self.locationFolderURLFieldForNewAsset stringValue]], kMediaAssetLocationFolderKey,
			[self.nameFieldForNewAsset stringValue], kMediaAssetLocationBasenameKey,
			[NSNumber numberWithBool:YES], kMediaAssetLocationHasMediaKey,
			[NSNumber numberWithBool:self.newAssetWantsDescription], kMediaAssetLocationHasDescriptionKey,
			nil];
}

- (void)populateAssetLocation:(NSDictionary*)locationInfo
{
	NSURL       *folderURL = [locationInfo objectForKey:kMediaAssetLocationFolderKey];
	NSNumber    *wantsDescription = [locationInfo objectForKey:kMediaAssetLocationHasDescriptionKey];
	
	if ( [self.locationTypePopupForNewAsset indexOfSelectedItem]  == -1 ) {
		[self.locationFolderURLFieldForNewAsset setStringValue:[folderURL absoluteString]];
	}
 
	if ( wantsDescription != NULL && [wantsDescription boolValue] ) {
		self.newAssetWantsDescription = YES;
	}
}


/*
 Metadata pane
 */

- (NSDictionary*)collectNewAssetMetadata
{
	NSMutableDictionary* metadataset = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[metadataset setObject:[self.descriptionFieldForNewAsset stringValue] forKey:kFCPXMetadataKeyDescription];
	[metadataset setObject:[self.expirationDatePickerForNewAsset dateValue] forKey:kASMetadataKeyExpirationDate];
	[metadataset setObject:[self.shareIDFieldForNewAsset stringValue] forKey:kFCPXShareMetadataKeyShareID];
	[metadataset setObject:[self.episodeIDFieldForNewAsset stringValue] forKey:kFCPXShareMetadataKeyEpisodeID];
	[metadataset setObject:@([self.episodeNumberFieldForNewAsset integerValue]) forKey:kFCPXShareMetadataKeyEpisodeNumber];
	[metadataset setObject:@"1" forKey:kASMetadataKeyPreparedAsset];
	
	return [NSDictionary dictionaryWithDictionary:metadataset];
}

- (void)populateNewAssetMetadata:(NSDictionary*)metadataset
{
	NSString *description = [metadataset objectForKey:kFCPXMetadataKeyDescription];
	
	if ( description == nil )
		description = @"";
	[self.descriptionFieldForNewAsset setStringValue:description];
	
	NSDate *expiratinoDate = [metadataset objectForKey:kASMetadataKeyExpirationDate];
	
	if ( expiratinoDate == nil )
		expiratinoDate = [NSDate dateWithTimeIntervalSinceNow:0];
	[self.expirationDatePickerForNewAsset setDateValue:expiratinoDate];
	
	NSString* shareID = [metadataset objectForKey:kFCPXShareMetadataKeyShareID];
	if ( shareID == nil )
		shareID = @"";
	[self.shareIDFieldForNewAsset setStringValue:shareID];
	
	NSString* episodeID = [metadataset objectForKey:kFCPXShareMetadataKeyEpisodeID];
	if ( episodeID == nil )
		episodeID = @"";
	[self.episodeIDFieldForNewAsset setStringValue:episodeID];
	
	NSString *episodeNumber = [metadataset objectForKey:kFCPXShareMetadataKeyEpisodeNumber];
	if ( episodeNumber == nil )
		episodeNumber = @"";
	[self.episodeNumberFieldForNewAsset setStringValue:episodeNumber];
}

/*
 Data options pane
 */

- (NSDictionary*)collectNewAssetDataOptions
{
	NSMutableDictionary*    dataOptions = [NSMutableDictionary dictionaryWithCapacity:0];
	
	NSString* theMetadataSetName = [self.metadataSetPopupForNewAsset titleOfSelectedItem];
	if ( theMetadataSetName != nil ) {
		[dataOptions setObject:theMetadataSetName forKey:kMediaAssetDataOptionMetadataSetKey];
	}
	
	return [NSDictionary dictionaryWithDictionary:dataOptions];
}

- (void)populateNewAssetDataOptions:(NSDictionary*)dataOptions
{
	NSArray*    availableMetadataSets = [dataOptions objectForKey:kMediaAssetDataOptionAvailableMetadataSetsKey];
	
	if ( availableMetadataSets != nil && [availableMetadataSets isKindOfClass:[NSArray class]] ) {
		[self.metadataSetPopupForNewAsset removeAllItems];
		[self.metadataSetPopupForNewAsset addItemWithTitle:@"None"];
		[self.metadataSetPopupForNewAsset addItemsWithTitles:availableMetadataSets];
	}
}


- (BOOL)newAssetWantsDescription
{
	return newAssetWantsDescription;
}
- (void)setNewAssetWantsDescription:(BOOL)newValue
{
	newAssetWantsDescription = newValue;
}
- (IBAction)updateNewAssetWantsDescription:(id)sender
{
	[self setNewAssetWantsDescription:[self.hasDecriptionCheckBoxForNewAsset state]];
}


#pragma mark <<< Add/Remove Assets >>>

/*
 add a file as a new asset
 */

- (IBAction)addAsset:sender
{
	ASDocument*    document = [self document];
	// Bring up a open panel
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	
	[openPanel setAllowedFileTypes:[NSArray arrayWithObjects:AVFileTypeQuickTimeMovie, AVFileTypeMPEG4, AVFileTypeAppleM4V, AVFileTypeAIFF, AVFileTypeWAVE, AVFileTypeAppleM4A, @"aiff", nil]];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setMessage:@"Choose asset media file to add"];
	[openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
		if (result == NSOKButton) {
			NSArray *selectedURLs = [openPanel URLs];
			
			for ( NSURL* theURL in selectedURLs ) {
				// create a new Asset and add it to the collection
				[document addURL:theURL content:YES metadata:nil dataOptions:nil];
			}
			
			// update the UI
			[self updateOutlineView:sender];
			[self updateSelectionDetailFields];
		}
	}];
}


/*
 remove asset
 */

- (IBAction)removeSelectedAssets:sender
{
	ASDocument*    document = [self document];
	// find which Assets are selected and remove them
	NSIndexSet *selectedRows = [self.outlineView selectedRowIndexes];
	NSInteger currentIndex = [selectedRows lastIndex];
	
	while (currentIndex != NSNotFound) {
		id selectedItem = [self.outlineView itemAtRow:currentIndex];
		
		if ( selectedItem == nil )
			continue;
		else if ( [selectedItem isMemberOfClass:[ASAsset class]] ) {
			ASAsset *asset = (ASAsset*)selectedItem;
			
			[document removeAsset:asset];
		}
		currentIndex = [selectedRows indexLessThanIndex: currentIndex];
	}
	
	// update the UI
	[self updateOutlineView:sender];
	[self updateSelectionDetailFields];
}


#pragma mark <<< Debugging >>>

#if DEBUG_SHEET_POSITION
- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect
{
	NSLog(@"Sheet rectangle: origin: %d, %d, size: %d, %d", (int)rect.origin.x, (int)rect.origin.y, (int)rect.size.width, (int)rect.size.height);
	return rect;
}
#endif


@end

/**************************************************************************************
 * $Log: ASWindowController.mm $
 * Revision 2 2015/12/23 16:41:58 -0800 harry /FinalCutProX/ADII/harryp
 * init version
 * 
 * Revision 1 2015/11/25 07:05:19 -0800 harry /FinalCutProX/ADII/harryp
 * init version
 * 
 *
 *************************************************************************************/
