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
#import "ECVConfigController.h"

// Models
#import "ECVCaptureDevice.h"

// Other Sources
#import "ECVAudioDevice.h"

@interface ECVConfigController(Private)

- (void)_snapSlider:(NSSlider *)slider;

@end

@implementation ECVConfigController

#pragma mark +ECVConfigController

+ (id)sharedConfigController
{
	static ECVConfigController *c;
	if(!c) c = [[self alloc] init];
	return [[c retain] autorelease];
}

#pragma mark -ECVConfigController

- (IBAction)changeFormat:(id)sender
{
	_captureDevice.videoFormatObject = [[sender selectedItem] representedObject];
}
- (IBAction)changeSource:(id)sender
{
	_captureDevice.videoSourceObject = [[sender selectedItem] representedObject];
}
- (IBAction)changeDeinterlacing:(id)sender
{
	_captureDevice.deinterlacingMode = [sender selectedTag];
}
- (IBAction)changeBrightness:(id)sender
{
	[self _snapSlider:sender];
	_captureDevice.brightness = [sender doubleValue];
}
- (IBAction)changeContrast:(id)sender
{
	[self _snapSlider:sender];
	_captureDevice.contrast = [sender doubleValue];
}
- (IBAction)changeSaturation:(id)sender
{
	[self _snapSlider:sender];
	_captureDevice.saturation = [sender doubleValue];
}
- (IBAction)changeHue:(id)sender
{
	[self _snapSlider:sender];
	_captureDevice.hue = [sender doubleValue];
}

#pragma mark -

- (IBAction)changeAudioInput:(id)sender
{
	_captureDevice.audioInput = [[sender selectedItem] representedObject];
}
- (IBAction)changeVolume:(id)sender
{
	_captureDevice.volume = [sender doubleValue];
}

#pragma mark -

@synthesize captureDevice = _captureDevice;
- (void)setCaptureDevice:(ECVCaptureDevice *)c
{
	_captureDevice = c;

	if(![self isWindowLoaded]) return;

	[sourcePopUp removeAllItems];
	if([_captureDevice respondsToSelector:@selector(allVideoSourceObjects)]) for(id const videoSourceObject in _captureDevice.allVideoSourceObjects) {
		if([NSNull null] == videoSourceObject) {
			[[sourcePopUp menu] addItem:[NSMenuItem separatorItem]];
			continue;
		}
		NSMenuItem *const item = [[[NSMenuItem alloc] initWithTitle:[_captureDevice localizedStringForVideoSourceObject:videoSourceObject] action:NULL keyEquivalent:@""] autorelease];
		[item setRepresentedObject:videoSourceObject];
		[item setEnabled:[_captureDevice isValidVideoSourceObject:videoSourceObject]];
		[item setIndentationLevel:[_captureDevice indentationLevelForVideoSourceObject:videoSourceObject]];
		[[sourcePopUp menu] addItem:item];
	}
	[sourcePopUp setEnabled:[_captureDevice respondsToSelector:@selector(videoSourceObject)]];
	if([sourcePopUp isEnabled]) [sourcePopUp selectItemAtIndex:[sourcePopUp indexOfItemWithRepresentedObject:_captureDevice.videoSourceObject]];

	[formatPopUp removeAllItems];
	if([_captureDevice respondsToSelector:@selector(allVideoFormatObjects)]) for(id const videoFormatObject in _captureDevice.allVideoFormatObjects) {
		if([NSNull null] == videoFormatObject) {
			[[formatPopUp menu] addItem:[NSMenuItem separatorItem]];
			continue;
		}
		NSMenuItem *const item = [[[NSMenuItem alloc] initWithTitle:[_captureDevice localizedStringForVideoFormatObject:videoFormatObject] action:NULL keyEquivalent:@""] autorelease];
		[item setRepresentedObject:videoFormatObject];
		[item setEnabled:[_captureDevice isValidVideoFormatObject:videoFormatObject]];
		[item setIndentationLevel:[_captureDevice indentationLevelForVideoFormatObject:videoFormatObject]];
		[[formatPopUp menu] addItem:item];
	}
	[formatPopUp setEnabled:[_captureDevice respondsToSelector:@selector(videoFormatObject)]];
	if([formatPopUp isEnabled]) [formatPopUp selectItemAtIndex:[formatPopUp indexOfItemWithRepresentedObject:_captureDevice.videoFormatObject]];

	[deinterlacePopUp selectItemWithTag:_captureDevice.deinterlacingMode];
	[deinterlacePopUp setEnabled:!!_captureDevice];

	[brightnessSlider setEnabled:[_captureDevice respondsToSelector:@selector(brightness)]];
	[contrastSlider setEnabled:[_captureDevice respondsToSelector:@selector(contrast)]];
	[saturationSlider setEnabled:[_captureDevice respondsToSelector:@selector(saturation)]];
	[hueSlider setEnabled:[_captureDevice respondsToSelector:@selector(hue)]];
	[volumeSlider setEnabled:[_captureDevice respondsToSelector:@selector(volume)]];
	[brightnessSlider setDoubleValue:[brightnessSlider isEnabled] ? _captureDevice.brightness : 0.5f];
	[contrastSlider setDoubleValue:[contrastSlider isEnabled] ? _captureDevice.contrast : 0.5f];
	[saturationSlider setDoubleValue:[saturationSlider isEnabled] ? _captureDevice.saturation : 0.5f];
	[hueSlider setDoubleValue:[hueSlider isEnabled] ? _captureDevice.hue : 0.5f];
	[volumeSlider setDoubleValue:[volumeSlider isEnabled] ? _captureDevice.volume : 1.0f];
	[self _snapSlider:brightnessSlider];
	[self _snapSlider:contrastSlider];
	[self _snapSlider:saturationSlider];
	[self _snapSlider:hueSlider];

	[self audioHardwareDevicesDidChange:nil];
}

#pragma mark -

- (void)audioHardwareDevicesDidChange:(NSNotification *)aNotif
{
	[audioSourcePopUp removeAllItems];
	ECVAudioDevice *const preferredInput = _captureDevice.audioInputOfCaptureHardware;
	if(preferredInput) {
		NSMenuItem *const item = [[[NSMenuItem alloc] initWithTitle:preferredInput.name action:NULL keyEquivalent:@""] autorelease];
		[item setRepresentedObject:preferredInput];
		[[audioSourcePopUp menu] addItem:item];
		[[audioSourcePopUp menu] addItem:[NSMenuItem separatorItem]];
	}
	for(ECVAudioDevice *const device in [ECVAudioDevice allDevicesInput:YES]) {
		if(ECVEqualObjects(device, preferredInput)) continue;
		NSMenuItem *const item = [[[NSMenuItem alloc] initWithTitle:device.name action:NULL keyEquivalent:@""] autorelease];
		[item setRepresentedObject:device];
		[[audioSourcePopUp menu] addItem:item];
	}
	[audioSourcePopUp selectItemAtIndex:[audioSourcePopUp indexOfItemWithRepresentedObject:_captureDevice.audioInput]];
	[audioSourcePopUp setEnabled:!!_captureDevice];
}

#pragma mark -ECVConfigController(Private)

- (void)_snapSlider:(NSSlider *)slider
{
	if(ABS([slider doubleValue] - 0.5f) < 0.03f) [slider setDoubleValue:0.5f];
}

#pragma mark -NSWindowController

- (void)windowDidLoad
{
	[super windowDidLoad];
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioHardwareDevicesDidChange:) name:ECVAudioHardwareDevicesDidChangeNotification object:[ECVAudioDevice class]];
	[self setCaptureDevice:_captureDevice];
}

#pragma mark -NSObject

- (id)init
{
	return [super initWithWindowNibName:@"ECVConfig"];
}

@end
