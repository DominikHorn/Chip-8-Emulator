//
//  GIView.h
//  Chip-8 Emulator
//
//  Created by Dominik Horn on 02.09.12.
//  Copyright (c) 2012 Dominik Horn. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/glu.h>

#define WIDTH 640
#define HEIGHT 320

@interface GIView : NSView {
    NSOpenGLContext* _context;
    NSOpenGLPixelFormat* _pixelFormat;
}

@end
