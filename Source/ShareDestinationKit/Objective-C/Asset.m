//
//  Asset.m
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#import "Asset.h"
#import "FCPXMetadataKeys.h"
#import "MediaAssetHelperKeys.h"

const NSString* kMetadataKeyManagedAsset     = @"com.latenitefilms.ShareDestinationKit.managedAsset";
const NSString* kMetadataKeyPreparedAsset    = @"com.latenitefilms.ShareDestinationKit.prepareAsset";
const NSString* kMetadataKeyExpirationDate   = @"com.latenitefilms.ShareDestinationKit.expeirationDate";

@implementation Asset
{
    NSURL*          principalURL;
	NSURL*			folderLocation;
	NSString*		mediaExtension;
	NSString*		descExtension;

	NSMutableDictionary*    metadata;
    NSMutableDictionary*    dataOptions;

	AVAsset			*internalAsset;
	NSXMLDocument	*internalDescription;
}

// ------------------------------------------------------------
// Class methods that recognizes supported file types:
// ------------------------------------------------------------
+ (BOOL)isDescExtension:(NSString*)extension
{
	if ( [extension isEqualToString:@"fcpxml"] )
		return YES;
	else
		return NO;
}

+ (BOOL)isMediaExtension:(NSString*)extension
{
	if ( [extension isEqualToString:@"mov"] )
		return YES;
    else if ( [extension isEqualToString:@"mp4"] )
		return YES;
	else
		return NO;	
}

// ------------------------------------------------------------
// Instead of synthesizing our properties here, we implement
// them manually in order to perform logging for debugging
// purposes.
//
// After initializing our superclasses, we set the properties
// we're maintaining in this class to their default values.
//
// See the description of the NSCreateCommand for more
// information about when your init method will be called.
// ------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
	if (self) {
        principalURL = nil;
		folderLocation = nil;
		mediaExtension = nil;
		descExtension = nil;
	}
    
    // ------------------------------------------------------------
	// Put the logging statement later after the superclass was
    // initialized so we will be able to report the uniqueID:
    // ------------------------------------------------------------
    NSLog(@"[ShareDestinationKit] INFO - init Asset %@", self.uniqueID);
	return self;
}

- (instancetype)init: (NSString*)assetName at:(NSURL*)location media:(NSString*)mediaExt desc:(NSString*)descExt
{
    self = [super init];
	if (self) {
		[self setName:assetName];
        principalURL = [location URLByAppendingPathComponent:assetName];
		folderLocation = location;
		mediaExtension = mediaExt;
		descExtension = descExt;
	}
    
    // ------------------------------------------------------------
	// I put the logging statement later after the superclass was
    // initialized so we will be able to report the uniqueID:
    // ------------------------------------------------------------
    NSLog(@"[ShareDestinationKit] INFO - init Asset %@", self.uniqueID);
	return self;
}

- (instancetype)init:(NSURL*)url 
{
    self = [super init];
	if (self) {
		NSString* extension = [url pathExtension];
		
        principalURL = [url URLByDeletingPathExtension];
		folderLocation = [principalURL URLByDeletingLastPathComponent];
		[self setName:[principalURL lastPathComponent]];
		
		if ( [Asset isMediaExtension:extension] ) {
			mediaExtension = extension;
			descExtension = @"fcpxml";
		}
		else if ( [Asset isDescExtension:extension] ) {
			descExtension = extension;
			mediaExtension = @"mov";
		}
	}

    NSLog(@"[ShareDestinationKit] INFO - init Asset %@", self.uniqueID);
	return self;
}

// ------------------------------------------------------------
// Standard deallocation of our members followed by superclass.
// Nothing out of the ordinary here:
// ------------------------------------------------------------
- (void)dealloc
{
    NSLog(@"[ShareDestinationKit] INFO - dealloc Asset %@", self.uniqueID);
	folderLocation = nil;
	mediaExtension = nil;
	descExtension = nil;
    principalURL = nil;
}

// ------------------------------------------------------------
// Standard getter methods for the folderLocation,
// mediaExtension, descriptionExtension, and principalURL
// properties:
// ------------------------------------------------------------
- (NSURL*)folderLocation
{
    NSLog(@"[ShareDestinationKit] INFO - Asset %@ property folderLocation %@", self.uniqueID, folderLocation);
	return folderLocation;
}

- (NSString *)mediaExtension
{
    NSLog(@"[ShareDestinationKit] INFO - Asset %@ property mediaExtension %@", self.uniqueID, mediaExtension);
	return mediaExtension;
}

- (void)setMediaExtension:(NSString *)newMediaExtension
{
    NSLog(@"[ShareDestinationKit] INFO - Asset %@ setting property mediaExtension %@", self.uniqueID, newMediaExtension);
    mediaExtension = newMediaExtension;
}

- (NSString *)descExtension
{
    NSLog(@"[ShareDestinationKit] INFO - Asset %@ property descExtension %@", self.uniqueID, descExtension);
	return descExtension;
}

- (void)setDescExtension:(NSString *)newDescExtension
{
    NSLog(@"[ShareDestinationKit] INFO - Asset %@ setting property descExtension %@", self.uniqueID, newDescExtension);
    descExtension = newDescExtension;
}

- (NSURL*)principalURL
{
    NSLog(@"[ShareDestinationKit] INFO - Asset %@ property principalURL %@", self.uniqueID, principalURL);
	return principalURL;
}

-(NSURL*)mediaFile
{
	if ( principalURL != nil && mediaExtension != nil )
        return [principalURL URLByAppendingPathExtension:mediaExtension];
	else
		return nil;
}

-(NSURL*)descFile
{
    if ( principalURL != nil && descExtension != nil ) {
        return [principalURL URLByAppendingPathExtension:descExtension];
    } else {
        return nil;
    }
}

- (BOOL)hasMedia
{
    return self.mediaExtension != nil;
}

- (BOOL)hasDescription
{
    return self.descExtension != nil;
}

-(NSDictionary*)locationInfo
{
    // ------------------------------------------------------------
	// Build the asset location dictionary:
    // ------------------------------------------------------------
    NSMutableDictionary*    assetLocation = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [assetLocation setObject:self.folderLocation forKey:kMediaAssetLocationFolderKey];
    [assetLocation setObject:self.name forKey:kMediaAssetLocationBasenameKey];

	if ( self.hasMedia ) {
        [assetLocation setObject:[NSNumber numberWithBool:YES] forKey:kMediaAssetLocationHasMediaKey];
    }
	if ( self.hasDescription ) {
        [assetLocation setObject:[NSNumber numberWithBool:YES] forKey:kMediaAssetLocationHasDescriptionKey];
    }
    	
	return [NSDictionary dictionaryWithDictionary:assetLocation];
}

- (NSDictionary*)metadata
{
    return [NSDictionary dictionaryWithDictionary:metadata];
}

- (void)setMetadata:(NSDictionary *)newMetadata
{
    metadata = [NSMutableDictionary dictionaryWithDictionary:newMetadata];
}

- (void)addMetadata:(id)value forKey:(NSString*)key
{
    if ( metadata == nil )
        metadata = [NSMutableDictionary dictionaryWithCapacity:0];
	[metadata setObject:value forKey:key];
}

- (NSDictionary*)dataOptions
{
    return [NSDictionary dictionaryWithDictionary:dataOptions];
}

- (void)setDataOptions:(NSDictionary *)newOptions
{
    dataOptions = [NSMutableDictionary dictionaryWithDictionary:newOptions];
}

- (void)setDataOption:(id)option forKey:(NSString*)key
{
    [dataOptions setObject:option forKey:key];
}

- (id)dataOptionForKey:(NSString*)key
{
    return [dataOptions objectForKey:key];
}

- (void)loadMedia
{
    NSURL *theFile = self.mediaFile;

	if ( [theFile checkResourceIsReachableAndReturnError:nil] ) {
		internalAsset = [AVAsset assetWithURL:theFile];
	}	
}

- (void)loadDescription
{
    NSURL *theFile = self.descFile;
    
	if ( [theFile checkResourceIsReachableAndReturnError:nil] ) {
		NSError*		loadError = nil;
		
		internalDescription = [[NSXMLDocument alloc] initWithContentsOfURL:theFile options:0 error:&loadError];
	}
}

- (NSString*)duration
{
	if ( [self.mediaFile checkResourceIsReachableAndReturnError:nil] ) {
		CMTime	dur = [internalAsset duration];
		return [NSString stringWithFormat:@"%lld/%ds", dur.value, dur.timescale];
    } else {
        return @"n/a";
    }
}

- (CGSize) frameSize
{
    if ( ! [self hasRoles] ) {
        NSArray* videoTracks = [internalAsset tracksWithMediaType:AVMediaTypeVideo];

        if ( videoTracks != nil && [videoTracks count] > 0 ) {
            AVAssetTrack* videoTrack = [videoTracks objectAtIndex:0];
            
            return [videoTrack naturalSize];
        }
        else
            return CGSizeZero;
    }
    return CGSizeZero;
}

- (NSString*) frameDuration
{
    if ( ! [self hasRoles] ) {
        NSArray* videoTracks = [internalAsset tracksWithMediaType:AVMediaTypeVideo];
        
        if ( videoTracks != nil && [videoTracks count] > 0 ) {
            AVAssetTrack* videoTrack = [videoTracks objectAtIndex:0];
            float frameRate = [videoTrack nominalFrameRate];
            CMTimeScale timeScale = [videoTrack naturalTimeScale];

            return [NSString stringWithFormat:@"%ld/%ds", (long)( timeScale / frameRate ), timeScale];

        }
        else
            return  @"n/a";
    }
    return @"n/a";
}

- (NSString*)shareID
{
    return [metadata objectForKey:kFCPXShareMetadataKeyShareID];
}

- (NSString*)episodeID
{
    return [metadata objectForKey:kFCPXShareMetadataKeyEpisodeID];
}

- (NSNumber*)episodeNumber
{
    return [metadata objectForKey:kFCPXShareMetadataKeyEpisodeNumber];
}

- (BOOL)mediaLoaded
{
	return internalAsset != nil;
}

- (BOOL)descriptionLoaded
{
	return internalDescription != nil;
}

- (BOOL)hasRoles
{
    return NO;
}

@end
