//
//  NSImage+QuickLook.m
//  QuickLookTest
//
//  Created by Matt Gemmell on 29/10/2007.
//

#import "NSImage+QuickLook.h"
#import <QuickLook/QuickLook.h> // Remember to import the QuickLook framework into your project!

@implementation NSImage (QuickLook)


+ (NSImage *)imageWithPreviewOfFileAtPath:(NSString *)path ofSize:(NSSize)size asIcon:(BOOL)icon complition:(void(^)(NSImage *image)) complitionHandler
{
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    if (!path || !fileURL) {
        return nil;
    }
  
  NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                   forKey:(NSString *)kQLThumbnailOptionIconModeKey];
  QLThumbnailRef thumbnail = QLThumbnailCreate(NULL, (__bridge CFURLRef)fileURL, size, NULL);//(__bridge CFDictionaryRef)dict);
  
  __block NSImage *result = nil;
  
  QLThumbnailDispatchAsync(thumbnail, dispatch_get_main_queue(), ^{
    CGImageRef image = QLThumbnailCopyImage(thumbnail);
    if (image) {
      dispatch_async(dispatch_get_main_queue(), ^{
        result = [[NSImage alloc] initWithCGImage:image size:size];
        complitionHandler(result);
        CGImageRelease(image);
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
  
  
    /*
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                     forKey:(NSString *)kQLThumbnailOptionIconModeKey];
    CGImageRef ref = QLThumbnailImageCreate(NULL, 
                                            (__bridge CFURLRef)fileURL, 
                                            CGSizeMake(size.width, size.height),
                                            (__bridge CFDictionaryRef)dict);
  NSLog(@"%@",ref);
    if (ref != NULL) {
        // Take advantage of NSBitmapImageRep's -initWithCGImage: initializer, new in Leopard,
        // which is a lot more efficient than copying pixel data into a brand new NSImage.
        // Thanks to Troy Stephens @ Apple for pointing this new method out to me.
        NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:ref];
        NSImage *newImage = nil;
        if (bitmapImageRep) {
            newImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
            [newImage addRepresentation:bitmapImageRep];
           // [bitmapImageRep release];
            
            /*if (newImage) {
                return [newImage autorelease];
            }*/
  /*      }
        CFRelease(ref);
    } else {
        // If we couldn't get a Quick Look preview, fall back on the file's Finder icon.
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
        if (icon) {
            [icon setSize:size];
        }
        return icon;
    }
    */
    return nil;
}


@end