//
//  AppDelegate.m
//  Eye Roll
//
//  Created by Marco Stagni on 20/07/14.
//  Copyright (c) 2014 Marco Stagni. All rights reserved.
//

#import "AppDelegate.h"
#import <Carbon/Carbon.h>

#import "EyeTracker.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    isActive = false;
}

- (void) awakeFromNib
{
    [menu setAutoenablesItems:YES];
    app = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [app setMenu:menu];
    [app setImage:[NSImage imageNamed:@"eye"]];
    [app setHighlightMode:true];
    [menu setDelegate:self];

    //setting up info button
    activate = [[NSMenuItem alloc] initWithTitle:@"Start" action:@selector(toggle:) keyEquivalent:@"a"];
    [activate setTarget:self];
    
    //setting up info button
    info = [[NSMenuItem alloc] initWithTitle:@"About Eye Roll" action:@selector(openInfo:) keyEquivalent:@"i"];
    [info setTarget:self];
    
    //setting up pref button
    pref = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:@selector(openPreferences:) keyEquivalent:@"p"];
    [pref setTarget:self];
    
    //setting quit button
    quit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quitApp:) keyEquivalent:@"q"];
    [quit setTarget:self];
    
    //adding elements to menu
    [menu insertItem:activate atIndex:0];
    [menu insertItem:info atIndex:2];
    [menu insertItem:pref atIndex:3];
    [menu insertItem:quit atIndex:5];
    
    NSLog(@"App started.");
}

- (void) openPreferences:(id) sender {
    NSLog(@"Opening preferences");
    NSWindowController *window = [[NSWindowController alloc] initWithWindowNibName:@"preferences"];
    [window showWindow:nil];
}

- (void) openInfo:(id) sender {
    NSLog(@"Opening info");
    NSWindowController *window = [[NSWindowController alloc] initWithWindowNibName:@"info"];
    [window showWindow:nil];
}

- (void) quitApp:(id) sender {
    NSLog(@"Quitting app");
    [[NSApplication sharedApplication] terminate:nil];
}

- (void) toggle:(id) sender {
    if (isActive) {
        /*
         se l'app era già attiva, cambio il label di active in "Start"
         cambio l'icona in "eye"
         gestisco il termine del tracking
         cambio il valore di isActive
         */
        isActive = false;
        [activate setTitle:@"Start"];
        [app setImage:[NSImage imageNamed:@"eye"]];
        //handle stop eye tracking
        [timer invalidate];
        timer = nil;
        
        stopTracking();
    } else {
        /*
         se l'app non era attiva, cambio il label di Active in "Stop"
         cambio l'icona con eye active
         faccio partire l'eye tracking
         cambio il valore di isActive
         */
        isActive = true;
        [activate setTitle:@"Stop"];
        [app setImage:[NSImage imageNamed:@"eye_active"]];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                target:self
                selector:@selector(simulateScroll:)
                userInfo:nil
                repeats:YES];
        startTracking();
    }
}

/*
- (void) getRunningApplication {
    //provo a listare le applicazioni aperte
    NSWorkspace *ws = [[NSWorkspace alloc] init];
    NSRunningApplication *runningapp = [ws frontmostApplication];
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    for (NSMutableDictionary* entry in (__bridge NSArray*)windowList)
    {
        NSString* ownerName = [entry objectForKey:(id)kCGWindowOwnerName];
        NSInteger ownerPID = [[entry objectForKey:(id)kCGWindowOwnerPID] integerValue];
        NSLog(@"%@:%d", ownerName, ownerPID);
    }
    CFRelease(windowList);
}
*/

- (void)sendData:(NSInteger) x :(NSInteger) y {
    NSLog(@"received %ld - %ld",(long)x,(long)y);
}

- (void) hello {
    [self hello];
}

void method (void* self, int x, int y)
{
    [(__bridge id) self innerMethod:x:y];
}

- (void) innerMethod:(int)x :(int)y {
	printf("Hello world \n");
}

- (void)simulateScroll:(NSTimer *)timer
{
    CGWheelCount wheelCount = 1; // 1 for Y-only, 2 for Y-X, 3 for Y-X-Z
    int32_t xScroll = 0;// Negative for right
    int32_t yScroll = -1; // Negative for down
    CGEventRef cgEvent = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitPixel, wheelCount, yScroll, xScroll);
    
    // You can post the CGEvent to the event stream to have it automatically sent to the window under the cursor
    CGEventPost(kCGHIDEventTap, cgEvent);
    
    CFRelease(cgEvent);
}

/************************************************************
    DELEGATE METHODS
 ************************************************************/

- (void)menuWillOpen:(NSMenu *)menu {

}


@end

