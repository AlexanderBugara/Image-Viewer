
#import <Cocoa/Cocoa.h>

@class IVImageFile;

@interface IVImageCollection : NSObject {
    NSMutableArray *imageFiles;
    NSMutableDictionary *imageFilesByURL;
}

@property(readonly) NSArray *imageFiles;

- (IVImageFile *)imageFileForURL:(NSURL *)imageFileURL;

- (void)addImageFile:(IVImageFile *)imageFile;
- (void)insertImageFile:(IVImageFile *)imageFile atIndex:(NSUInteger)index;
- (void)removeImageFile:(IVImageFile *)imageFile;
- (void)removeImageFileAtIndex:(NSUInteger)index;
@end

extern NSString *imageFilesKey;
