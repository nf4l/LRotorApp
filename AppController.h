//
//  AppController.h
//  LRotor
//

#import <Cocoa/Cocoa.h>
#import "ORSSerialPort.h"
#import <Foundation/Foundation.h>

@class PreferenceController;

@interface AppController : NSObject {
	IBOutlet NSTextField *inputTextField;
	IBOutlet NSTextField *inputTextField2;
	IBOutlet NSButton *buttonSend;
	IBOutlet NSButton *buttonSend2;
	IBOutlet NSButton *buttonLP;
	IBOutlet NSButton * buttonLP2;
	IBOutlet NSWindow *myWindow;
  IBOutlet NSView *myView;
	IBOutlet NSButton *buttonLED3;
	IBOutlet NSTextField *MyHdgLabel;
	IBOutlet NSTextField *labelConnection;
	ORSSerialPort *serialPort;
	PreferenceController *preferenceController;
}

@property (nonatomic, retain) ORSSerialPort *serialPort;
@property (nonatomic,retain) NSString *CurrentPort;
@property (nonatomic, retain) NSString *CurrentBaud;
@property (nonatomic) NSInteger currentOnTopState;

- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)send:(id)sender;

- (void)enableCommUI:(BOOL)flag;
- (void)showAlert:(NSString *)msg;
- (void)getSettings;
- (void)initPort;
- (void)controlTextDidChange:(NSNotification *)notification;

@end
