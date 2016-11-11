//
//  IVCollectionViewFlowLayout.m
//  Image Viewer
//
//  Created by Alexander on 11/12/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "IVCollectionViewFlowLayout.h"

@implementation IVCollectionViewFlowLayout


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
  CGRect oldBounds = self.collectionView.bounds;
  if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
    return YES;
  }
  return YES;
}

- (nullable NSCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [super layoutAttributesForItemAtIndexPath:indexPath];
}

- (NSArray<__kindof NSCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(NSRect)rect {
  NSArray *arr = [super layoutAttributesForElementsInRect:rect];
  
  for (NSCollectionViewLayoutAttributes *attr in arr) {
    NSRect rect = attr.frame;
    rect.size.height = self.collectionView.frame.size.height;
    rect.origin.y = 0.0f;
    [attr setFrame:rect];
  }
  return arr;
}
@end
