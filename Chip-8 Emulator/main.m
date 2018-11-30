//
//  main.m
//  Chip-8 Emulator
//
//  Created by Dominik Horn on 02.09.12.
//  Copyright (c) 2012 Dominik Horn. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CPU.h"

void listRoms() {
    /* TODO: list all the roms we could use */
}

int main(int argc, char *argv[])
{
    if (argc < 2) { printf("Usage: %s <Rom_Name>\n", argv[0]); exit(0); }
//    [CPU instance].rom = argv[1];
    [CPU instance].rom = "tetris";
    return NSApplicationMain(argc, (const char **)argv);
}
