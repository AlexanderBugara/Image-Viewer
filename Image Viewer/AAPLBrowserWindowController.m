/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This is the browser window controller implementation.
*/

#import "AAPLBrowserWindowController.h"
#import "AAPLImageCollection.h"
#import "AAPLImageFile.h"

#define HEADER_VIEW_HEIGHT  39
#define FOOTER_VIEW_HEIGHT  28

static NSString *selectionIndexPathsKey = @"selectionIndexPaths";
static NSString *tagsKey = @"tags";

static NSString *StringFromCollectionViewDropOperation(NSCollectionViewDropOperation dropOperation);
static NSString *StringFromCollectionViewIndexPath(NSIndexPath *indexPath);

@interface AAPLBrowserWindowController (Internals)

- (void)showStatus:(NSString *)statusMessage;

- (void)startObservingImageCollection;
- (void)stopObservingImageCollection;

- (void)handleImageFilesInsertedAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths;
- (void)handleImageFilesRemovedAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths;

- (void)handleTagsInsertedInCollectionAtIndexes:(NSIndexSet *)indexes;
- (void)handleTagsRemovedFromCollectionAtIndexes:(NSIndexSet *)indexes;

@end

@implementation AAPLBrowserWindowController

- (id)initWithRootURL:(NSURL *)newRootURL {
  self = [super initWithWindowNibName:@"BrowserWindow"];
  if (self) {
    rootURL = [newRootURL copy];
    groupByTag = NO;
    layoutKind = SlideLayoutKindWrapped;
    
    imageCollection = [[AAPLImageCollection alloc] init];
    [self startObservingImageCollection];
  }
  
  return self;
}

- (void)startObservingImageCollection {
  [imageCollection addObserver:self forKeyPath:imageFilesKey options:0 context:NULL];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [imageCollection.imageFiles count];
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
  NSCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"Slide" forIndexPath:indexPath];
  AAPLImageFile *imageFile = [self imageFileAtIndexPath:indexPath];
  item.representedObject = imageFile;
  
  return item;
}

- (AAPLImageFile *)imageFileAtIndexPath:(NSIndexPath *)indexPath {
  
  return imageCollection.imageFiles[indexPath.item];
  
}

#pragma mark NSCollectionViewDelegate Drag-and-Drop Methods


/*******************/
/* Dragging Source */
/*******************/

- (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event {
  return YES;
}

- (id <NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath {
   return nil;
 /*AAPLImageFile *imageFile = [self imageFileAtIndexPath:indexPath];
 return imageFile.url.absoluteURL;*/
  // An NSURL can be a pasteboard writer, but must be returned as an absolute URL.
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
  
  indexPathsOfItemsBeingDragged = [indexPaths copy];
  
  // Indicate dragging state in our status TextField.
  [self showStatus:[NSString stringWithFormat:@"Dragging %lu items", (unsigned long)(indexPaths.count)]];
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation {
  
  // Clear the dragging indexPaths we saved earlier.
  indexPathsOfItemsBeingDragged = nil;
  
  // Indicate dragging state in our status TextField.
  [self showStatus:@"Dragging ended"];
}


/************************/
/* Dragging Destination */
/************************/

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id <NSDraggingInfo>)draggingInfo proposedIndexPath:(NSIndexPath **)proposedDropIndexPath dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
  
  NSString *proposedActionDescription = [NSString stringWithFormat:@"Validate drop %@ item at indexPath=%@", StringFromCollectionViewDropOperation(*proposedDropOperation), StringFromCollectionViewIndexPath(*proposedDropIndexPath)];
  if (*proposedDropOperation == NSCollectionViewDropOn) {
    *proposedDropOperation = NSCollectionViewDropBefore;
    proposedActionDescription = [proposedActionDescription stringByAppendingFormat:@" -- changed to drop before %@", StringFromCollectionViewIndexPath(*proposedDropIndexPath)];
  }
  
  [self showStatus:proposedActionDescription];
  
  
  if (indexPathsOfItemsBeingDragged) {
    return groupByTag ? NSDragOperationNone : NSDragOperationMove;
  } else {
    return NSDragOperationCopy;
  }
}

- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id <NSDraggingInfo>)draggingInfo indexPath:(NSIndexPath *)indexPath dropOperation:(NSCollectionViewDropOperation)dropOperation {
  
  BOOL result = NO;
  NSString *proposedActionDescription = [NSString stringWithFormat:@"Accept drop of %lu items from %@, %@ item at indexPath=%@", (unsigned long)[draggingInfo numberOfValidItemsForDrop], indexPathsOfItemsBeingDragged ? @"self" : @"elsewhere", StringFromCollectionViewDropOperation(dropOperation), StringFromCollectionViewIndexPath(indexPath)];
  
   [self suspendAutoUpdateResponse];
  
  if (indexPathsOfItemsBeingDragged) {
    [self movedInsideApplication:draggingInfo collectionView:collectionView indexPath:indexPath result:&result];
  } else {
    [self droppedFromSystem:draggingInfo collectionView:collectionView indexPath:indexPath result:&result];
  }
  
  [self resumeAutoUpdateResponse];
  return result;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  
  if (object == imageCollectionView && [keyPath isEqual:selectionIndexPathsKey]) {
    NSSet<NSIndexPath *> *newSelectedIndexPaths = imageCollectionView.selectionIndexPaths;
    [self showStatus:[NSString stringWithFormat:@"%lu items selected", (unsigned long)(newSelectedIndexPaths.count)]];
    
  } else if (object == imageCollection && !autoUpdateResponseSuspended) {
    NSKeyValueChange kind = [change[NSKeyValueChangeKindKey] integerValue];
    if (kind == NSKeyValueChangeInsertion || kind == NSKeyValueChangeRemoval) {
      
      NSIndexSet *indexes = change[@"indexes"];
      NSMutableSet<NSIndexPath *> *indexPaths = [NSMutableSet<NSIndexPath *> setWithCollectionViewIndexPaths:[NSArray array]];
      if ([keyPath isEqual:imageFilesKey]) {
        if (object == imageCollection) {
          
          [indexes enumerateIndexesUsingBlock:^(NSUInteger itemIndex, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
          }];
          
        } /*else if ([object isKindOfClass:[AAPLTag class]]) {
          
          NSUInteger sectionIndex = [imageCollection.tags indexOfObject:object];
          if (sectionIndex != NSNotFound) {
            [indexes enumerateIndexesUsingBlock:^(NSUInteger itemIndex, BOOL *stop) {
              [indexPaths addObject:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
            }];
          }
          
        }*/
        
        if (kind == NSKeyValueChangeInsertion) {
          [self handleImageFilesInsertedAtIndexPaths:indexPaths];
        } else {
          [self handleImageFilesRemovedAtIndexPaths:indexPaths];
        }
        
      } else if ([keyPath isEqual:tagsKey]) {
        if (kind == NSKeyValueChangeInsertion) {
          [self handleTagsInsertedInCollectionAtIndexes:indexes];
        } else {
          [self handleTagsRemovedFromCollectionAtIndexes:indexes];
        }
      }
      
    } else {
      [self.imageCollectionView reloadData];
    }
  }
}

- (void)suspendAutoUpdateResponse {
  autoUpdateResponseSuspended = YES;
}

- (void)resumeAutoUpdateResponse {
  autoUpdateResponseSuspended = NO;
}

- (void)movedInsideApplication:(id <NSDraggingInfo>)draggingInfo
                collectionView:(NSCollectionView *)collectionView
                     indexPath:(NSIndexPath *)indexPath
                        result:(BOOL *)result {
  
  __block NSInteger toItemIndex = indexPath.item;
  [indexPathsOfItemsBeingDragged enumerateIndexPathsWithOptions:0 usingBlock:^(NSIndexPath *fromIndexPath, BOOL *stop) {
    NSInteger fromItemIndex = fromIndexPath.item;
    if (fromItemIndex > toItemIndex) {
      
      [imageCollection moveImageFileFromIndex:fromItemIndex toIndex:toItemIndex];
      
      [[imageCollectionView animator] moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromItemIndex inSection:[indexPath section]] toIndexPath:[NSIndexPath indexPathForItem:toItemIndex inSection:[indexPath section]]];
      
      ++toItemIndex;
    }
  }];
  
  __block NSInteger adjustedToItemIndex = indexPath.item - 1;
  [indexPathsOfItemsBeingDragged enumerateIndexPathsWithOptions:NSEnumerationReverse  usingBlock:^(NSIndexPath *fromIndexPath, BOOL *stop) {
    NSInteger fromItemIndex = [fromIndexPath item];
    if (fromItemIndex < adjustedToItemIndex) {
      
      [imageCollection moveImageFileFromIndex:fromItemIndex toIndex:adjustedToItemIndex];
      
      NSIndexPath *adjustedToIndexPath = [NSIndexPath indexPathForItem:adjustedToItemIndex inSection:[indexPath section]];
      [imageCollectionView.animator moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromItemIndex inSection:indexPath.section] toIndexPath:adjustedToIndexPath];
      
      --adjustedToItemIndex;
    }
  }];
  *result = YES;
}


- (void)droppedFromSystem:(id <NSDraggingInfo>)draggingInfo
           collectionView:(NSCollectionView *)collectionView
                indexPath:(NSIndexPath *)indexPath
                   result:(BOOL *)result {
  
  NSMutableArray *droppedObjects = [NSMutableArray array];
  [draggingInfo enumerateDraggingItemsWithOptions:0 forView:collectionView classes:@[[NSURL class]] searchOptions:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSPasteboardURLReadingFileURLsOnlyKey, nil] usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
    
    NSURL *url = draggingItem.item;
    if ([url isKindOfClass:[NSURL class]]) {
      [droppedObjects addObject:url];
    }
  }];
  
  NSInteger insertionIndex = indexPath.item;
  
  for (NSURL *url in droppedObjects) {
    AAPLImageFile *imageFile = [imageCollection imageFileForURL:url];
    if (imageFile == nil) {
        imageFile = [[AAPLImageFile alloc] initWithURL:url];
        [imageCollection insertImageFile:imageFile atIndex:insertionIndex];
        [collectionView.animator insertItemsAtIndexPaths:[NSSet<NSIndexPath *> setWithCollectionViewIndexPath:indexPath]];
    }
  }
  *result = YES;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
  
  NSCollectionViewItem *item = [collectionView itemAtIndexPath:indexPaths.anyObject];
  if (item) {
    [item setSelected:YES];
  }
}

- (void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(nonnull NSSet<NSIndexPath *> *)indexPaths {
  NSCollectionViewItem *item = [collectionView itemAtIndexPath:indexPaths.anyObject];
  if (item) {
    [item setSelected:NO];
  }
}

- (void)showStatus:(NSString *)statusMessage {
  statusTextField.stringValue = statusMessage;
}

- (void)registerForCollectionViewDragAndDrop {
  // Register for the dropped object types we can accept.
  [self.imageCollectionView registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
  
  // Enable dragging items from our CollectionView to other applications.
  [self.imageCollectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
  
  // Enable dragging items within and into our CollectionView.
  [self.imageCollectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
}

- (void)windowDidLoad {
  
  // Set the window's title to the name of the folder we're browsing.
/*  self.window.title = rootURL.lastPathComponent;
  
  // Set imageCollectionView.collectionViewLayout to match our desired layoutKind.
  [self updateLayout];
  
  // Give the CollectionView a backgroundView.  The CollectionView will insert this view behind its enclosing NSClipView, and automatically size it to always match the NSClipView's frame, producing a background that remains stationary as the content scrolls.
  NSView *backgroundView = [[AAPLSlideTableBackgroundView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
  self.imageCollectionView.backgroundView = backgroundView;
  
  // Watch for changes to the CollectionView's selection, just so we can update our status display.
  [imageCollectionView addObserver:self forKeyPath:selectionIndexPathsKey options:0 context:NULL];
  
  // Start scanning our assigned folder for image files.
  [imageCollection startOrRestartFileTreeScan];*/
  
  // Configure our CollectionView for drag-and-drop.
  [self registerForCollectionViewDragAndDrop];
}

- (NSSize)collectionView:(NSCollectionView *)collectionView
                  layout:(NSCollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  NSSize size;
  size.width = 50;
  size.height = collectionView.frame.size.height;
  return size;
}


@end

static NSString *StringFromCollectionViewDropOperation(NSCollectionViewDropOperation dropOperation) {
  switch (dropOperation) {
    case NSCollectionViewDropBefore:
      return @"before";
      
    case NSCollectionViewDropOn:
      return @"on";
      
    default:
      return @"?";
  }
}

static NSString *StringFromCollectionViewIndexPath(NSIndexPath *indexPath) {
  if (indexPath && indexPath.length == 2) {
    return [NSString stringWithFormat:@"(%ld,%ld)", (long)(indexPath.section), (long)(indexPath.item)];
  } else {
    return @"(nil)";
  }
}
