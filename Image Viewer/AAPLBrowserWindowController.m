/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This is the browser window controller implementation.
*/

#import "AAPLBrowserWindowController.h"
#import "AAPLImageCollection.h"

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
    
    // Create an AAPLImageCollection for browsing our assigned folder.
    imageCollection = [[AAPLImageCollection alloc] initWithRootURL:rootURL];
    
    /*
     Watch for changes in the imageCollection's imageFiles list.
     Whenever a new AAPLImageFile is added or removed,
     Key-Value Observing (KVO) will send us an
     -observeValueForKeyPath:ofObject:change:context: message, which we
     can respond to as needed to update the set of slides that we
     display.
     */
    //[self startObservingImageCollection];
  }
  
  return self;
}



- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  
  return 50;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
  // Message back to the collectionView, asking it to make a @"Slide" item associated with the given item indexPath.  The collectionView will first check whether an NSNib or item Class has been registered with that name (via -registerNib:forItemWithIdentifier: or -registerClass:forItemWithIdentifier:).  Failing that, the collectionView will search for a .nib file named "Slide".  Since our .nib file is named "Slide.nib", no registration is necessary.
  NSCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"Slide" forIndexPath:indexPath];
 // AAPLImageFile *imageFile = [self imageFileAtIndexPath:indexPath];
 // item.representedObject = imageFile;
  
  return item;
}
/*
- (AAPLImageFile *)imageFileAtIndexPath:(NSIndexPath *)indexPath {
  if (groupByTag) {
    NSArray<AAPLTag *> *tags = imageCollection.tags;
    NSInteger sectionIndex = indexPath.section;
    if (sectionIndex < tags.count) {
      return tags[sectionIndex].imageFiles[indexPath.item];
    } else {
      return imageCollection.untaggedImageFiles[indexPath.item];
    }
  } else {
    return imageCollection.imageFiles[indexPath.item];
  }
}*/





@end
