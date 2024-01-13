/*
     File: ScriptingSupportCategories.m
 Abstract: Cocoa Scripting Support Categories.
 //  This file contains four Objective-C Categories that handle conversion between the following types of
 //  AppleEvent descriptors and Foundation types
 //
 //  - AppleEvent record descriptor (typeAERecord) and NSDictionary
 //  - AppleEvent list descriptor (typeAEList) and NSArray
 //  - AppleEvent descriptor that may be a list, a record, or something else and id
 //  - AppleEvent file URL descriptor (typeFileURL) and NSURL
 
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

#import "ScriptingSupportCategories.h"

#import <Carbon/Carbon.h>


@implementation NSDictionary (UserDefinedRecord)

+(NSDictionary*)scriptingUserDefinedRecordWithDescriptor:(NSAppleEventDescriptor*)desc
{
    // empty dictinoary to start with
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];

    // keyASUserRecordFields has a list of alternating keys and values
    
    NSAppleEventDescriptor* userFieldItems = [desc descriptorForKeyword:keyASUserRecordFields];
    NSInteger numItems = [userFieldItems numberOfItems];
    
    for ( NSInteger itemIndex = 1; itemIndex <= numItems - 1; itemIndex += 2 ) {
        NSAppleEventDescriptor* keyDesc = [userFieldItems descriptorAtIndex:itemIndex];
        NSAppleEventDescriptor* valueDesc = [userFieldItems descriptorAtIndex:itemIndex + 1];
        
        // convert key and value to Foundation object
        // note the value can be another record or list
        
        NSString* keyString = [keyDesc stringValue];
        id value = [valueDesc objectValue];
        
        // add the key value pair to the dictionary
        
        if ( keyString != nil && value != nil )
            [dict setObject:value forKey:keyString];
    }
    
    // return an immutable copy
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

-(NSAppleEventDescriptor*)scriptingUserDefinedRecordDescriptor
{
    // empty AERecord to start with
    // empty AEList to hold alternating keys and values
    
    NSAppleEventDescriptor* recordDesc = [NSAppleEventDescriptor recordDescriptor];
    NSAppleEventDescriptor* userFieldDesc = [NSAppleEventDescriptor listDescriptor];
    NSInteger userFieldIndex = 1;
    
    // for each key value pair construct descriptors
    
    for ( id key in self ) {
        if ( [key isKindOfClass:[NSString class]] ) {
            NSString* valueString = nil;
            id value = [self objectForKey:key];

            // convert a key that is not string to a string
            
            if ( ! [value isKindOfClass:[NSString class]] )
                valueString = [NSString stringWithFormat:@"%@", value];
            else
                valueString = value;
            
            NSAppleEventDescriptor* valueDesc = [NSAppleEventDescriptor descriptorWithString:valueString];
            NSAppleEventDescriptor* keyDesc = [NSAppleEventDescriptor descriptorWithString:key];
            
            // stick the key and value descriptors into the AEList
            
            if ( valueDesc != nil && keyDesc != nil ) {
                [userFieldDesc insertDescriptor:keyDesc atIndex:userFieldIndex++];
                [userFieldDesc insertDescriptor:valueDesc atIndex:userFieldIndex++];
            }
        }
    }
    
    // stick the AEList into the AERecord with keyASUserRecordFields
    
    [recordDesc setDescriptor:userFieldDesc forKeyword:keyASUserRecordFields];
    
    return recordDesc;
}

@end

@implementation NSArray (UserList)

+(NSArray*)scriptingUserListWithDescriptor:(NSAppleEventDescriptor*)desc
{
    // empty array to start with
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    NSInteger numItems = [desc numberOfItems];
    
    // for each item in the list, convert to Foundation object and add to the array
    
    for ( NSInteger itemIndex = 1; itemIndex <= numItems; itemIndex++ ) {
        NSAppleEventDescriptor* itemDesc = [desc descriptorAtIndex:itemIndex];
        
        [array addObject:[itemDesc objectValue]];
    }
    
    // return an immutable copy
    
    return [NSArray arrayWithArray:array];
}

-(NSAppleEventDescriptor*)scriptingUserListDescriptor
{
    // empty AEList to start with
    
    NSAppleEventDescriptor* listDesc = [NSAppleEventDescriptor listDescriptor];
    NSInteger itemIndex = 1;
    
    // for each object in the array, construct a descriptor and stick that into the AEList
    
    for ( id item in self ) {
        NSAppleEventDescriptor* itemDesc = [NSAppleEventDescriptor descriptorWithObject:item];
        
        [listDesc insertDescriptor:itemDesc atIndex:itemIndex++];
    }
    
    return listDesc;
}

@end


@implementation NSAppleEventDescriptor (GenericObject)

+(NSAppleEventDescriptor*)descriptorWithObject:(id)object
{
    NSAppleEventDescriptor* desc = nil;
	
    if ( [object isKindOfClass:[NSArray class]] ) {
        NSArray*    array = (NSArray*)object;
        
        desc = [array scriptingUserListDescriptor];
    }
    else if ( [object isKindOfClass:[NSDictionary class]] ) {
        NSDictionary*   dict = (NSDictionary*)object;
        
        desc = [dict scriptingUserDefinedRecordDescriptor];
    }
    else if ( [object isKindOfClass:[NSString class]] ) {
        desc = [NSAppleEventDescriptor descriptorWithString:(NSString*)object];
    }
    else if ( [object isKindOfClass:[NSURL class]] ) {
        desc = [NSAppleEventDescriptor descriptorWithURL:(NSURL*)object];
    }
    else {
        // create a printed representation and construct a string descriptor
        
        NSString* valueString = [NSString stringWithFormat:@"%@", object];
		
        desc = [NSAppleEventDescriptor descriptorWithString:valueString];
    }
	
    return desc;
}

-(id)objectValue
{
    DescType    descType = [self descriptorType];
    DescType    bigEndianDescType = 0;
    id          object = nil;
    
    
    switch ( descType ) {
        case typeUnicodeText:
        case typeUTF8Text:
            object = [self stringValue];
            break;
        case typeFileURL:
            object = [self urlValue];
            break;
        case typeAEList:
            object = [NSArray scriptingUserListWithDescriptor:self];
            break;
        case typeAERecord:
            object = [NSDictionary scriptingUserDefinedRecordWithDescriptor:self];
            break;
        case typeSInt16:
        case typeUInt16:
        case typeSInt32:
        case typeUInt32:
        case typeSInt64:
        case typeUInt64:
            object = [NSNumber numberWithInteger:(NSInteger)[self int32Value]];
            break;
        default:

            // create NSData to hold the data for an unfamiliar type

            bigEndianDescType = EndianU32_NtoB(descType);
            NSLog(@"Creating NSData for AE desc type %.4s.", (char*)&bigEndianDescType);
            object = [self data];
            break;
    }
	
    return object;
}

@end

@implementation NSAppleEventDescriptor (URLValue)


+ (NSAppleEventDescriptor *)descriptorWithURL:(NSURL *)url
{
    NSData*     urlData = (NSData *)CFBridgingRelease((CFURLCreateData(NULL, (__bridge CFURLRef)(url), kCFStringEncodingUTF8, TRUE)));
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeFileURL data:urlData];
}

- (NSURL*)urlValue
{
    NSData      *urlData = [self data];
    NSError     *theError = nil;
    NSURL       *theURLValue = nil;
    
    switch ( [self descriptorType] ) {
        case typeFileURL:
            theURLValue = (NSURL *)CFBridgingRelease(CFURLCreateWithBytes(NULL, [urlData bytes], [urlData length], kCFStringEncodingUTF8, NULL));
            break;
    }
    
    if ( theError != nil ) {
        NSLog(@"Failed to retrieve URL value out of an NSAppleEventDescriptor %@, error %@.", self, theError);
    }
    
    return theURLValue;
}

@end
