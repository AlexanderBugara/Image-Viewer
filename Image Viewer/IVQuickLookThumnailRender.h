//
//  IVQuickLookThumnailRender.h
//  Image Viewer
//
//  Created by Alexander on 11/14/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IVQuickLookThumnailRender : NSObject
- (void)imageWithPreviewOfFileAtPath:(NSString *)path
                              ofSize:(NSSize)size
                          complition:(void(^)(NSImage *image)) complitionHandler;
@end
