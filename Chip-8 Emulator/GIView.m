//
//  GIView.m
//  Chip-8 Emulator
//
//  Created by Dominik Horn on 02.09.12.
//  Copyright (c) 2012 Dominik Horn. All rights reserved.
//

#import "GIView.h"
#import "CPU.h"

@implementation GIView

-(BOOL) acceptsFirstResponder
{
    return YES;
}

-(BOOL) becomeFirstResponder
{
    return YES;
}

-(BOOL) resignFirstResponder
{
    return YES;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    _context = nil;
    return self;
}

- (NSOpenGLContext*)openGLContext {
    if (!_pixelFormat) {
        NSOpenGLPixelFormatAttribute attributes[] = {
            NSOpenGLPFAWindow,
            NSOpenGLPFAAccelerated,
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFAMinimumPolicy,
            0
        };
        _pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
        if (!_pixelFormat) {
            NSRunAlertPanel(@"ERROR: couldn't setup OpenGL pixelFormat", @"", @"OK", nil, nil);
            /* Ask to Terminate */
            [[NSApplication sharedApplication] terminate:self];
        }
    }
    if (!_context) {
        _context = [[NSOpenGLContext alloc] initWithFormat:_pixelFormat shareContext:nil];
        if (!_context) {
            NSRunAlertPanel(@"ERROR: couldn't setup OpenGL context", @"", @"OK", nil, nil);
            /* Ask to Terminate */
            [[NSApplication sharedApplication] terminate:self];
        }
    }
    return _context;
}

- (void)lockFocus {
    [super lockFocus];
    NSOpenGLContext* c = [self openGLContext];
    if ([c view] != self) {
        [c setView:self];
    }
    [c makeCurrentContext];
}

- (void)prepareOpenGL {
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, WIDTH, HEIGHT, 0, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glPointSize(10);
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [_context update];
    glViewport(0, 0, WIDTH, HEIGHT);
    glLoadIdentity();
    glClear(GL_COLOR_BUFFER_BIT);
    
//    unsigned char* buff = [[CPU instance] getGFX];
//    int posX = 0, posY = 0;
//    for (int i = 0; i < DISPLAYSIZE; i++) {
//        posX+=10; if (posX == 64) { posX = 0; posY+=10; }
//        unsigned char byte = *(buff + i);
//        for (int cnt = 0; cnt < 8; cnt++) {
//            unsigned char bit = byte & (0x80 >> cnt);
//            if (bit) {
//                glBegin(GL_POINT);
//                    glVertex2i(posX, posY);
//                glEnd();
//            }
//        }
//    }
    [[CPU instance] draw];
    
    glFlush();
}

- (void)keyDown:(NSEvent *)theEvent {
    switch (theEvent.keyCode) {
        case 0x12: /* 1 */
//            NSLog(@"1");
            [[CPU instance] setKey:1 keyNum:0x1];
            break;
        case 0x13: /* 2 */
//            NSLog(@"2");
            [[CPU instance] setKey:1 keyNum:0x2];
            break;
        case 0x14: /* 3 */
//            NSLog(@"3");
            [[CPU instance] setKey:1 keyNum:0x3];
            break;
        case 0x15: /* 4 */
//            NSLog(@"4");
            [[CPU instance] setKey:1 keyNum:0xC];
            break;
        case 0x0C: /* Q */
//            NSLog(@"Q");
            [[CPU instance] setKey:1 keyNum:0x4];
            break;
        case 0x0D: /* W */
//            NSLog(@"W");
            [[CPU instance] setKey:1 keyNum:0x5];
            break;
        case 0x0E: /* E */
//            NSLog(@"E");
            [[CPU instance] setKey:1 keyNum:0x6];
            break;
        case 0x0F: /* R */
//            NSLog(@"R");
            [[CPU instance] setKey:1 keyNum:0xD];
            break;
        case 0x00: /* A */
//            NSLog(@"A");
            [[CPU instance] setKey:1 keyNum:0x7];
            break;
        case 0x01: /* S */
//            NSLog(@"S");
            [[CPU instance] setKey:1 keyNum:0x8];
            break;
        case 0x02: /* D */
//            NSLog(@"D");
            [[CPU instance] setKey:1 keyNum:0x9];
            break;
        case 0x03: /* F */
//            NSLog(@"F");
            [[CPU instance] setKey:1 keyNum:0xE];
            break;
        case 0x06: /* Y */
//            NSLog(@"Y");
            [[CPU instance] setKey:1 keyNum:0xA];
            break;
        case 0x07: /* X */
//            NSLog(@"X");
            [[CPU instance] setKey:1 keyNum:0x0];
            break;
        case 0x08: /* C */
//            NSLog(@"C");
            [[CPU instance] setKey:1 keyNum:0xB];
            break;
        case 0x09: /* V */
//            NSLog(@"V");
            [[CPU instance] setKey:1 keyNum:0xF];
            break;
        default:
            [super keyDown:theEvent];
            break;
    }
}

- (void)keyUp:(NSEvent *)theEvent {
    switch (theEvent.keyCode) {
        case 0x12: /* 1 */
//            NSLog(@"1");
            [[CPU instance] setKey:0 keyNum:0x1];
            break;
        case 0x13: /* 2 */
//            NSLog(@"2");
            [[CPU instance] setKey:0 keyNum:0x2];
            break;
        case 0x14: /* 3 */
//            NSLog(@"3");
            [[CPU instance] setKey:0 keyNum:0x3];
            break;
        case 0x15: /* 4 */
//            NSLog(@"4");
            [[CPU instance] setKey:0 keyNum:0xC];
            break;
        case 0x0C: /* Q */
//            NSLog(@"Q");
            [[CPU instance] setKey:0 keyNum:0x4];
            break;
        case 0x0D: /* W */
//            NSLog(@"W");
            [[CPU instance] setKey:0 keyNum:0x5];
            break;
        case 0x0E: /* E */
//            NSLog(@"E");
            [[CPU instance] setKey:0 keyNum:0x6];
            break;
        case 0x0F: /* R */
//            NSLog(@"R");
            [[CPU instance] setKey:0 keyNum:0xD];
            break;
        case 0x00: /* A */
//            NSLog(@"A");
            [[CPU instance] setKey:0 keyNum:0x7];
            break;
        case 0x01: /* S */
//            NSLog(@"S");
            [[CPU instance] setKey:0 keyNum:0x8];
            break;
        case 0x02: /* D */
//            NSLog(@"D");
            [[CPU instance] setKey:0 keyNum:0x9];
            break;
        case 0x03: /* F */
//            NSLog(@"F");
            [[CPU instance] setKey:0 keyNum:0xE];
            break;
        case 0x06: /* Y */
//            NSLog(@"Y");
            [[CPU instance] setKey:0 keyNum:0xA];
            break;
        case 0x07: /* X */
//            NSLog(@"X");
            [[CPU instance] setKey:0 keyNum:0x0];
            break;
        case 0x08: /* C */
//            NSLog(@"C");
            [[CPU instance] setKey:0 keyNum:0xB];
            break;
        case 0x09: /* V */
//            NSLog(@"V");
            [[CPU instance] setKey:0 keyNum:0xF];
            break;
        default:
            [super keyUp:theEvent];
            break;
    }
}

- (void)dealloc
{
    [_pixelFormat release];
    [_context release];
    [super dealloc];
}


@end
