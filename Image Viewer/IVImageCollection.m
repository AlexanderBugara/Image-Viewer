
#import "IVImageCollection.h"
#import "IVImageFile.h"

NSString *imageFilesKey = @"imageFiles";

@implementation IVImageCollection

- (id)initWithRootURL {
    
    self = [super init];
    if (self) {
        imageFiles = [[NSMutableArray alloc] init];
        imageFilesByURL = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Property Accessors
@synthesize imageFiles;

#pragma mark Querying the List of ImageFiles

- (IVImageFile *)imageFileForURL:(NSURL *)imageFileURL {
    return imageFilesByURL[imageFileURL];
}


#pragma mark Modifying the List of ImageFiles

- (void)addImageFile:(IVImageFile *)imageFile {
    [self insertImageFile:imageFile atIndex:imageFiles.count];
}

- (void)insertImageFile:(IVImageFile *)imageFile atIndex:(NSUInteger)index {
    // Insert the imageFile into our "imageFiles" array (in a KVO-compliant way).
    [[self mutableArrayValueForKey:imageFilesKey] insertObject:imageFile atIndex:index];

    // Add the imageFile into our "imageFilesByURL" dictionary.
    [imageFilesByURL setObject:imageFile forKey:imageFile.url];
}

- (void)removeImageFile:(IVImageFile *)imageFile {
    // Remove the imageFile from our "imageFiles" array (in a KVO-compliant way).
    [[self mutableArrayValueForKey:imageFilesKey] removeObject:imageFile];

    // Remove the imageFile from our "imageFilesByURL" dictionary.
    [imageFilesByURL removeObjectForKey:imageFile.url];
}

- (void)removeImageFileAtIndex:(NSUInteger)index {
    IVImageFile *imageFile = [imageFiles objectAtIndex:index];
    [self removeImageFile:imageFile];
}

@end
