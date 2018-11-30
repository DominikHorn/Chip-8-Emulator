//
//  Core.m
//  Chip-8 Emulator
//
//  Created by Dominik Horn on 02.09.12.
//  Copyright (c) 2012 Dominik Horn. All rights reserved.
//

#import "Core.h"
#import "CPU.h"
#import "AppDelegate.h"

@implementation Core
@synthesize previous;

+ (Core*)instance {
    static Core* core;
    if (!core) {
        core = [[Core alloc] init];
    }
    return core;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[CPU instance] loadRom];
        self.previous = [NSDate date];
    }
    return self;
}

- (void)dealloc
{
    self.previous = nil;
    [super dealloc];
}

- (void)enterEmu {
    //Load Game
    quartz = [NSTimer scheduledTimerWithTimeInterval:FREQUENCY
                                              target:self
                                            selector:@selector(cycle)
                                            userInfo:nil
                                             repeats:YES];
    
}

- (void)cycle {
//    deltatime = [[NSDate date] timeIntervalSinceDate:self.previous];
//    self.previous = [NSDate date];
//    printf("OC_PS: %f\n", 1.0/deltatime);
    [[CPU instance] emulateCycle];
    if ([CPU instance].drawFlag) {
//        [CPU instance].dumpGFX;
        AppDelegate* app = (AppDelegate*)[NSApplication sharedApplication].delegate;
        [app.gameView drawRect:CGRectMake(0, 0, 0, 0)];
        [CPU instance].drawFlag = false;
    }
    
}

@end
