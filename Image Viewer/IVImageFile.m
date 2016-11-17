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
  return self.previewImage.size.width;
}

- (NSInteger)pixelsHigh {
  return self.previewImage.size.height;
}

- (CGSize)proportionalSizeForHeight:(CGFloat)height {
  NSInteger imageWidth = [self pixelsWide];
  NSInteger imageHeight = [self pixelsHigh];
  
  if (imageWidth == 0 || imageHeight == 0) return CGSizeZero;
  
  CGFloat ratio = height/imageHeight;
  NSInteger slideWidth = (NSInteger)(imageWidth * ratio);
  
  NSSize size;
  size.height = height;
  size.width = slideWidth;
  return size;
}

@synthesize previewImage;

- (void)requestPreviewImageComplitionHandler:(void(^)(void))complitionHandler {
    if (self.previewImage == nil) {
      
      __weak __typeof (self) weakSelf = self;
      
      [self.render imageWithPreviewOfFileAtPath:[self.url path]
                                         ofSize:NSSizeFromCGSize(CGSizeMake(190, 190))
                                     complition:^(NSImage *image) {
                                       weakSelf.previewImage = image;
                                       complitionHandler();
                                     }];
    }
}
@end
