//
//  AppDelegate.h
//  Chip-8 Emulator
//
//  Created by Dominik Horn on 02.09.12.
//  Copyright (c) 2012 Dominik Horn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* This is our Controller */
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSView* gameView;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView* gameView;

@end
