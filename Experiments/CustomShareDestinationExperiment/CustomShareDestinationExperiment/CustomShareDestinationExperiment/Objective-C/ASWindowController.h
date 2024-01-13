/****************************************************************************************
 * Copyright 2001-2015 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * ASWindowController.h  $Revision: 1 $
 *
 *		Description
 *
 *
 ***************************************************************************************/
 
#import <Cocoa/Cocoa.h>

@class ASAsset;

@interface ASWindowController : NSWindowController

- (instancetype)init;
- (instancetype)initWithWindow:(NSWindow *)window;

// update UI elements
- (void)clearDetailFields;
- (void)setDetailFieldsWithName:(NSString*)name mediaURL:(NSURL*)mediaURL descURL:(NSURL*)descURL;

- (void)updateSelectionDetailFields;
- (void)updateOutlineView:(id)sendor;

// add new asset without the contents
- (IBAction)newAsset:sender;
- (IBAction)finishNewAssetSheet:sender;
- (IBAction)cancelNewAssetSheet:sender;

// invoke the new asset UI
- (void)newAssetWithName:(NSString*)assetName
				metadata:(NSDictionary*)assetMetadata
			 dataOptions:(NSDictionary*)assetDataOptions
	   completionHandler:(void (^)(ASAsset* newAsset))handler;

@property (readwrite) BOOL   newAssetWantsDescription;
- (IBAction)updateNewAssetWantsDescription:(id)sender;

@end

/**************************************************************************************
 * $Log: ASWindowController.h $
 * Revision 1 2015/11/25 07:05:19 -0800 harry /FinalCutProX/ADII/harryp
 * init version
 * 
 *
 *************************************************************************************/
