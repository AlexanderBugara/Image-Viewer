
#import "IVSlide.h"
#import "IVImageFile.h"
#import <QuartzCore/QuartzCore.h>

@implementation IVSlide

#pragma mark Represented Object

- (IVImageFile *)imageFile {
    return (IVImageFile *)(self.representedObject);
}

- (void)setRepresentedObject:(id)newRepresentedObject {
    [super setRepresentedObject:newRepresentedObject];
    [self.imageFile requestPreviewImage];
}

- (void)viewDidLoad {
  self.view.wantsLayer = YES;
  self.view.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
}

@end
