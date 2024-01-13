/****************************************************************************************
 * Copyright 2015 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * ASApplication.mm  $Revision: 3 $
 *
 *		Description
 *
 *
 ***************************************************************************************/
 
#import "ASApplication.h"

@implementation ASApplication
{
	// @property ASAsset*	assets;  (auto-synthesized)
	//ASAsset* asset ;
}

- (instancetype)init
{
	self = [super init];
	//asset = [[ASAsset alloc] init] ;
	MyASAsset* asset = [[MyASAsset alloc] init] ;
	[asset setContainer:self andProperty:@"assets"] ;
	
	assets = [NSArray arrayWithObject: asset] ;
	[assets retain];
	return self;
}

- (NSArray*)assets
{
	return assets ;
}

- (MyASAsset*)asset
{
	return [assets objectAtIndex:0] ;
}


@end

