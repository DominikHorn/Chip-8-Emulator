//
//  Core.h
//  Chip-8 Emulator
//
//  Created by Dominik Horn on 02.09.12.
//  Copyright (c) 2012 Dominik Horn. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FREQUENCY (1.0/100.0)

@interface Core : NSObject {
    NSTimer* quartz;
    
    float deltatime;
    NSDate* previous;
}

+ (Core*)instance;

- (void)enterEmu;
- (void)cycle;

@property (retain) NSDate* previous;

@end
