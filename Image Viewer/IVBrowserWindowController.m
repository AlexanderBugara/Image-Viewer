#import "IVBrowserWindowController.h"
#import "IVImageCollection.h"
#import "IVImageFile.h"
#import "IVSlide.h"
#import "IVCollectionViewFlowLayout.h"
#import "IVQuickLookThumnailRender.h"

@interface IVBrowserWindowController () <IVLayoutDataSource>

@property (nonatomic, strong) IVQuickLookThumnailRender *render;
@end

@implementation IVBrowserWindowController

- (IVQuickLookThumnailRender *)render {
  if (!_render) {
    _render = [IVQuickLookThumnailRender new];
  }
  return _render;
}

- (id)initWithNib {
  self = [super initWithWindowNibName:@"BrowserWindow"];
  if (self) {
    imageCollection = [[IVImageCollection alloc] init];
  }
  return self;
}



- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [imageCollection.imageFiles count];
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
  
  NSCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"Slide" forIndexPath:indexPath];
  IVImageFile *imageFile = [self imageFileAtIndexPath:indexPath];
  imageFile.render = [self render];
  item.representedObject = imageFile;
  
  return item;
}

- (IVImageFile *)imageFileAtIndexPath:(NSIndexPath *)indexPath {
  return imageCollection.imageFiles[indexPath.item];
}

#pragma mark - NSCollectionViewDelegate Drag-and-Drop Methods

- (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event {
  return YES;
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
  indexPathsOfItemsBeingDragged = [indexPaths copy];
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation {
  indexPathsOfItemsBeingDragged = nil;
}
#pragma mark - destination
- (NSDragOperation)collectionView:(NSCollectionView *)collectionView
                     validateDrop:(id <NSDraggingInfo>)draggingInfo
                proposedIndexPath:(NSIndexPath **)proposedDropIndexPath
                    dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
  
  if (indexPathsOfItemsBeingDragged) {
    return NSDragOperationMove;
  } else {
    return NSDragOperationCopy;
  }
}

- (BOOL)collectionView:(NSCollectionView *)collectionView
            acceptDrop:(id <NSDraggingInfo>)draggingInfo
             indexPath:(NSIndexPath *)indexPath
         dropOperation:(NSCollectionViewDropOperation)dropOperation {
  
  NSMutableArray *droppedObjects = [NSMutableArray array];
  [draggingInfo enumerateDraggingItemsWithOptions:0 forView:collectionView classes:@[[NSURL class]] searchOptions:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSPasteboardURLReadingFileURLsOnlyKey, nil] usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
    
    NSURL *url = draggingItem.item;
    if ([url isKindOfClass:[NSURL class]]) {
      [droppedObjects addObject:url];
    }
  }];
  
  NSInteger insertionIndex = indexPath.item;
  
  for (NSURL *url in droppedObjects) {
    IVImageFile *imageFile = [imageCollection imageFileForURL:url];
    if (imageFile == nil) {
      imageFile = [[IVImageFile alloc] initWithURL:url];
      [imageCollection insertImageFile:imageFile atIndex:insertionIndex];
      [collectionView.animator insertItemsAtIndexPaths:[NSSet<NSIndexPath *> setWithCollectionViewIndexPath:indexPath]];
    }
  }
  
  return YES;
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
  [(IVCollectionViewFlowLayout *)self.imageCollectionView.collectionViewLayout setDataSource:self];
  [self registerForCollectionViewDragAndDrop];
}




#pragma mark - IVLayoutDataSource datasource
- (NSSize)collctionViewFlowLayoutItemFrame:(IVCollectionViewFlowLayout *)flowLayout
                                 indexPath:(NSIndexPath *)indexPath {
  
  IVImageFile *imageFile = [self imageFileAtIndexPath:indexPath];
  return [imageFile proportionalSizeForHeight:self.imageCollectionView.frame.size.height];
  
}

- (NSSize)collctionViewFlowLayoutContentSize:(IVCollectionViewFlowLayout *)flowLayout {
  
  NSSize result;
  result.height = 0.0f;
  result.width = 0.0f;
  
  for (IVImageFile *file in imageCollection.imageFiles) {
    NSSize size = [file proportionalSizeForHeight:self.imageCollectionView.frame.size.height];
    result.width += size.width;
    result.height = size.height;
  }
  
  return result;
}

@end
