//
//  GFX.m
//  Chip-8 Emulator
//
//  Created by Dominik Horn on 02.09.12.
//  Copyright (c) 2012 Dominik Horn. All rights reserved.
//

#import "GFX.h"
#import "AppDelegate.h"

@implementation GFX

+ (GFX*)instance  {
    static GFX* gfx;
    if (!gfx) {
        gfx = [[GFX alloc] init];
    }
    return gfx;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)draw {
    [[NSApplication sharedApplication].delegate(AppDelegate*)]
}

@end
