/* Copyright (c) 2009, Ben Trask
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * The names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY BEN TRASK ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL BEN TRASK BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface MPLVideoView : NSOpenGLView
{
	@private
	IBOutlet id delegate;
	CVImageBufferRef _imageBuffer;
	CVOpenGLTextureRef _previousTextureBuffer;
	CVOpenGLTextureCacheRef _cache;
	NSSize _aspectRatio;
	CGFloat _position;
	NSUInteger _flushCacheCounter;
	BOOL _blurFramesTogether;
	BOOL _vsync;
	BOOL _showDroppedFrames;
	float _frameDropStrength;
	GLint _magFilter;
}

@property(assign) id delegate;
@property CVImageBufferRef imageBuffer;
@property(assign) NSSize aspectRatio;
@property(assign) BOOL blurFramesTogether;
@property(assign) BOOL vsync;
@property(assign) BOOL showDroppedFrames;
@property(assign) GLint magFilter;

- (void)droppedFrame:(BOOL)flag;

@end

@interface NSObject (MPLVideoViewDelegate)

- (BOOL)videoView:(MPLVideoView *)sender handleKeyDown:(NSEvent *)anEvent;

@end
