//
//  AppDelegate.m
//  Image Viewer
//
//  Created by Alexander on 11/11/16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "AppDelegate.h"
#import "IVBrowserWindowController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  [self openBrowserWindow];
}

- (void)openBrowserWindow {
  
  IVBrowserWindowController *browserWindowController = [[IVBrowserWindowController alloc] initWithNib];
  
  if (browserWindowController) {
    [browserWindowController showWindow:self];
    
    if (browserWindowControllers == nil) {
      browserWindowControllers = [[NSMutableSet alloc] init];
    }
    [browserWindowControllers addObject:browserWindowController];
    
  }
}
@end
