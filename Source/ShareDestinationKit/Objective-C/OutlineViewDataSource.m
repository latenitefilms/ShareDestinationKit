//
//  OutlineViewDataSource.m
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#import "OutlineViewDataSource.h"
#import "Asset.h"
#import "Document.h"
#import "WindowController.h"

@implementation WindowController(OutlineView)

// ------------------------------------------------------------
// Outline View - Number of Children Of Item:
// ------------------------------------------------------------
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    Document* document = [self document];
    
    if ( item == nil )
        return [document.collection count];
    else
        return 0;
}

// ------------------------------------------------------------
// Outline View - Child Of Item:
// ------------------------------------------------------------
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    Document*    document = [self document];

    if ( item == nil )
        return [document.collection objectAtIndex:index];
    else
        return nil;
}

// ------------------------------------------------------------
// Outline View - Is Item Expandable:
// ------------------------------------------------------------
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ( item == nil )
        return YES;
    else
        return NO;
}

// ------------------------------------------------------------
// Outline View - Object Value for Table Column:
// ------------------------------------------------------------
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    if ( item == nil )
        return nil;
    else {
        NSString *columnKey = [tableColumn identifier];
        
        if ( columnKey != nil )
            return 	[item valueForKey:columnKey];
        else
            return nil;
    }
}
// ------------------------------------------------------------
// Outline View - Set Object Value for Table Column:
// ------------------------------------------------------------
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{

}

// ------------------------------------------------------------
// Outline View - Selection Indexes For Proposed Selection:
// ------------------------------------------------------------
- (NSIndexSet *)outlineView:(NSOutlineView *)theOutlineView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    NSMutableIndexSet   *theNewSelectionIndexes = [[NSMutableIndexSet alloc] initWithIndexSet:proposedSelectionIndexes];

    return theNewSelectionIndexes;
}

// ------------------------------------------------------------
// If the table view selection changes, then update the values
// in the user interface controls that display details about
// the selected object:
// ------------------------------------------------------------
- (void)outlineViewSelectionDidChange:(NSNotification *)aNotification
{
	[self updateSelectionDetailFields];
}

@end
