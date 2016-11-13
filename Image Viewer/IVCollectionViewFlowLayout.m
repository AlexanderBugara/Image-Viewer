//
//  IVCollectionViewFlowLayout.m
//  Image Viewer
//
//  Created by Alexander on 11/12/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "IVCollectionViewFlowLayout.h"
#import "AAPLSlide.h"
#import "AAPLImageFile.h"

@interface IVCollectionViewFlowLayout ()
@property (assign) NSSize contentSize;
@property (assign) CGFloat lastLayoutCellXBorder;;
@end

@implementation IVCollectionViewFlowLayout


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
  CGRect oldBounds = self.collectionView.bounds;
  if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
    return YES;
  }
  return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(NSRect)rect {
  NSInteger itemCount = [[self collectionView] numberOfItemsInSection:0];
  NSMutableArray *layoutAttributesArray = [NSMutableArray arrayWithCapacity:itemCount];
  for (NSInteger index = 0; index < itemCount; index++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    NSCollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    if (layoutAttributes) {
      [layoutAttributesArray addObject:layoutAttributes];
    }
  }
  self.lastLayoutCellXBorder = 0.0f;
  return layoutAttributesArray;
}


- (NSCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  NSInteger count = [[self collectionView] numberOfItemsInSection:0];
  if (count == 0) {
    return nil;
  }
  
  NSSize size = [self.dataSource collctionViewFlowLayoutItemFrame:self indexPath:indexPath];
  NSRect itemFrame = CGRectMake(self.lastLayoutCellXBorder, 0.0f, size.width, size.height);
  self.lastLayoutCellXBorder += size.width;
  
  NSCollectionViewLayoutAttributes *attributes = [[[self class] layoutAttributesClass] layoutAttributesForItemWithIndexPath:indexPath];
  [attributes setFrame:NSRectToCGRect(itemFrame)];
  [attributes setZIndex:[indexPath item]];
  return attributes;
}

- (NSSize)collectionViewContentSize {
  return [self.dataSource collctionViewFlowLayoutContentSize:self];
}
@end
