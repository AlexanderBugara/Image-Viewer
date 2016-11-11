//
//  AppDelegate.m
//  Image Viewer
//
//  Created by Alexander on 11/11/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "AppDelegate.h"
#import "AAPLBrowserWindowController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
  [self openBrowserWindowForFolderURL:[NSURL fileURLWithPath:@"/Library/Desktop Pictures"]];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

- (void)openBrowserWindowForFolderURL:(NSURL *)folderURL {
  AAPLBrowserWindowController *browserWindowController = [[AAPLBrowserWindowController alloc] initWithRootURL:folderURL];
  if (browserWindowController) {
    [browserWindowController showWindow:self];
    
    /*
     Add browserWindowController to browserWindowControllers, to keep it
     alive.
     */
    if (browserWindowControllers == nil) {
      browserWindowControllers = [[NSMutableSet alloc] init];
    }
    [browserWindowControllers addObject:browserWindowController];
    
    /*
     Watch for the window to be closed, so we can let it and its
     controller go.
     */
    NSWindow *browserWindow = [browserWindowController window];
    if (browserWindow) {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browserWindowWillClose:) name:NSWindowWillCloseNotification object:browserWindow];
    }
  }
}
@end
