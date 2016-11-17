#import <Foundation/Foundation.h>

@class IVQuickLookThumnailRender;

@interface IVImageFile : NSObject

- (id)initWithURL:(NSURL *)newURL;
@property(copy) NSURL *url;

@property(readonly) NSInteger pixelsWide;
@property(readonly) NSInteger pixelsHigh;

@property(strong) NSImage *previewImage;
@property (nonatomic, weak) IVQuickLookThumnailRender *render;

- (CGSize)proportionalSizeForHeight:(CGFloat)height;

#pragma mark Loading
- (void)requestPreviewImageComplitionHandler:(void(^)(void))complitionHandler;
@end
