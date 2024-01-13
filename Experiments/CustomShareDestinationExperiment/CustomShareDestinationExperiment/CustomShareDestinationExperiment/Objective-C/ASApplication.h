/****************************************************************************************
 * Copyright 2015 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * ASApplication.h  $Revision: 2 $
 *
 *		Description
 *
 *
 ***************************************************************************************/

#import <AppKit/NSApplication.h>

#import "ASAsset.h"


@interface ASApplication : NSApplication
{
	//ASAsset* asset ;
	NSArray* assets ;
}

- (instancetype)init ;

- (NSArray*) assets ;
- (MyASAsset*) asset ;

@end
