//
//  PreferenceController.h
//  LRotor
//
//  Created by Mike Reublin on 2/14/13.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "ORSSerialPort.h"
#import "ORSSerialPortManager.h"


extern NSString * const myBGColorKey;
extern NSString * const myTxtColorKey;

extern NSString * const myBGColorChangedNotification;
extern NSString * const myTextColorChangedNotification;
extern NSString * const myRotorChangedNotification;
extern NSString * const myPortChangedNotification;
extern NSString * const myOnTopChangedNotification;


@interface PreferenceController:NSWindowController
{
	IBOutlet NSColorWell *bgColorWell;
	IBOutlet NSColorWell *textColorWell;
	IBOutlet NSMatrix *matrixRotor;
	IBOutlet NSPopUpButton *portsButton;
	IBOutlet NSButton *buttonOnTop;
}

@property (strong) IBOutlet NSPopUpButton *putSettings;

- (IBAction)putSettings:(id)sender;
- (IBAction)setBGColor:(id)sender;
- (IBAction)setTextColor:(id)sender;
- (IBAction)setRotorTag:(id)sender;
- (IBAction)setOnTopStatus:(id)sender;

-(id)init;

+ (NSColor *)preferenceBGColor;
+ (NSColor *)preferenceTxtColor;
+ (NSInteger)preferenceRotorTag;
+ (NSInteger)preferenceOnTopTag;

+ (void)setPreferenceBGColor:(NSColor *)color;
+ (void)setPreferenceTxtColor:(NSColor *)color;
+ (void)setPreferenceRotor:(NSInteger)matrixTag;
+ (void)setPreferenceOnTop:(NSInteger)onTopState;

@end



