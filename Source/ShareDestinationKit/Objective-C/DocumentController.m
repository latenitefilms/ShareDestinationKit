//
//  DocumentController.m
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#import "DocumentController.h"
#import "Document.h"

@implementation DocumentController

- (void)openDocumentWithContentsOfURL:(NSURL *)url display:(BOOL)displayDocument completionHandler:(void (^)(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error))completionHandler
{
	NSError *theErr = nil;
	NSString *documentType = [self typeForContentsOfURL:url error:&theErr];
    
	if ( documentType == nil ) {
		completionHandler(nil, NO, theErr);
		return;
	}

	if ( [documentType isEqualToString:@"Asset Media File"] || [documentType isEqualToString:@"Asset Description File"] ) {
		Document *currentDocument = [self currentDocument];
		
		if ( currentDocument == nil ) {
			NSArray *documents = [self documents];
			
            if ( [documents count] > 0 ) {
                currentDocument = [documents objectAtIndex:0];
            } else {
                currentDocument = [self openUntitledDocumentAndDisplay:YES error:&theErr];
            }
		}
		
		NSUInteger assetIndex = [currentDocument addURL:url content:YES metadata:nil dataOptions:nil];
        
		completionHandler([currentDocument.assets objectAtIndex:assetIndex], NO, theErr);
	}
	else {
		[super openDocumentWithContentsOfURL:url display:displayDocument completionHandler:completionHandler];
	}
}

@end
