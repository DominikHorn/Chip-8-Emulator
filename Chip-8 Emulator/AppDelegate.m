//
//  AppDelegate.m
//  Chip-8 Emulator
//
//  Created by Dominik Horn on 02.09.12.
//  Copyright (c) 2012 Dominik Horn. All rights reserved.
//

#import "AppDelegate.h"
#import "Core.h"

@implementation AppDelegate
@synthesize gameView;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[Core instance] enterEmu]; /* Start our Emulator */
   // [[NSApplication sharedApplication] terminate:self];
}

@end
