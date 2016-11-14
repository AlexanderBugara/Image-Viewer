#import <Cocoa/Cocoa.h>
#import "IVImageFile.h"
#import "IVQuickLookThumnailRender.h"

@interface IVImageFile (Internals)
@property(strong) NSImage *previewImage;
@end

@implementation IVImageFile
@synthesize url;

- (id)initWithURL:(NSURL *)newURL {
    self = [super init];
    if (self) {
        self.url = newURL;
    }
    return self;
}

#pragma mark Image Properties

- (NSInteger)pixelsWide {
  return 200;
}

- (NSInteger)pixelsHigh {
  return 200;
}

- (CGSize)proportionalSizeForHeight:(CGFloat)height {
  NSInteger imageWidth = [self pixelsWide];
  NSInteger imageHeight = [self pixelsHigh];
  
  CGFloat ratio = height/imageHeight;
  NSInteger slideWidth = (NSInteger)(imageWidth * ratio);
  
  NSSize size;
  size.height = height;
  size.width = slideWidth;
  return size;
}

@synthesize previewImage;

- (void)requestPreviewImage {
    if (self.previewImage == nil) {
      
      __weak __typeof (self) weakSelf = self;
      
      [self.render imageWithPreviewOfFileAtPath:[self.url path]
                                         ofSize:NSSizeFromCGSize(CGSizeMake(190, 190))
                                     complition:^(NSImage *image) {
                                       weakSelf.previewImage = image;
                                     }];
    }
}
@end
