/****************************************************************************************
 * Copyright 2001-2015 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * ASObject.mm  $Revision: 4 $
 *
 *		Description
 *
 *
 ***************************************************************************************/

#import "ASObject.h"
#import "scriptLog.h"

@implementation MyASObject
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
-(instancetype) init
{
	self = [super init];
	if (self)
	{
		/* calkl our unique id generator to make a new id */
		self.uniqueID = [MyASObject calculateNewUniqueID];
		/* we use a global counter to generate unique names */
		self.name = [NSString stringWithFormat:@"Untitled %ld", [MyASObject calculateNameCounter]];
	}
	/* I put the logging statement later after the initialization so we can see
	 the uniqueID */
	SLOG(@"init SAMObject %@", self.uniqueID);
	return self;
}

/* add logging to dealloc. */
- (void) dealloc
{
	SLOG(@"dealloc SAMObject %@", self.uniqueID);
	[super dealloc] ;
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
+ (NSString *)calculateNewUniqueID
{
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
#if 0
	theID = [NSString stringWithFormat:@"SSO-%d-%ld", gMyProcessID, gSAMObjectCounter++];
#else
	theID = [NSString stringWithFormat:@"SSO-%d-%d", gMyProcessID, 1];
#endif
	SLOG(@"new unique id ='%@'", theID);
	return theID;
}


+ (unsigned long)calculateNameCounter
{
	static unsigned long gNameCounter = 1;
#if 0
	return gNameCounter++;
#else
	return gNameCounter;
#endif
}


/* standard setter and getter methods for the container and
 containerProperty slots.  The only thing that's unusual here is that
 we have lumped the setter functions together because we will always
 call them together. */
- (id)container
{
	SLOG(@" of %@ as %@", self.uniqueID, container);
	return container;
}

- (NSString *)containerProperty
{
	SLOG(@" return  %@ as '%@'", self.uniqueID, containerProperty);
	return containerProperty;
}

- (void)setContainer:(id)value andProperty:(NSString *)property
{
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

- (void)setUniqueID:(NSString *)value
{
	SLOG(@" of %@ to '%@'", self.uniqueID, value);
	if (uniqueID != value)
	{
		uniqueID = [value copy];
	}
}


/* standard setter and getter methods for the 'name' property
 nothing out of the ordinary here. */
- (NSString *)name
{
	SLOG(@" of %@ as '%@'", self.uniqueID, name);
	return name;
}

- (void)setName:(NSString *)value
{
	SLOG(@" of %@ to '%@'", self.uniqueID, value);
	if (name != value)
	{
		name = [value copy];
	}
}


/* calling objectSpecifier asks an object to return an object specifier
 record referring to itself.  You must call setContainer:andProperty: before
 you can call this method. */
- (NSScriptObjectSpecifier *)objectSpecifier
{
	SLOG(@" of %@ ", self.uniqueID);
#if OBJECT_SPECIFIER_TYPE == OBJECT_SPECIFIER_TYPE_NAME
	return [[NSNameSpecifier alloc]
			initWithContainerClassDescription:(NSScriptClassDescription*)[self.container classDescription] containerSpecifier:[self.container objectSpecifier] key:self.containerProperty name:self.name];
#elif OBJECT_SPECIFIER_TYPE == OBJECT_SPECIFIER_TYPE_UNIQUE_ID
	NSScriptClassDescription* classDesc = (NSScriptClassDescription*)[self.container classDescription] ;
	NSScriptObjectSpecifier* objSpec = [self.container objectSpecifier];
	
#if 0
	return [[NSUniqueIDSpecifier alloc]
			initWithContainerClassDescription:(NSScriptClassDescription*)[self.container classDescription] containerSpecifier:[self.container objectSpecifier] key:self.containerProperty uniqueID:self.uniqueID];
#else
	NSScriptClassDescription* containerClassDesc = (NSScriptClassDescription*)[NSScriptClassDescription classDescriptionForClass:[NSApp class]] ;
	return [[NSUniqueIDSpecifier alloc]
			initWithContainerClassDescription:containerClassDesc
			containerSpecifier:nil
			key:self.containerProperty
			uniqueID:self.uniqueID];
#endif

#endif
}


@end

/**************************************************************************************
 * $Log: ASObject.mm $
 * Revision 4 2020/03/27 12:20:34 -0700 harry /FinalCutProX/ADII/harryp
 * added import of "scriptLog.h" (needed for Xcode10 compile)
 * 
 * Revision 3 2019/09/04 15:52:46 -0700 harry /FinalCutProX/ADII/harryp
 * ASObject name changed to MyASObject as part of ASAsset class name changes 10.15
 * 
 * Revision 2 2016/02/12 09:53:52 -0800 harry /FinalCutProX/ADII/harryp
 * change to objectSpecifier method (per Kaz@Apple). magic.
 * 
 * Revision 1 2015/11/24 17:03:30 -0800 harry /FinalCutProX/ADII/harryp
 * init version
 * 
 *
 *************************************************************************************/
