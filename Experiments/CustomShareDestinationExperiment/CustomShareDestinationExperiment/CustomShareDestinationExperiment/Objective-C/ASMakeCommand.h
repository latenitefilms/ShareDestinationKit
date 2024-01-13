/****************************************************************************************
 * Copyright 2015-2016 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * ASMakeCommand  $Revision: 2 $
 *
 *		This class is reponsible for responsing to the Apple Script "make" new asset
 *	command.
 *
 * Based on SAMMakeCommand class from the SampleAssetManagerSimple eg from Apple
 *
 ***************************************************************************************/
 
#import <Foundation/Foundation.h>

@interface ASMakeCommand :  NSCreateCommand

- (id)performDefaultImplementation;

@end
