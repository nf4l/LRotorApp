//
//  PreferenceController.m
//  LRotor
//
//  Created by Mike Reublin on 2/14/13.
//
//

#import "PreferenceController.h"
#import "AppController.h"

NSString * const myBGColorKey = @"bgColor";
NSString * const myTxtColorKey = @"txtColor";
NSString * const myPortKey = @"portKey";
NSString * const myRotorKey = @"rotorKey";
NSString * const myOnTopKey = @"OnTopKey";
NSString * const myBGColorChangedNotification = @"myBGColorChanged";
NSString * const myTextColorChangedNotification = @"myTextColorChanged";
NSString * const myRotorChangedNotification = @"myRotorChanged";
NSString * const myPortChangedNotification = @"myPortChanged";
NSString * const myOnTopChangedNotification = @"myOnTopChanged";

@implementation PreferenceController

-(id)init
{
	self = [super initWithWindowNibName:@"PreferenceController"];
	return self;
}

- (void)awakeFromNib
{
	NSCell *blankCell = [[NSCell alloc] init];
	blankCell.enabled = NO;
	blankCell.title = @"";
	[matrixRotor putCell:blankCell atRow:3 column:1];
	[blankCell release];
	[portsButton removeAllItems];
	[portsButton addItemWithTitle:(@"Ports")];
	
	ORSSerialPortManager *portManager = [ORSSerialPortManager sharedSerialPortManager];
	NSArray *portPaths = [portManager.availablePorts valueForKey:@"path"];
	[portsButton addItemsWithTitles:portPaths];
/*
	ORSSerialPortManager *portManager = [ORSSerialPortManager sharedSerialPortManager];
	NSArray *availablePorts = portManager.availablePorts;
	NSMutableString * result = [[NSMutableString alloc] init];
	NSString *portString;
	for (NSObject * obj in availablePorts)
	{
		//NSString *presult = [availablePorts objectAtIndex:i];
    result = [[obj description] mutableCopy];
		portString = @"/dev/cu.";
		portString = [portString stringByAppendingString:(NSString *) result];
		[portsButton addItemWithTitle:(portString)];
	}
	[result release];
 */
	[self getSettings];
}

- (void)windowDidLoad
{
	// Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

	[super windowDidLoad];
	if([PreferenceController preferenceBGColor])
	{
    [bgColorWell setColor:[PreferenceController preferenceBGColor]];
	}
	if([PreferenceController preferenceTxtColor])
	{
	  [textColorWell setColor:[PreferenceController preferenceTxtColor]];
	}
	if([PreferenceController preferenceRotorTag])
	{
	  [matrixRotor selectCellWithTag:[PreferenceController preferenceRotorTag]];
	}
	if([PreferenceController preferenceOnTopTag])
	{
	  [buttonOnTop setState:[PreferenceController preferenceOnTopTag]];
	}
}

- (BOOL)windowShouldClose:(id)sender
{
	BOOL cp = [NSColorPanel sharedColorPanelExists];
	if (cp)
	{
		NSColorPanel *scp = [NSColorPanel sharedColorPanel];
		[scp orderOut:sender];
	}
	return YES;
}

+ (NSColor *)preferenceBGColor
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *colorAsData = [defaults objectForKey:myBGColorKey];
	return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}
					
+ (NSColor *)preferenceTxtColor
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *colorAsData = [defaults objectForKey:myTxtColorKey];
	return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}

+ (NSInteger)preferenceRotorTag
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger rt = [defaults integerForKey:myRotorKey];
	return  rt;
}

+ (NSInteger)preferenceOnTopTag
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger ot = [defaults integerForKey:myOnTopKey];
	return ot;
}  

+ (void)setPreferenceBGColor:(NSColor *)color
{
  NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
	[[NSUserDefaults standardUserDefaults]setObject:colorAsData forKey:myBGColorKey];
}

+ (void)setPreferenceTxtColor:(NSColor *)color
{
	NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
	[[NSUserDefaults standardUserDefaults]setObject:colorAsData forKey:myTxtColorKey];		
}

+ (void)setPreferenceRotor:(NSInteger)matrixTag
{
	[[NSUserDefaults standardUserDefaults] setInteger:matrixTag forKey:myRotorKey];
}

+ (void)setPreferenceOnTop:(NSInteger)onTopState
{
	[[NSUserDefaults standardUserDefaults] setInteger:onTopState forKey:myOnTopKey];
}

- (IBAction)setRotorTag:(id)sender
{
	NSButtonCell *selCell = [sender selectedCell];
	[PreferenceController setPreferenceRotor:[selCell tag]];
	NSLog(@"Rotor chosen");
	NSNotificationCenter *nr = [NSNotificationCenter defaultCenter];
  NSLog(@"Sending notification");
  [nr postNotificationName:myRotorChangedNotification
										object:self
									userInfo:nil];
}

- (IBAction)setOnTopStatus:(id)sender
{
  [PreferenceController setPreferenceOnTop:[buttonOnTop state]];
  NSNotificationCenter *no = [NSNotificationCenter defaultCenter];
  NSLog(@"Sending notification");
//	NSDictionary *d = [NSDictionary dictionaryWithObject:myOnTopKey
//																								forKey:@"myBGcolorKey"];
  [no postNotificationName:myOnTopChangedNotification
										object:self
									userInfo:nil];
}

- (IBAction)setBGColor:(id)sender
{
	NSColor *color = [sender color];
	[PreferenceController setPreferenceBGColor:color];
  NSLog(@"Color changed: %@", color);
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  NSLog(@"Sending notification");
	NSDictionary *d = [NSDictionary dictionaryWithObject:color
																								forKey:@"myBGcolorKey"];
  [nc postNotificationName:myBGColorChangedNotification
										object:self
									userInfo:d];
}

- (IBAction)setTextColor:(id)sender
{
	NSColor *txtColor = [sender color];
	[PreferenceController setPreferenceTxtColor:txtColor];
	NSLog(@"Color changed: %@", txtColor);
  
  NSNotificationCenter *nd = [NSNotificationCenter defaultCenter];
  NSLog(@"Sending notification");
	NSDictionary *d = [NSDictionary dictionaryWithObject:txtColor
																								forKey:@"myTxtColorKey"];
  [nd postNotificationName:myTextColorChangedNotification
										object:self
									userInfo:d];
}

- (void)getSettings
{
	NSInteger myInt;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	// getting an NSInteger
	myInt = [prefs integerForKey:@"Port"];
	[portsButton selectItemAtIndex:(myInt)];
	// getting an NSString
	//NSString *myString = [prefs stringForKey:@"keyToLookupString"];
}

- (IBAction)putSettings:(id)sender
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	// saving an NSInteger
	if ([portsButton indexOfSelectedItem] > 0)
	{
	  [prefs setInteger:[portsButton indexOfSelectedItem] forKey:@"Port"];
		[prefs setObject:[portsButton titleOfSelectedItem] forKey:@"portName"];
	}
	if([sender tag] == 1)
	{
		NSString *portStr = [portsButton titleOfSelectedItem];
		NSNotificationCenter *np = [NSNotificationCenter defaultCenter];
		NSLog(@"Sending notification");
		NSDictionary *d = [NSDictionary dictionaryWithObject:portStr
																									forKey:@"myPortKey"];
		[np postNotificationName:myPortChangedNotification
											object:self
										userInfo:d];

	}
	// saving an NSString
	//[prefs setObject:@"TextToSave" forKey:@"keyToLookupString"];
}



@end
