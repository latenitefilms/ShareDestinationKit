/*
     File: SAMDocument.h
 Abstract: SimpleAssetManager document class.
 
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

#import <Cocoa/Cocoa.h>
#import "SAMObject.h"
#import "SAMAsset.h"
#import "SAMWindowController.h"


@interface SAMDocument : NSDocument

@property (readonly) SAMWindowController*    primaryWindowController;

// properties
@property NSString				*collectionName;
@property NSString				*collectionDescription;
@property NSMutableArray		*collection;				// array of SAMAsset

@property NSDictionary          *defaultAssetLocation;

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
- (void)removeAsset:(SAMAsset*)asset;

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
