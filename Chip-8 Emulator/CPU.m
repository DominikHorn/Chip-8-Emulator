//
//  CPU.m
//  Chip-8 Emulator
//
//  Created by Dominik Horn on 02.09.12.
//  Copyright (c) 2012 Dominik Horn. All rights reserved.
//

#import "CPU.h"
#import <stdlib.h>

unsigned char chip8_fontset[80] =
{
    0xF0, 0x90, 0x90, 0x90, 0xF0, //0
    0x20, 0x60, 0x20, 0x20, 0x70, //1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, //2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, //3
    0x90, 0x90, 0xF0, 0x10, 0x10, //4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, //5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, //6
    0xF0, 0x10, 0x20, 0x40, 0x40, //7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, //8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, //9
    0xF0, 0x90, 0xF0, 0x90, 0x90, //A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, //B
    0xF0, 0x80, 0x80, 0x80, 0xF0, //C
    0xE0, 0x90, 0x90, 0x90, 0xE0, //D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, //E
    0xF0, 0x80, 0xF0, 0x80, 0x80  //F
};

@implementation CPU
@synthesize drawFlag, rom;

+ (CPU*)instance {
    static CPU* cpu;
    if (!cpu) {
        cpu = [[CPU alloc] init];
    }
    return cpu;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    /* Called on start/reset/Game Change */
    for (int i = 0; i < MEMSIZE; i++) {
        memory[i] = 0;  /* Reset Memory */
    }
    for (int i = 0; i < NUMREGS; i++) {
        V[i] = 0;
    }
    for (int i = 0; i < MAX_STACKSIZE; i++) {
        stack[i] = 0;
    }
//    for (int i = 0; i < NUM_INPUT; i++) {
//        key[i] = 0;
//    }
    for(int i = 0; i < 80; ++i)
		memory[i] = chip8_fontset[i];

    I = 0; pc = 0x200, opcode = 0, sp = 0;
    sound_timer = 0, delay_timer = 0;
    
    drawFlag = false;
    
    [self clearDisplay];
}

- (void)printOpcodeFunction {
    switch (opcode & 0xF000) {
        case 0x0000:
            switch (opcode & 0x000F) {
                case 0x0000: /* 0x00E0: Clears the Screen */
                    printf("[0x00E0: Clears the Screen]");
                    break;
                case 0x000E: /* 0x00EE: Returns from a Subroutine */
                    printf("[0x00EE: Returns from a Subroutine]");
                    break;
                default:
                    printf("Unknown Opcode: 0x%x", opcode);
                    break;
            }
            break;
        case 0x1000: /* 0x1NNN: Jumps to Adress NNN */
            printf("[0x1NNN: Jumps to Adress NNN]");
            break;
        case 0x2000: /* 0x2NNN: Calls subroutine at NNN */
            printf("[0x2NNN: Calls subroutine at NNN]");
            break;
        case 0x3000: /* 3XNN: Skips the next instruction if VX equals NN */
            printf("[0x3XNN: Skips the next instruction if VX equals NN]");
            break;
        case 0x4000: /* 4XNN: Skips the next instruction if VX doesn't equal NN */
            printf("[0x4XNN: Skips the next instruction if VX doesn't equal NN]");
            break;
        case 0x5000: /* 5XY0: Skips the next instruction if VX equals VY */
            printf("[0x5XY0: Skips the next instruction if VX equals VY]");
            break;
        case 0x6000: /* 6XNN: sets VX to NN */
            printf("[0x6XNN: sets VX to NN]");
            break;
        case 0x7000: /* 7XNN: adds NN to VX */
            printf("[0x7XNN: adds NN to VX]");
            break;
        case 0x8000:
            switch (opcode & 0x000F) {
                case 0x0000: /* 8XY0: Sets VX to the value of VY */
                    printf("[0x8XY0: Sets VX to the value of VY]");
                    break;
                case 0x0001: /* 8XY1: Sets VX to VX or VY */
                    printf("[0x8XY1: Sets VX to VX or VY]");
                    break;
                case 0x0002: /* 8XY2: Sets VX to VX and VY */
                    printf("[0x8XY2: Sets VX to VX and VY]");
                    break;
                case 0x0003: /* 8XY3: Sets VX to VX xor VY */
                    printf("[0x8XY3: Sets VX to VX xor VY]");
                    break;
                case 0x0004: /* 8XY4: Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't */
                    printf("[0x8XY4: Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't]");
                case 0x0005: /* 8XY5: VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't. */
                    printf("[0x8XY5: VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't]");
                    break;
                case 0x0006: /* 8XY6: Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift. */
                    printf("[0x8XY6: Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift]");
                    break;
                case 0x0007: /* 8XY7: Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't */
                    printf("[0x8XY7: Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't]");
                    break;
                case 0x000E: /* 8XYE: Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift */
                    printf("[0x8XYE: Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift]");
                    break;
                default:
                    printf("Unknown Opcode: 0x%x", opcode);
                    break;
            }
            break;
        case 0x9000: /* 9XY0: Skips the next instruction if VX doesn't equal VY */
            printf("[0x9XY0: Skips the next instruction if VX doesn't equal VY]");
            break;
        case 0xA000: /* 0xANNN: Set's I to the Adress NNN */
            printf("[0xANNN: Set's I to the Adress NNN]");
            break;
        case 0xB000: /* BNNN: Jumps to the address NNN plus V0 */
            printf("[0xBNNN: Jumps to the address NNN plus V0]");
            break;
        case 0xC000: /* CXNN: Sets VX to a random number and NN */
            printf("[0xCXNN: Sets VX to a random number and NN]");
            break;
        case 0xD000: /* Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels. Each row of 8 pixels is read as bit-coded (with the most significant bit of each byte displayed on the left) starting from memory location I; I value doesn't change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn't happen */
            printf("[0xDXYN: Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels. Each row of 8 pixels is read as bit-coded (with the most significant bit of each byte displayed on the left) starting from memory location I; I value doesn't change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn't happen]");
            break;
        case 0xE000:
            switch (opcode & 0x00FF) {
                case 0x009E: /* EX9E: Skips the next instruction if the key stored in VX is pressed */
                    printf("[0xEX9E: Skips the next instruction if the key stored in VX is pressed]");
                    break;
                case 0x00A1: /* EXA1: Skips the next instruction if the key stored in VX isn't pressed */
                    printf("[0xEXA1: Skips the next instruction if the key stored in VX isn't pressed]");
                    break;
                default:
                    printf("Unknown Opcode: 0x%x", opcode);
                    break;
            }
            break;
        case 0xF000:
            switch (opcode & 0x00FF) {
                case 0x0007: /* FX07: Sets VX to the value of the delay timer */
                    printf("[0xFX07: Sets VX to the value of the delay timer]");
                    break;
                case 0x000A: /* FX0A: A key press is awaited, and then stored in VX */
                    printf("[0xFX0A: A key press is awaited, and then stored in VX]");
                    break;
                case 0x0015: /* FX15: Sets the delay timer to VX */
                    printf("[0xFX15: Sets the delay timer to VX]");
                    break;
                case 0x0018: /* FX18: Sets the sound timer to VX */
                    printf("[0xFX18: Sets the sound timer to VX]");
                    break;
                case 0x001E: /* FX1E: Adds VX to I */
                    printf("[0xFX1E: Adds VX to I]");
                    break;
                case 0x0029: /* FX29: Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font */
                    printf("[0xFX29: Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font]");
                    break;
                case 0x0033: /* FX33: Stores the Binary-coded decimal representation of VX, with the most significant of three digits at the address in I, the middle digit at I plus 1, and the least significant digit at I plus 2. (In other words, take the decimal representation of VX, place the hundreds digit in memory at location in I, the tens digit at location I+1, and the ones digit at location I+2.) */
                    printf("[0xFX33: Stores the Binary-coded decimal representation of VX, with the most significant of three digits at the address in I, the middle digit at I plus 1, and the least significant digit at I plus 2. (In other words, take the decimal representation of VX, place the hundreds digit in memory at location in I, the tens digit at location I+1, and the ones digit at location I+2]");
                    break;
                case 0x0055: /* 0xFX55: Stores V0 to VX in memory starting at address I */
                    printf("[0xFX55: Stores V0 to VX in memory starting at address I]");
                    break;
                case 0x0065: /* 0xFX65: Fills V0 to VX with values from memory starting at address I */
                    printf("[0xFX65: Fills V0 to VX with values from memory starting at address I]");
                    break;
                default:
                    printf("Unknown Opcode: 0x%x", opcode);
                    break;
            }
            break;
        default:
            printf("Unknown Opcode: 0x%x", opcode);
            break;
    }
}

- (void)dumpMemory:(BOOL)dumpMemory {
    printf("System Memory Dump:");
    printf("\n======================================================================================================================================================\n");
    printf("Stack Pointer: %i\tI: 0x%04x\tpc: 0x%04x\n", sp, I, pc);
    printf("Timers: %i\t%i\n", delay_timer, sound_timer);
    printf("Opcode: %x\t", opcode);
    [self printOpcodeFunction];
    printf("\n");
    printf("\nRegisters:\n");
    for (int i = 0; i < NUMREGS; i++) {
        printf("Register[%x]: %x\n", i, V[i]);
    }
    printf("\nInput:\n");
    for (int i = 0; i < NUM_INPUT; i++) {
        printf("Key[%x]: %x\n", i, key[i]);
    }
    printf("\nStack:\n");
    for (int i = 0; i < MAX_STACKSIZE; i++) {
        printf("Stack[%x]: %x\n", i, stack[i]);
    }
    if (dumpMemory) {
        printf("\nRaw_Memory:\n");
        int cnt = 0;
        int counter = 0;
        for (int i = 0; i < MEMSIZE; i++) {
            cnt++;
                    if (memory[i] != 0) {
            printf("[0x%04x]  0x%02x", cnt, memory[i]);
            counter ++; if (counter == 8) { printf("\n"); counter = 0; } else printf("  ");
                    }
        }
        printf("\nTotal Memory Size: %i", cnt);
    }
    printf("\n======================================================================================================================================================\n");
}


- (void)clearDisplay {
    for (int i = 0; i < DISPLAYSIZE; i++) {
        gfx[i] = 0;
    }
}

- (void)dumpGFX {
    printf("\n\n\n\n\nGFX:\n======================================================================================================================================================\n");
    for (int y = 0; y < 32; y++) {
        for (int x = 0; x < 64; x++) {
            for (int i = 0; i < 8; i++) {
                if (gfx[y*64+x] & (0x80 >> i)) printf("*"); else printf(".");
//                printf("%x", gfx[y*64+x] & (0x80 >> i));
            }
        }
    }
    printf("\n");
    printf("======================================================================================================================================================\n");
}

- (void)draw {
//    int posX = 0, posY = 0;
    for (int y = 0; y < 32; y++) {
        for (int x = 0; x < 64; x++) {
            for (int i = 0; i < 8; i++) {
                if (gfx[y*64+x] & (0x80 >> i)) [self drawWhitePixelAt:x*10 y:y*10]; else [self drawBlackPixelAt:x*10 y:y*10];
//                posX+=10; if (posX > DISPLAY_WIDTH * 10) { posX = 0; posY += 10; }
            }
        }
    }
}

- (void)drawWhitePixelAt:(int)x y:(int)y {
    glColor3f(1.0, 1.0, 1.0);
    glBegin(GL_POINTS);
        glVertex2i(x+5, y+5);
    glEnd();
}

- (void)drawBlackPixelAt:(int)x y:(int)y {
    glColor3f(0.0, 0.0, 0.0);
    glBegin(GL_POINTS);
    glVertex2i(x+5, y+5);
    glEnd();
}

- (void)emulateCycle {
    if (DEVELOPER) {
        printf("\n"); [self dumpMemory:false]; printf("\n");
    }
    opcode = memory[pc] << 8 | memory[pc + 1];
    switch (opcode & 0xF000) {
        case 0x0000:
            switch (opcode & 0x000F) {
                case 0x0000: /* 0x00E0: Clears the Screen */
                    [self clearDisplay];
                    pc += OPCODE_OFFSET;
                    break;
                case 0x000E: /* 0x00EE: Returns from a Subroutine */
                    pc = stack[--sp];
                    break;
                default:
                    printf("Unknown opcode [0x0000]: 0x%X\n", opcode);
                    break;
            }
            break;
        case 0x1000: /* 0x1NNN: Jumps to Adress NNN */
            pc = opcode & 0x0FFF;
            break;
        case 0x2000: /* 0x2NNN: Calls subroutine at NNN */
            stack[sp] = pc+OPCODE_OFFSET;
            sp++;
            pc = opcode & 0x0FFF;
            break;
        case 0x3000: /* 3XNN: Skips the next instruction if VX equals NN */
            if (V[(opcode & 0x0F00) >> 8] == (opcode & 0x00FF)) {
                pc +=OPCODE_OFFSET;
            }
            pc +=OPCODE_OFFSET;
            break;
        case 0x4000: /* 4XNN: Skips the next instruction if VX doesn't equal NN */
            if (V[(opcode & 0x0F00) >> 8] != (opcode & 0x00FF)) {
                pc +=OPCODE_OFFSET;
            }
            pc +=OPCODE_OFFSET;
            break;
        case 0x5000: /* 5XY0: Skips the next instruction if VX equals VY */
            if (V[(opcode & 0x0F00) >> 8] == V[(opcode & 0x00F0) >> 4]) {
                pc += OPCODE_OFFSET;
            }
            pc +=OPCODE_OFFSET;
            break;
        case 0x6000: /* 6XNN: sets VX to NN */
            V[(opcode & 0x0F00) >> 8] = (opcode & 0x00FF);
            pc += OPCODE_OFFSET;
            break;
        case 0x7000: /* 7XNN: adds NN to VX */
            V[(opcode & 0x0F00) >> 8] += (opcode & 0x00FF);
            pc += OPCODE_OFFSET;
            break;
        case 0x8000:
            switch (opcode & 0x000F) {
                case 0x0000: /* 8XY0: Sets VX to the value of VY */
                    V[(opcode & 0x0F00) >> 8] = V[(opcode & 0x00F0) >> 4];
                    pc += OPCODE_OFFSET;
                    break;
                case 0x0001: /* 8XY1: Sets VX to VX or VY */
                    V[(opcode & 0x0F00) >> 8] = V[(opcode & 0x0F00) >> 8] | V[(opcode & 0x00F0) >> 4];
                    pc += OPCODE_OFFSET;
                    break;
                case 0x0002: /* 8XY2: Sets VX to VX and VY */
                    V[(opcode & 0x0F00) >> 8] = V[(opcode & 0x0F00) >> 8] & V[(opcode & 0x00F0) >> 4];
                    pc += OPCODE_OFFSET;
                    break;
                case 0x0003: /* 8XY3: Sets VX to VX xor VY */
                    V[(opcode & 0x0F00) >> 8] = V[(opcode & 0x0F00) >> 8] ^ V[(opcode & 0x00F0) >> 4];
                    pc += OPCODE_OFFSET;
                    break;
                case 0x0004: /* 8XY4: Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't */
                    if (V[(opcode & 0x00F0) >> 4] > (0xFF - V[(opcode & 0x0F00) >> 8])) V[0xF] = 1; else V[0xF] = 0;
                    V[(opcode & 0x0F00) >> 8] += V[(opcode & 0x00F0) >> 4];
                    pc += OPCODE_OFFSET;
                    break;
                case 0x0005: /* 8XY5: VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't. */
                    if (V[(opcode & 0x00F0) >> 4] > V[(opcode & 0x0F00) >> 8]) V[(0xF)] = 1; else V[(0xF)] = 0;
                    V[(opcode & 0x0F00) >> 8] -= V[(opcode & 0x00F0) >> 4];
                    pc += OPCODE_OFFSET;
                    break;
                case 0x0006: /* 8XY6: Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift. */
                    V[(0xF)] = V[(opcode & 0x0F00) >> 8] & 0x0001;
                    V[(opcode & 0x0F00) >> 8] = V[(opcode & 0x0F00) >> 8] >> 1;
                    pc += OPCODE_OFFSET;
                    break;
                case 0x0007: /* 8XY7: Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't */
                    if (V[(opcode & 0x0F00) >> 8] > V[(opcode & 0x00F0) >> 4]) V[(0xF)] = 0; else V[(0xF)] = 1;
                    V[(opcode & 0x0F00) >> 8] = V[(opcode & 0x00F0) >> 4] - V[(opcode & 0x0F00) >> 8];
                    pc += OPCODE_OFFSET;
                    break;
                case 0x000E: /* 8XYE: Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift */
                    V[(0xF)] = (V[(opcode & 0x0F00) >> 8] & 0x8000) >> 15;
                    V[(opcode & 0x0F00) >> 8] = V[(opcode & 0x0F00) >> 8] << 1;
                    break;
                default:
                    printf("Unimplemented Opcode 0x8...\n");
                    break;
            }
            break;
        case 0x9000: /* 9XY0: Skips the next instruction if VX doesn't equal VY */
            if (V[(opcode & 0x0F00) >> 8] != V[(opcode & 0x00F0) >> 4]) {
                pc += OPCODE_OFFSET;
            }
            pc += OPCODE_OFFSET;
            break;
        case 0xA000: /* 0xANNN: Set's I to the Adress NNN */
            I = opcode & 0x0FFF;
            pc+= OPCODE_OFFSET;
            break;
        case 0xB000: /* BNNN: Jumps to the address NNN plus V0 */
            pc = V[0x0] + (opcode & 0x0FFF);
            break;
        case 0xC000: /* CXNN: Sets VX to a random number and NN */
            V[(opcode & 0x0F00) >> 8] = (arc4random() % 0xFF) & (opcode & 0x00FF);
            pc += OPCODE_OFFSET;
            break;
        case 0xD000: /* Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels. Each row of 8 pixels is read as bit-coded (with the most significant bit of each byte displayed on the left) starting from memory location I; I value doesn't change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn't happen */
        {
            unsigned short x = V[(opcode & 0x0F00) >> 8];
			unsigned short y = V[(opcode & 0x00F0) >> 4];
			unsigned short height = opcode & 0x000F;
			unsigned short pixel;
            
			V[0xF] = 0;
			for (int yline = 0; yline < height; yline++)
			{
				pixel = memory[I + yline];
				for(int xline = 0; xline < 8; xline++)
				{
					if((pixel & (0x80 >> xline)) != 0)
					{
						if(gfx[(x + xline + ((y + yline) * 64))] == 1)
						{
							V[0xF] = 1;
						}
						gfx[x + xline + ((y + yline) * 64)] ^= 1;
					}
				}
			}
            
			drawFlag = true;
			pc += OPCODE_OFFSET;
		}
            break;
        case 0xE000:
            switch (opcode & 0x00FF) {
                case 0x009E: /* EX9E: Skips the next instruction if the key stored in VX is pressed */
                    if (key[V[(opcode & 0x0F00) >> 8]] != 0) pc += OPCODE_OFFSET;
                    pc += OPCODE_OFFSET;
                    break;
                case 0x00A1: /* EXA1: Skips the next instruction if the key stored in VX isn't pressed */
                    if (key[V[(opcode & 0x0F00) >> 8]] == 0) pc += OPCODE_OFFSET;
                    pc += OPCODE_OFFSET;
                    break;
                default:
                    printf("Unimplemented Subopcode 0xE...\n");
                    break;
            }
            break;
        case 0xF000:
            switch (opcode & 0x00FF) {
                case 0x0007: /* FX07: Sets VX to the value of the delay timer */
                    V[(opcode & 0x0F00) >> 8] = delay_timer;
                    pc += OPCODE_OFFSET;
                    break;
                case 0x000A: /* FX0A: A key press is awaited, and then stored in VX */
                {
                    bool keyPress = false;
                    
                    for (int i = 0; i < NUM_INPUT; i++) {
                        if (key[i] != 0) {
                            V[(opcode & 0x0F00) >> 8] = i;
                            keyPress = true;
                        }
                    }
                    
                    if (keyPress) pc += OPCODE_OFFSET;
                }
                    break;
                case 0x0015: /* FX15: Sets the delay timer to VX */
                    delay_timer = V[(opcode & 0x0F00) >> 8];
                    pc += OPCODE_OFFSET;
                    break;
                case 0x0018: /* FX18: Sets the sound timer to VX */
                    sound_timer = V[(opcode & 0x0F00) >> 8];
                    pc += OPCODE_OFFSET;
                    break;
                case 0x001E: /* FX1E: Adds VX to I */
                    if ((I + V[(opcode & 0x0F00) >> 8]) > 0xFFF) V[0xF] = 1; else V[(0xF)] = 0;
                    I += V[(opcode & 0x0F00) >> 8];
                    pc += OPCODE_OFFSET;
                    break;
                case 0x0029: /* FX29: Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font */
                    I = V[(opcode & 0x0F00) >> 8] * 0x5;
					pc += OPCODE_OFFSET;
                    break;
                case 0x0033: /* FX33: Stores the Binary-coded decimal representation of VX, with the most significant of three digits at the address in I, the middle digit at I plus 1, and the least significant digit at I plus 2. (In other words, take the decimal representation of VX, place the hundreds digit in memory at location in I, the tens digit at location I+1, and the ones digit at location I+2.) */
                    memory[I] = V[(opcode & 0x0F00) >> 8] / 100;
                    memory[I + 1] = (V[(opcode & 0x0F00) >> 8] / 10) % 10;
                    memory[I + 2] = (V[(opcode & 0x0F00) >> 8] % 100) % 10;
                    pc += OPCODE_OFFSET;
                    break;
                case 0x0055: /* 0xFX55: Stores V0 to VX in memory starting at address I */
                    for (int i = 0; i <= ((opcode & 0x0F00) >> 8); ++i)
						memory[I + i] = V[i];
                    
					// On the original interpreter, when the operation is done, I = I + X + 1.
					I += ((opcode & 0x0F00) >> 8) + 1;
					pc += OPCODE_OFFSET;
                    break;
                case 0x0065: /* 0xFX65: Fills V0 to VX with values from memory starting at address I */
                    for (int i = 0; i <= ((opcode & 0x0F00) >> 8); ++i)
						V[i] = memory[I + i];
                    
					// On the original interpreter, when the operation is done, I = I + X + 1.
					I += ((opcode & 0x0F00) >> 8) + 1;
					pc += OPCODE_OFFSET;
                    break;
                default:
                    printf("Unimplemented Sub opcode 0xF...\n");
                    break;
            }
            break;
        default:
            printf("Unknown Opcode: 0x%x\n", opcode);
            break;
    }
    
    if (delay_timer > 0) {
        delay_timer--;
    }
    if (sound_timer > 0) {
        sound_timer--;
        printf("BEEP\n");
    }
}

- (unsigned char*)getGFX {
    return gfx;
}

- (void)setKey:(unsigned char)k keyNum:(int)num {
    key[num] = k;
}

- (void)loadRom {
    int fd; /* file Descriptor */
//    unsigned char *buffer;
    char *datafile;
    NSString* string = [NSString stringWithFormat:@"Chip-8 Emulator.app/Contents/Resources/Roms/%s.c8", self.rom];
    long bytes = 0;
    
//    buffer = (unsigned char*)ec_malloc(MAX_ROM_SIZE);
    datafile = (char*)ec_malloc(50);
    strcpy(datafile, [string cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    printf("Loading Data File: %s\n", datafile);
    fd = open(datafile, O_RDONLY);
    if (fd == -1)
        fatal("couldn't open Rom File");
    
    bytes = read(fd, (memory + ROM_OFFSET), MAX_ROM_SIZE);//

//    bytes = read(fd, buffer, MAX_ROM_SIZE);
    if (bytes == -1)
        fatal("couldn't read Rom File");
    
    if (DEVELOPER) {
        printf("\nRom Binary Dump:");
        printf("\n======================================================================================================================================================\n");
        for (int i = ROM_OFFSET; i < bytes+ROM_OFFSET; i++) {
            printf("0x%02x ", memory[i]);
        }
        printf("\n\nTotal Rom Size: %li bytes", bytes);
        printf("\n======================================================================================================================================================\n\n\n\n");
    }
    
//    for (int i = 0; i < bytes; i++) {
//        memory[i + ROM_OFFSET] = buffer[i];
//    }
    
    free(datafile);
//    free(buffer);
}

void fatal(char *message) {
    char error_message[100];
    strcpy(error_message, "[!!] Fatal Error "); strncat(error_message, message, 83); perror(error_message);
    exit(-1);
}

void *ec_malloc(unsigned int size) {
    void *ptr;
    ptr = malloc(size); if(ptr == NULL)
        fatal("in ec_malloc() on memory allocation"); return ptr;
}

@end
