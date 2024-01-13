/****************************************************************************************
 * Copyright 2015-2016 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * ASAsset.h  $Revision: 3 $
 *
 *		single Asset instantiation to support FCPX Apple Script communication
 *
 *	Based on SAMAsset class fm SimpleAssetManagerSample example from Apple
 *
 *
 ***************************************************************************************/
 
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "ASObject.h"

// Simple Asset Manager metadata keys
extern const NSString*     kASMetadataKeyManagedAsset;
extern const NSString*     kASMetadataKeyPreparedAsset;
extern const NSString*     kASMetadataKeyExpirationDate;


@interface MyASAsset : MyASObject

+ (BOOL)isMediaExtension:(NSString*)extension;
+ (BOOL)isDescExtension:(NSString*)extension;

/* init and dealloc */
- (instancetype)init;
- (instancetype)init:(NSURL*)url;
- (instancetype)init:(NSString*)assetName at:(NSURL*)location media:(NSString*)mediaExt desc:(NSString*)descExt;
- (void)dealloc;

/* properties */
@property (nonatomic, strong, readonly) NSURL* principalURL;
@property (nonatomic, strong, readwrite) NSURL* folderLocation;
@property (nonatomic, strong, readwrite) NSString* mediaExtension;
@property (nonatomic, strong, readwrite) NSString* descExtension;
@property (nonatomic, readonly) BOOL hasMedia;
@property (nonatomic, readonly) BOOL hasDescription;

@property (nonatomic, readonly) NSDictionary	*locationInfo;
// a dictinoary that contains base name, folder location, media extension, and description extension

@property (nonatomic, readonly) NSURL			*mediaFile;
@property (nonatomic, readonly) NSURL			*descFile;

@property (nonatomic, strong, readwrite) NSDictionary   *metadata;
@property (nonatomic, strong, readwrite) NSDictionary   *dataOptions;

- (void)loadMedia;
- (void)loadDescription;

/* metadata and data options */
- (void)addMetadata:(id)value forKey:(const NSString*)key;

- (void)setDataOption:(id)option forKey:(NSString*)key;
- (id)dataOptionForKey:(NSString*)key;

/* conveinence properties */
@property (readonly) NSString* duration;
@property (readonly) CGSize frameSize;
@property (readonly) NSString* frameDuration;

@property (readonly) NSString* episodeID;
@property (readonly) NSNumber* episodeNumber;

@property (readonly) BOOL mediaLoaded;
@property (readonly) BOOL descriptionLoaded;
@property (readonly) BOOL hasRoles;


@end
