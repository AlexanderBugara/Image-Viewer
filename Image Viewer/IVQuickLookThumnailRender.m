//
//  IVQuickLookThumnailRender.m
//  Image Viewer
//
//  Created by Alexander on 11/14/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "IVQuickLookThumnailRender.h"
#import <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>

@implementation IVQuickLookThumnailRender

- (void)imageWithPreviewOfFileAtPath:(NSString *)path
                              ofSize:(NSSize)size
                          complition:(void(^)(NSImage *image)) complitionHandler
{
  NSURL *fileURL = [NSURL fileURLWithPath:path];
  if (!path || !fileURL) {
    return;
  }
  
  QLThumbnailRef thumbnail = QLThumbnailCreate(NULL, (__bridge CFURLRef)fileURL, size, NULL);
  __block NSImage *result = nil;
  QLThumbnailDispatchAsync(thumbnail, dispatch_get_main_queue(), ^{
    CGImageRef image = QLThumbnailCopyImage(thumbnail);
    CGRect rect = QLThumbnailGetContentRect(thumbnail);
    if (image) {
      dispatch_async(dispatch_get_main_queue(), ^{
        result = [[NSImage alloc] initWithCGImage:image size:rect.size];
        CGImageRelease(image);
        complitionHandler(result);
      });
    } else {
      NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
      if (icon) {
        [icon setSize:size];
      }
      complitionHandler(result);
    }
    
    CFRelease(thumbnail);
    
  });
}
@end
