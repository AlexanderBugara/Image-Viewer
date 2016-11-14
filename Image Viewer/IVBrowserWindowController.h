
#import <Cocoa/Cocoa.h>

@class IVImageCollection;

@interface IVBrowserWindowController : NSWindowController <NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout> {
    IVImageCollection *imageCollection;
    NSSet <NSIndexPath *> *indexPathsOfItemsBeingDragged;
}

@property(weak) IBOutlet NSCollectionView *imageCollectionView;
- (id)initWithNib;
@end
