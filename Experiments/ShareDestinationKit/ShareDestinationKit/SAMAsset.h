/*
     File: SAMAsset.h
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

#import <Foundation/Foundation.h>
#import "SAMObject.h"
#import <AVFoundation/AVFoundation.h>

// Simple Asset Manager metadata keys
const NSString*     kSAMMetadataKeyManagedAsset;
const NSString*     kSAMMetadataKeyPreparedAsset;
const NSString*     kSAMMetadataKeyExpirationDate;


@interface SAMAsset : SAMObject

+ (BOOL)isMediaExtension:(NSString*)extension;
+ (BOOL)isDescExtension:(NSString*)extension;

/* init and dealloc */
- (instancetype)init;
- (instancetype)init:(NSURL*)url;
- (instancetype)init:(NSString*)assetName at:(NSURL*)location media:(NSString*)mediaExt desc:(NSString*)descExt;
- (void)dealloc;

/* properties */
@property (nonatomic, readonly) NSURL* principalURL;
@property (nonatomic, readonly) NSURL* folderLocation;
@property (nonatomic, readwrite) NSString* mediaExtension;
@property (nonatomic, readwrite) NSString* descExtension;
@property (nonatomic, readonly) BOOL hasMedia;
@property (nonatomic, readonly) BOOL hasDescription;

@property (nonatomic, readonly) NSDictionary	*locationInfo;
	// a dictinoary that contains base name, folder location, media extension, and description extension

@property (nonatomic, readonly) NSURL			*mediaFile;
@property (nonatomic, readonly) NSURL			*descFile;

@property (nonatomic, readwrite) NSDictionary   *metadata;
@property (nonatomic, readwrite) NSDictionary   *dataOptions;

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
