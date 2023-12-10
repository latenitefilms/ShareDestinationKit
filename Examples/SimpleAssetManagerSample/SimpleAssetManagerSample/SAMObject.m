/*
     File: SAMObject.m
 Abstract: SimpleAssetManager base object classs for scriptable object.
 
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

#import "SAMObject.h"
#import "scriptLog.h"

#include <sys/types.h>
#include <unistd.h>

@implementation SAMObject
{
	/* The following two variables are used in calculating the objectSpecifier
	 for this object.  To do that, we maintain a reference to the containing
	 object (container) and the name of the Cocoa key (containerProperty) on
	 that container where our instance is being stored.  For example, the Bucket
	 class contains a list of 'trinket' objects in it.  A trinket contained in
	 an instance of the Bucket class would retain a reference to the Bucket object
	 it is stored in along with the name of the Cocoa key ('trinkets') being used
	 to reference the list of trinkets inside of that Bucket. */
	id container; /* reference to the object containing this object */
	NSString* containerProperty; /* name of the cocoa key on container specifying the
								  list property where this object is stored */

	/* Storage for our id and name AppleScript properties. */
	NSString* uniqueID; /* A unique id value for this object */
	NSString* name; /* The name property for this object */
}


/* Instead of sythesizing our properties here, we implement them manually
 in order to perform logging for debugging purposes. */


/* storage management
 
 The normal sequence of events when an object is created is as follows:
 
 1. an AppleScript 'make' command will allocate and initialize an instance
 of the class it has been asked to create.  For example, it may create a Trinket.
 
 2. then it will call the insertInXXXXX: insertInXXXXX:atIndex: method on the container
 object where the new object will be stored.  For example, if we were being asked
 to create a Trinket in a Bucket, then the make command would create an instance
 of Trinket and then it would call insertInTrinkets: on the Bucket object.
 
 3. Inside of the insertInXXXXX: or insertInXXXXX:atIndex: you must record the
 parent object and the parent's property key for the new object being created so
 you can create a objectSpecifier later.  In this class, we have defined the
 setContainer:andProperty: for that purpose.  For example, inside of our
 insertInTrinkets: method on our Bucket object, we the setContainer:andProperty:
 method on the trinket object like so:
 [trinket setContainer:self andProperty:@"trinkets"]
 to inform the trinket object who its container is and the name of the Cocoa key
 on that container object used for the list of trinkets.
 */
-(instancetype) init {
    self = [super init];
    if (self) {
		/* calkl our unique id generator to make a new id */
		self.uniqueID = [SAMObject calculateNewUniqueID];
		/* we use a global counter to generate unique names */
		self.name = [NSString stringWithFormat:@"Untitled %ld", [SAMObject calculateNameCounter]];
	}
	/* I put the logging statement later after the initialization so we can see
	 the uniqueID */
	SLOG(@"init SAMObject %@", self.uniqueID);
	return self;
}

/* add logging to dealloc. */
- (void) dealloc {
	SLOG(@"dealloc SAMObject %@", self.uniqueID);
}



/* calculateNewUniqueID returns a new unique id value that can be used
 to uniquely idenfity an scriptable object.  Our main concern here is that the
 id value be unique within our process AND that it is unique to the specific
 instance of our process (in case our application is re-launched for some reason
 while a script is running).
 
 To guarantee uniqueness within our process, we use a simple counting global
 variable, and to guarantee the values we return are unique to our process instance
 we mix in our process id number.
 
 For convenience and ease of idenfification, I put the application's initials at the
 beginning of the id string.  */
+ (NSString *)calculateNewUniqueID {
	static unsigned long gSAMObjectCounter; /* our SAMObject id generator */
	static pid_t gMyProcessID; /* unique id of our process */
	static BOOL gUniqueInited = NO; /* our SAMObject id generator */
	NSString* theID;
	
	/* set up code for our id generator */
	if ( ! gUniqueInited ) {
		gMyProcessID = getpid(); /* guaranteed unique for our process, see man getpid */
		gSAMObjectCounter = 1; /* guaranteed unique within our process */
		gUniqueInited = YES;
	}
	/* we'll return unique id values as strings composed of the process id followed
	 by a unique count value.  see the man page for getpid for more info about process
	 id values.  */
	theID = [NSString stringWithFormat:@"SSO-%d-%ld", gMyProcessID, gSAMObjectCounter++];
	SLOG(@"new unique id ='%@'", theID);
	return theID;
}


+ (unsigned long)calculateNameCounter {
	static unsigned long gNameCounter = 1;
	
	return gNameCounter++;
}


/* standard setter and getter methods for the container and
 containerProperty slots.  The only thing that's unusual here is that
 we have lumped the setter functions together because we will always
 call them together. */
- (id)container {
	SLOG(@" of %@ as %@", self.uniqueID, container);
    return container;
}

- (NSString *)containerProperty {
	SLOG(@" return  %@ as '%@'", self.uniqueID, containerProperty);
    return containerProperty;
}

- (void)setContainer:(id)value andProperty:(NSString *)property {
	SLOG(@" of %@ to %@ and '%@'", self.uniqueID, [value class], property);
    if (container != value) {
		container = value;
    }
    if (containerProperty != property) {
        containerProperty = [property copy];
    }
}




/* standard setter and getter methods for the 'uniqueID' property
 nothing out of the ordinary here. */
- (NSString *)uniqueID {
    return uniqueID;
}

- (void)setUniqueID:(NSString *)value {
	SLOG(@" of %@ to '%@'", self.uniqueID, value);
    if (uniqueID != value) {
        uniqueID = [value copy];
    }
}


/* standard setter and getter methods for the 'name' property
 nothing out of the ordinary here. */
- (NSString *)name {
	SLOG(@" of %@ as '%@'", self.uniqueID, name);
    return name;
}

- (void)setName:(NSString *)value {
	SLOG(@" of %@ to '%@'", self.uniqueID, value);
    if (name != value) {
        name = [value copy];
    }
}


/* calling objectSpecifier asks an object to return an object specifier
 record referring to itself.  You must call setContainer:andProperty: before
 you can call this method. */
- (NSScriptObjectSpecifier *)objectSpecifier {
	SLOG(@" of %@ ", self.uniqueID);
#if OBJECT_SPECIFIER_TYPE == OBJECT_SPECIFIER_TYPE_NAME
	return [[NSNameSpecifier alloc]
			initWithContainerClassDescription:(NSScriptClassDescription*)[self.container classDescription] containerSpecifier:[self.container objectSpecifier] key:self.containerProperty name:self.name];
#elif OBJECT_SPECIFIER_TYPE == OBJECT_SPECIFIER_TYPE_UNIQUE_ID
	return [[NSUniqueIDSpecifier alloc]
			initWithContainerClassDescription:(NSScriptClassDescription*)[self.container classDescription] containerSpecifier:[self.container objectSpecifier] key:self.containerProperty uniqueID:self.uniqueID];
#endif
}


@end
