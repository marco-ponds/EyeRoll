//
//  AppDelegate.h
//  Eye Roll
//
//  Created by Marco Stagni on 20/07/14.
//  Copyright (c) 2014 Marco Stagni. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppDelegate : NSObject <NSApplicationDelegate,NSMenuDelegate>
        
    -(void) innerMethod:(int)x : (int) y;
    void method(void* self, int x, int y);

@end

IBOutlet NSMenu *menu;
NSStatusItem *app;
NSMenuItem *activate, *info, *pref, *quit;

NSTimer *timer;
BOOL isActive;
