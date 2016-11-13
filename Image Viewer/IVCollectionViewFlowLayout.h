//
//  IVCollectionViewFlowLayout.h
//  Image Viewer
//
//  Created by Alexander on 11/12/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define X_PADDING        10.0
#define Y_PADDING        10.0

@class IVCollectionViewFlowLayout;

@protocol IVLayoutDataSource <NSObject>
@required
- (NSSize)collctionViewFlowLayoutContentSize:(IVCollectionViewFlowLayout *)flowLayout;
- (NSSize)collctionViewFlowLayoutItemFrame:(IVCollectionViewFlowLayout *)flowLayout
                                 indexPath:(NSIndexPath *)indexPath;
@end

@interface IVCollectionViewFlowLayout : NSCollectionViewFlowLayout {
  NSPoint loopCenter;
  NSSize loopSize;
  NSSize itemSize;
  NSRect box;
}
@property (nonatomic, weak) id <IVLayoutDataSource> dataSource;
@end
