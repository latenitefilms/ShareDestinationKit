/****************************************************************************************
 * Copyright 2001-2015 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * XMotionDocument.h  $Revision: 1 $
 *
 *		Description
 *
 *
 ***************************************************************************************/
 

#import <Cocoa/Cocoa.h>

#import "ASObject.h"
#import "ASAsset.h"
#import "ASWindowController.h"


@interface ASDocument : NSDocument

@property (readonly) ASWindowController*    primaryWindowController;

// properties
@property (strong) NSString				*collectionName;
@property (strong) NSString				*collectionDescription;
@property (strong) NSMutableArray		*collection;				// array of ASAsset

@property (strong) NSDictionary          *defaultAssetLocation;

// asset access methods
- (NSURL*)assetURLAtIndex:(NSUInteger)index;
- (NSUInteger)assetIndexForURL:(NSURL*)url;
- (NSUInteger)assetIndexForLocation:(NSDictionary*)locationInfo;

// adding asset
- (NSUInteger)addAssetAtURL:(NSURL*)url
					content:(BOOL)load
				   metadata:(NSDictionary*)metadataset
				dataOptions:(NSDictionary*)options;
- (NSUInteger)addAssetAtLocation:(NSDictionary*)locationInfo
						 content:(BOOL)load
						metadata:(NSDictionary*)metadataset
					 dataOptions:(NSDictionary*)options;

// removig asset
- (void)removeAssetAtIndex:(NSUInteger)index;
- (void)removeAsset:(ASAsset*)asset;

// add a URL either as an asset or a role
- (NSUInteger)addURL:(NSURL*)url content:(BOOL)load metadata:(NSDictionary*)metadataset dataOptions:(NSDictionary*)dataOptions;

// scriptping bookkeeping

/* properties for the container and containerProperty fields. */
@property (readonly) id container;
@property (readonly) NSString *containerProperty;


/* since the container and containerProperty fields are always set at the
 same time, we have lumped those setter calls together into one call that
 sets both. */
- (void)setContainer:(id)value andProperty:(NSString *)property;


/* kvc Cocoa property for the 'id' AppleScript property */
@property (copy) NSString *uniqueID;

/* kvc Cocoa property for the 'name' AppleScript property */
@property (copy) NSString *name;


/* kvc methods for the 'assets' AppleScript element.  Here we implement the methods
 necessary for maintaining the list of assets inside of a Document.  Note the names.
 In our scripting definition file we specified that the 'document' class contains an
 element of type 'asset', like so:
 <element type="asset"/>
 Cocoa will use the plural form of the class name, 'assets',  when naming the
 property used by AppleScript to access the list of buckets, and we should use
 the property name when naming our methods.  So, using the property name, we
 name our methods as follows:
 - (NSArray*) assets; (implied by property declaration)
 -(void) insertInAssets:(id) asset;
 -(void) insertInAssets:(id) asset atIndex:(unsigned)index;
 -(void) removeFromAssetsAtIndex:(unsigned)index;
 */

/* return the entire list of assets */
@property (nonatomic, readonly) NSArray *assets;

/* insert a asset at the beginning of the list */
-(void) insertInAssets:(id) asset;

/* insert a asset at some position in the list */
-(void) insertInAssets:(id) asset atIndex:(unsigned)index;

/* remove a asset from the list */
-(void) removeFromAssetsAtIndex:(unsigned)index;

@end

/**************************************************************************************
 * $Log: ASDocument.h $
 * Revision 1 2015/11/25 07:01:59 -0800 harry /FinalCutProX/ADII/harryp
 * init version.
 * 
 *
 *************************************************************************************/
