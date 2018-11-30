//
//  CPU.h
//  Chip-8 Emulator
//
//  Created by Dominik Horn on 02.09.12.
//  Copyright (c) 2012 Dominik Horn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>

#define MEMSIZE 4096
#define NUMREGS 16
#define DISPLAY_WIDTH 64
#define DISPLAY_HEIGHT 32
#define DISPLAYSIZE DISPLAY_WIDTH*DISPLAY_HEIGHT
#define MAX_STACKSIZE 16
#define NUM_INPUT 16
#define ROM_OFFSET 512
#define MAX_ROM_SIZE MEMSIZE-ROM_OFFSET
#define DEVELOPER true

#define OPCODE_OFFSET 2

@interface CPU : NSObject {
    unsigned char memory[MEMSIZE];             /* Ram, 4 KB in size                 */
    unsigned char V[NUMREGS];                  /* 1 Byte Registers                  */
    unsigned short I, pc;                      /* 2 Byte Register + Program counter */
    unsigned char gfx[DISPLAYSIZE];            /* Graphics Storage                  */
    unsigned char delay_timer, sound_timer;    /* Chip-8 timers                     */
    unsigned short stack[MAX_STACKSIZE];       /* The Stack                         */
    unsigned short sp;                         /* Stack Pointer                     */
    unsigned char key[NUM_INPUT];              /* Input Keys                        */
    unsigned short opcode;                     /* Our current opcode                */
    bool drawFlag;
    
    char* rom;
}

+ (CPU*)instance;
- (void)initialize;
- (void)loadRom;
- (void)draw;

- (void)dumpGFX;
- (void)emulateCycle;
- (unsigned char*)getGFX;
- (void)setKey:(unsigned char)k keyNum:(int)num;

@property bool drawFlag;
@property char* rom;

@end
