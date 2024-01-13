/*
     File: SAMAsset.m
 Abstract: SimpleAssetManager asset class.
 
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

#import "SAMAsset.h"
#import "FCPXMetadataKeys.h"
#import "scriptLog.h"

#import "MediaAssetHelperKeys.h"


const NSString*     kSAMMetadataKeyManagedAsset = @"com.example.apple-samplecode.simpleassetmanager.managedAsset";
const NSString*     kSAMMetadataKeyPreparedAsset = @"com.example.apple-samplecode.simpleassetmanager.prepareAsset";
const NSString*     kSAMMetadataKeyExpirationDate = @"com.example.apple-samplecode.simpleassetmanager.expeirationDate";


@implementation SAMAsset
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
	if (self) {
        principalURL = nil;
		folderLocation = nil;
		mediaExtension = nil;
		descExtension = nil;
	}
	/* Put the logging statement later after the superclass was initialized so we will be able to report the uniqueID */
	SLOG(@"init SAMAsset %@", self.uniqueID);
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
	/* I put the logging statement later after the superclass was initialized
	 so we will be able to report the uniqueID */
	SLOG(@"init SAMAsset %@", self.uniqueID);
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
		
		if ( [SAMAsset isMediaExtension:extension] ) {
			mediaExtension = extension;
			descExtension = @"fcpxml";
		}
		else if ( [SAMAsset isDescExtension:extension] ) {
			descExtension = extension;
			mediaExtension = @"mov";
		}
	}

	SLOG(@"init SAMAsset %@", self.uniqueID);
	return self;
}

/* standard deallocation of our members followed by superclass.
 nothing out of the ordinary here. */

- (void)dealloc
{
	SLOG(@"del SAMAsset %@", self.uniqueID);
	folderLocation = nil;
	mediaExtension = nil;
	descExtension = nil;
    principalURL = nil;
}



/* standard getter methods for the folderLocation, mediaExtension, descriptionExtension, and principalURL properties */

- (NSURL*)folderLocation
{
	SLOG(@"SAMAsset %@ property folderLocation %@", self.uniqueID, folderLocation);
	return folderLocation;
}

- (NSString *)mediaExtension
{
	SLOG(@"SAMAsset %@ property mediaExtension %@", self.uniqueID, mediaExtension);
	return mediaExtension;
}

- (void)setMediaExtension:(NSString *)newMediaExtension
{
	SLOG(@"SAMAsset %@ setting property mediaExtension %@", self.uniqueID, newMediaExtension);
    mediaExtension = newMediaExtension;
}

- (NSString *)descExtension
{
	SLOG(@"SAMAsset %@ property descExtension %@", self.uniqueID, descExtension);
	return descExtension;
}

- (void)setDescExtension:(NSString *)newDescExtension
{
	SLOG(@"SAMAsset %@ setting property descExtension %@", self.uniqueID, newDescExtension);
    descExtension = newDescExtension;
}

- (NSURL*)principalURL
{
	SLOG(@"SAMAsset %@ property principalURL %@", self.uniqueID, principalURL);
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
    return self.mediaExtension != nil;
}

- (BOOL)hasDescription
{
    return self.descExtension != nil;
}


-(NSDictionary*)locationInfo
{
	// build the asset location dictionary
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
    NSURL       *theFile = self.mediaFile;

	if ( [theFile checkResourceIsReachableAndReturnError:nil] ) {
		internalAsset = [AVAsset assetWithURL:theFile];
	}	
}

- (void)loadDescription
{
    NSURL       *theFile = self.descFile;
    
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
	}
	else
		return @"n/a";
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
