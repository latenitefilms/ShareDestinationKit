/****************************************************************************************
 * Copyright 2015-2016 Automatic Duck,Inc.  All Rights reserved
 *
 *
 * ASAsset.mm  $Revision: 5 $
 *
 *		single Asset instantiation to support FCPX Apple Script communication
 *
 *	Based on SAMAsset class fm SimpleAssetManagerSample example from Apple
 *
 *
 ***************************************************************************************/
 
#import "ASAsset.h"

#import "FCPXMetadataKeys.h"
#import "scriptLog.h"

#import "MediaAssetHelperKeys.h"
#import "plog.h"

extern int myOpenFile(const char*) ;
extern FILE* gSystemLog ;

const NSString*     kASMetadataKeyManagedAsset = @"com.automaticduck.managedAsset";
const NSString*     kASMetadataKeyPreparedAsset = @"com.automaticduck.prepareAsset";
const NSString*     kASMetadataKeyExpirationDate = @"com.automaticduck.expirationDate";

@implementation MyASAsset
{
	NSURL*          principalURL;
//	NSURL*			folderLocation;
	NSString*		mediaExtension;
	NSString*		descExtension;
	
	NSMutableDictionary*    metadata;
	NSMutableDictionary*    dataOptions;
	
	AVAsset			*internalAsset;
	NSXMLDocument	*internalDescription;
}


// class methods that recognizes supported file types

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


/* Instead of sythesizing our properties here, we implement them manually
 in order to perform logging for debugging purposes. */


/* after initializing our superclasses, we set the properties we're
 maintaining in this class to their default values.
 
 See the description of the NSCreateCommand for more information about
 when your init method will be called.  */


- (instancetype)init
{
	self = [super init];
	if (self)
	{
		principalURL = nil;
		_folderLocation = nil;
		mediaExtension = nil;
		descExtension = nil;
	}
	/* Put the logging statement later after the superclass was initialized so we will be able to report the uniqueID */
	SLOG(@"init ASAsset %@", self.uniqueID);
	return self;
}

- (instancetype)init: (NSString*)assetName at:(NSURL*)location media:(NSString*)mediaExt desc:(NSString*)descExt
{
	self = [super init];
	if (self)
	{
		[self setName:assetName];
		principalURL = [location URLByAppendingPathComponent:assetName];
		[principalURL retain];
		_folderLocation = location;
		[_folderLocation retain];
		mediaExtension = mediaExt;
		[mediaExtension retain];
		descExtension = descExt;
		[descExtension retain];
	}
	/* I put the logging statement later after the superclass was initialized
	 so we will be able to report the uniqueID */
	SLOG(@"init ASAsset %@", self.uniqueID);
	return self;
}

- (instancetype)init:(NSURL*)url
{
	self = [super init];
	if (self)
	{
		NSString* extension = [url pathExtension];
		
		principalURL = [url URLByDeletingPathExtension];
		_folderLocation = [principalURL URLByDeletingLastPathComponent];
		[self setName:[principalURL lastPathComponent]];
		
		if ( [MyASAsset isMediaExtension:extension] )
		{
			mediaExtension = extension;
			descExtension = @"fcpxml";
		}
		else if ( [MyASAsset isDescExtension:extension] )
		{
			descExtension = extension;
			mediaExtension = @"mov";
		}
	}
	
	SLOG(@"init ASAsset %@", self.uniqueID);
	return self;
}

/* standard deallocation of our members followed by superclass.
 nothing out of the ordinary here. */

- (void)dealloc
{
	SLOG(@"del ASAsset %@", self.uniqueID);
	_folderLocation = nil;
	mediaExtension = nil;
	descExtension = nil;
	principalURL = nil;
	
	[super dealloc] ;
}



/* standard getter methods for the folderLocation, mediaExtension, descriptionExtension, and principalURL properties */

- (NSURL*)folderLocation
{
	SLOG(@"ASAsset %@ property folderLocation %@", self.uniqueID, _folderLocation);
	return _folderLocation;
}

- (NSString *)mediaExtension
{
	SLOG(@"ASAsset %@ property mediaExtension %@", self.uniqueID, mediaExtension);
	return mediaExtension;
}

- (void)setMediaExtension:(NSString *)newMediaExtension
{
	SLOG(@"ASAsset %@ setting property mediaExtension %@", self.uniqueID, newMediaExtension);
	mediaExtension = newMediaExtension;
}

- (NSString *)descExtension
{
	SLOG(@"ASAsset %@ property descExtension %@", self.uniqueID, descExtension);
	plog(gSystemLog, "++ ASAsset %s %s\n", 	[self.uniqueID cStringUsingEncoding:NSASCIIStringEncoding],
											[descExtension cStringUsingEncoding:NSASCIIStringEncoding]);
	return descExtension;
}

- (void)setDescExtension:(NSString *)newDescExtension
{
	SLOG(@"ASAsset %@ setting property descExtension %@", self.uniqueID, newDescExtension);
	descExtension = newDescExtension;
}

- (NSURL*)principalURL
{
	SLOG(@"ASAsset %@ property principalURL %@", self.uniqueID, principalURL);
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
	if ( principalURL != nil && descExtension != nil )
		return [principalURL URLByAppendingPathExtension:descExtension];
	else
		return nil;
}

- (BOOL)hasMedia
{
#if 0
	return self.mediaExtension != nil;
#else
	return NO;
#endif
}

- (BOOL)hasDescription
{
#if 1
	return self.descExtension != nil;
#else
	return NO ;
#endif
}


-(NSDictionary*)locationInfo
{
	// build the asset location dictionary
	NSMutableDictionary*    assetLocation = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[assetLocation setObject:self.folderLocation forKey:kMediaAssetLocationFolderKey];
	[assetLocation setObject:self.name forKey:kMediaAssetLocationBasenameKey];
	
	[assetLocation setObject:[NSNumber numberWithBool: ( self.hasMedia ) ? YES : NO] forKey:kMediaAssetLocationHasMediaKey];

	if ( self.hasDescription )
	{
		[assetLocation setObject:[NSNumber numberWithBool:YES] forKey:kMediaAssetLocationHasDescriptionKey];
	}
	plog(gSystemLog, "++ locationInfo: %s\n", [assetLocation.description cStringUsingEncoding:NSASCIIStringEncoding]) ;
	return [NSDictionary dictionaryWithDictionary:assetLocation];
}

- (NSDictionary*)metadata
{
	return [NSDictionary dictionaryWithDictionary:metadata];
}

- (void)setMetadata:(NSDictionary *)newMetadata
{
	metadata = [NSMutableDictionary dictionaryWithDictionary:newMetadata];
	[metadata retain] ;
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
	[dataOptions retain] ;
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
	NSURL       *theFile = self.mediaFile;
	
	if ( [theFile checkResourceIsReachableAndReturnError:nil] )
	{
		internalAsset = [AVAsset assetWithURL:theFile];
	}
}

- (void)loadDescription
{
	NSURL       *theFile = self.descFile;
	
	if ( [theFile checkResourceIsReachableAndReturnError:nil] )
	{
		NSError*		loadError = nil;
		
		internalDescription = [[NSXMLDocument alloc] initWithContentsOfURL:theFile options:0 error:&loadError];
	}
}

- (NSString*)duration
{
	if ( [self.mediaFile checkResourceIsReachableAndReturnError:nil] )
	{
		CMTime	dur = [internalAsset duration];
		
		return [NSString stringWithFormat:@"%lld/%ds", dur.value, dur.timescale];
	}
	else
		return @"n/a";
}

- (CGSize) frameSize
{
	if ( ! [self hasRoles] )
	{
		NSArray* videoTracks = [internalAsset tracksWithMediaType:AVMediaTypeVideo];
		
		if ( videoTracks != nil && [videoTracks count] > 0 )
		{
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
	if ( ! [self hasRoles] )
	{
		NSArray* videoTracks = [internalAsset tracksWithMediaType:AVMediaTypeVideo];
		
		if ( videoTracks != nil && [videoTracks count] > 0 )
		{
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
