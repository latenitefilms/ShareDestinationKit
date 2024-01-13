/****************************************************************************************
 * Copyright 2001-2015 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * ASObject.h  $Revision: 2 $
 *
 *		Description
 *
 *	Based on SAMObject.h (from SimpleAssetManager eg)
 *
 ***************************************************************************************/
 
#import <Foundation/Foundation.h>

#define OBJECT_SPECIFIER_TYPE_NAME          0
#define OBJECT_SPECIFIER_TYPE_INDEX         1
#define OBJECT_SPECIFIER_TYPE_UNIQUE_ID     2
#define OBJECT_SPECIFIER_TYPE               OBJECT_SPECIFIER_TYPE_UNIQUE_ID


/* The SAMObject class is the root class for all of the AppleScript
 objects we provide in our application.
 
 It is in this class that take care of most of the 'infrastructure'
 type operations needed for maintaining our objects.  In our application
 we assume that all of our objects will have a 'name' property and an
 'id' property and we maintain those properties in this class.
 
 Given that's taken care of here, we implement the objectSpecifier method
 based on the id property.  By doing that here, we don't have to worry about
 implementing an objectSpecifier method in any of our other sub-classes.
 
 For most intentions and purposes, you should be able to use this class
 unmodified as a superclass for your own scriptable objects.
 */
@interface MyASObject : NSObject

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
-(instancetype)init;
- (void)dealloc;


/* ensuring that the id values we are using for unique ids are unique
 is essential go good operation.  Here we provide a class method to vend
 unique id values for use with our objects.  */
+ (NSString *)calculateNewUniqueID;


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

/* calling objectSpecifier asks an object to return an object specifier
 record referring to itself.  You must call setContainer:andProperty: before
 you can call this method.   see the explanation above.
 
 Note: this routine assumes you have added a objectSpecifier method to
 a category of NSApplication that always returns nil (the default value
 for the application class).  */
- (NSScriptObjectSpecifier *)objectSpecifier;


@end

/**************************************************************************************
 * $Log: ASObject.h $
 * Revision 2 2019/09/04 15:52:45 -0700 harry /FinalCutProX/ADII/harryp
 * ASObject name changed to MyASObject as part of ASAsset class name changes 10.15
 * 
 * Revision 1 2015/11/24 17:03:29 -0800 harry /FinalCutProX/ADII/harryp
 * init version
 * 
 *
 *************************************************************************************/
