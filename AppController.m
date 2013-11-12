//
//  AppController.m
//  LRotor
//


#import "AppController.h"
#import "PreferenceController.h"
#import "HdgFormatter.h"

@implementation AppController

@synthesize serialPort;
@synthesize CurrentBaud;
@synthesize CurrentPort;
@synthesize currentOnTopState;

- (id)init
{
	self = [super init];
	if (self)
	{ 
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
					 selector:@selector(handleColorChange:)
							 name:myBGColorChangedNotification
						 object:nil];
		NSNotificationCenter *nd = [NSNotificationCenter defaultCenter];
		[nd addObserver:self
					 selector:@selector(handleTextColorChange:)
							 name:myTextColorChangedNotification
						 object:nil];
		
		NSNotificationCenter *nr = [NSNotificationCenter defaultCenter];
		[nr addObserver:self
					 selector:@selector(handleRotorChange:)
							 name:myRotorChangedNotification
						 object:nil];
		
		NSNotificationCenter *np = [NSNotificationCenter defaultCenter];
		[np addObserver:self
					 selector:@selector(handlePortChange:)
							 name:myPortChangedNotification
						 object:nil];
		
		NSNotificationCenter *no = [NSNotificationCenter defaultCenter];
		[no addObserver:self
					 selector:@selector(handleOnTopChange:)
							 name:myOnTopChangedNotification
						 object:nil];

	}
	return self;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	if ( flag ) {
		[myWindow orderFront:self];
	}
	else {
		[myWindow makeKeyAndOrderFront:self];
	}
	return YES;
}

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:[NSColor lightGrayColor]];
	[defaultValues setObject:colorAsData forKey:myBGColorKey];
	colorAsData = [NSKeyedArchiver archivedDataWithRootObject:[NSColor blackColor]];
	[defaultValues setObject:colorAsData forKey:myTxtColorKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void)awakeFromNib
{
	[self enableCommUI:NO];
  [[buttonLED3 cell] setBackgroundColor:[NSColor redColor]];
	[self getSettings];
	///////////
	[[myWindow windowController] setShouldCascadeWindows:NO];
	[myWindow setFrameAutosaveName:@"My Window"];
	[myWindow makeKeyAndOrderFront:nil];
	//[myWindow setOpaque:NO]; // YES by default
	[myWindow setBackgroundColor:[PreferenceController preferenceBGColor]];
	[MyHdgLabel setTextColor:[PreferenceController preferenceTxtColor]];
	[labelConnection setTextColor:[PreferenceController preferenceTxtColor]];
	if([CurrentBaud length] > 0 && [CurrentPort length] > 0)
	{
		[self initPort];
	}
	[self toggleOnTop];
	[[myWindow windowController] setShouldCascadeWindows:NO];
	[myWindow setFrameAutosaveName:@"My Window"];
	[myWindow makeKeyAndOrderFront:nil];
	//[myWindow setOpaque:NO]; // YES by default
	[myWindow setBackgroundColor:[PreferenceController preferenceBGColor]];
	[MyHdgLabel setTextColor:[PreferenceController preferenceTxtColor]];
	[labelConnection setTextColor:[PreferenceController preferenceTxtColor]];
	if([CurrentBaud length] > 0 && [CurrentPort length] > 0)
	{
		[self initPort];
	}
	[self toggleOnTop];
}


-(void)handleColorChange:(NSNotification *)note
{
  NSLog(@"Received BG notification: %@", note);
  NSColor *color = [[note userInfo]objectForKey:@"myBGcolorKey"];
  [myWindow setBackgroundColor:color];
}

-(void)handleTextColorChange:(NSNotification *)note
{
	NSLog(@"Received Text notification: %@", note);
	NSColor *tcolor = [[note userInfo]objectForKey:@"myTxtColorKey"];
  [MyHdgLabel setTextColor:tcolor];
	[labelConnection setTextColor:tcolor];
}

-(void)handleRotorChange:(NSNotification *)note
{
	[self getSettings];
	if([CurrentBaud length] > 0 && [CurrentPort length] > 0)
	{
		[self initPort];
	}
}

-(void)handlePortChange:(NSNotification *)note
{
	[self getSettings];
	if([CurrentBaud length] > 0 && [CurrentPort length] > 0)
	{
		[self initPort];
	}
}


-(void)handleOnTopChange:(NSNotification *)note
{
	currentOnTopState = [PreferenceController preferenceOnTopTag];
	[self toggleOnTop];
}

-(void)toggleOnTop
{
	if (currentOnTopState) {
    [myWindow setLevel:NSFloatingWindowLevel];
  } else {
    [myWindow setLevel:NSNormalWindowLevel];
  }
}

-(void)enableCommUI:(BOOL)flag
{
	[inputTextField setEnabled:flag];
	[buttonSend setEnabled:flag];
	[buttonLP setEnabled:flag];
}

-(void)enableLine2:(BOOL)flag
{
	[inputTextField2 setEnabled:flag];
	[buttonSend2 setEnabled:flag];
	[buttonLP2 setEnabled:flag];
}

-(void)showAlert:(NSString *)msg
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:msg];
	[alert beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow
                      modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (void)initPort
{
	NSString *deviceName = CurrentPort;
	NSString *tmpBaud = CurrentBaud;
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber * baudRate = [f numberFromString:tmpBaud];
	[f release];
	NSString *errMsg = @"Couldn't open port: ";
	errMsg = [errMsg stringByAppendingString:deviceName];
	if (serialPort.isOpen){	[serialPort close]; }
  serialPort = [ORSSerialPort serialPortWithPath:deviceName];
	serialPort.baudRate = baudRate;
	serialPort.parity = ORSSerialPortParityNone;
	//serialPort. setStopBits:(kAMSerialStopBitsOne)];
	//[self.serialPort setDataBits:(dbits)];
	// register as self as delegate for port
	//[self.serialPort setDelegate:self];
		
	// open port - may take a few seconds ...
	//if ([serialPort.isOpen])
	//{
	[serialPort open];
	if (serialPort.isOpen)
	{
	  [self enableCommUI:YES];
		[[buttonLED3 cell] setBackgroundColor:[NSColor greenColor]];
	}
	else
	{ // an error occured while creating port
		[self enableCommUI:NO];
		[[buttonLED3 cell] setBackgroundColor:[NSColor redColor]];
    [self showAlert:errMsg];
		serialPort = nil;
	}
}

- (void)serialPortReadData:(NSDictionary *)dataDictionary
{
/*
	// this method is called if data arrives
	// @"data" is the actual data, @"serialPort" is the sending port
	AMSerialPort *sendPort = [dataDictionary objectForKey:@"serialPort"];
	NSData *data = [dataDictionary objectForKey:@"data"];
	if ([data length] > 0) {
		NSString *text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		//[outputTextView insertText:text];
		[text release];
		// continue listening
		[sendPort readDataInBackground];
	} else { // port closed
		//[outputTextView insertText:@"port closed\r"];
	}
	//[outputTextView setNeedsDisplay:YES];
	//[outputTextView displayIfNeeded];
 */
}


- (IBAction)showPreferencePanel:(id)sender
{
	if(!preferenceController)
  {
    preferenceController = [[PreferenceController alloc] init];
  }
	[preferenceController showWindow:self];
}

- (IBAction)send:(id)sender
{
	if (![serialPort isOpen])
	{
		return;
	}
	NSInteger r = [PreferenceController preferenceRotorTag];
	NSString *sendString = @"";
	NSString *tmpStr;
	NSString *tmpVal;
	NSString *hdgVal;
	NSData *dataToSend;
	int i;
	int c;
	char j;
	long st;
	st = [sender tag];
	if([sender tag] ==1)
	{
		NSButton *btn=(NSButton *)sender;
	  [btn setTitle:([btn.title isEqualToString:@"LP"] ? @"SP" : @"LP")];

		i = [inputTextField intValue];
		if(i < 181)
		{
			i = i + 180;
		}
		else if (i > 180)
		{
			i = i - 180;
		}
		NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
		[numberFormatter setPaddingCharacter:@"0"];
		[numberFormatter setMinimumIntegerDigits:3];
		NSNumber * number = [NSNumber numberWithInt:i];
		tmpStr = [numberFormatter stringFromNumber:number];
		[numberFormatter release];
		[inputTextField setStringValue:tmpStr];
		hdgVal = tmpStr;
	}
	else if([sender tag] == 0)
	{
		[buttonLP setTitle:@"LP"];
		tmpStr = [inputTextField stringValue];
		while([tmpStr length] < 3)
		{
		  tmpStr = [@"0" stringByAppendingString:tmpStr];
		}
		[inputTextField setStringValue:tmpStr];
		hdgVal = tmpStr;
	}
	else if([sender tag] ==3)
	{
		NSButton *btn=(NSButton *)sender;
	  [btn setTitle:([btn.title isEqualToString:@"LP"] ? @"SP" : @"LP")];
		
		i = [inputTextField2 intValue];
		if(i < 181)
		{
			i = i + 180;
		}
		else if (i > 180)
		{
			i = i - 180;
		}
		NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
		[numberFormatter setPaddingCharacter:@"0"];
		[numberFormatter setMinimumIntegerDigits:3];
		NSNumber * number = [NSNumber numberWithInt:i];
		tmpStr = [numberFormatter stringFromNumber:number];
		[numberFormatter release];
		[inputTextField2 setStringValue:tmpStr];
		hdgVal = tmpStr;
	}
	else if([sender tag] == 2)
	{
		[buttonLP2 setTitle:@"LP"];
		tmpStr = [inputTextField2 stringValue];
		while([tmpStr length] < 3)
		{
		  tmpStr = [@"0" stringByAppendingString:tmpStr];
		}
		[inputTextField2 setStringValue:tmpStr];
		hdgVal = tmpStr;
	}

	switch(r)
	{
		case 1:    //Alfaspid and Yaesu
		case 7:
			sendString = @"M";
			sendString = [sendString stringByAppendingString:(hdgVal)];
			sendString = [sendString stringByAppendingString:@"\r\n"];
			dataToSend = [sendString dataUsingEncoding:NSUTF8StringEncoding];
			[serialPort sendData:dataToSend];
			break;
		case 2:    //DCU
			sendString = @"AP1";
			//NSLog(@"SendString = %@", sendString);
			//NSLog(@"SendString = %@", [inputTextField stringValue]);
			//sendString = [sendString stringByAppendingString:([inputTextField stringValue])];
			sendString = [sendString stringByAppendingString:(hdgVal)];
			NSLog(@"SendString = %@", sendString);
			//			sendString = [sendString stringByAppendingString:@";AM1;\r\n"];
			sendString = [sendString stringByAppendingString:@";AM1;"];
		
			NSLog(@"SendString = %@", sendString);
			dataToSend = [sendString dataUsingEncoding:NSUTF8StringEncoding];
			[serialPort sendData:dataToSend];
			break;
		case 3: //Prosistel A B C
			c = 2;
			j = (char)c;
			tmpVal = [NSString stringWithFormat:@"%c", j];
			dataToSend = [tmpVal dataUsingEncoding:NSUTF8StringEncoding];
			[self.serialPort sendData:dataToSend];
		
			tmpStr = [inputTextField stringValue];
			for (i = 0 ; i < [tmpStr length]; i++)
			{
				NSLog(@"Iteration: %d", i);
				tmpVal = [tmpStr substringWithRange:NSMakeRange(i, 1)];
				c = [tmpVal intValue];
				j = (char)c;
				tmpVal = [NSString stringWithFormat:@"%c", j];
				dataToSend = [tmpVal dataUsingEncoding:NSUTF8StringEncoding];
				[self.serialPort sendData:dataToSend];
			}
			c = 13;
			j = (char)c;
			dataToSend = [tmpVal dataUsingEncoding:NSUTF8StringEncoding];
			[self.serialPort sendData:dataToSend];
			break;
		case 4: //Prosistel CBOX/D
			//char c = 0x02; dataToSend = [NSData dataWithBytes:&c length:1]
			j = 0x02;
			dataToSend = [NSData dataWithBytes:&j length:1];
			[self.serialPort sendData:dataToSend];
			tmpStr = @"AG";
			tmpStr = [tmpStr stringByAppendingString:(hdgVal)];
			dataToSend = [tmpStr dataUsingEncoding:NSUTF8StringEncoding];
			[self.serialPort sendData:dataToSend];
			j = 0x0d;
			dataToSend = [NSData dataWithBytes:&j length:1];
			[self.serialPort sendData:dataToSend];
			break;
		case 5: //RC-2800PX
			sendString = @"A#";
			sendString = [sendString stringByAppendingString:(hdgVal)];
			sendString = [sendString stringByAppendingString:@"\r"];
			dataToSend = [sendString dataUsingEncoding:NSUTF8StringEncoding];
			[self.serialPort sendData:dataToSend];
			break;
		case 6: //SARTEK
			sendString = @"P";
			sendString = [sendString stringByAppendingString:(hdgVal)];
			sendString = [sendString stringByAppendingString:@"\r\n"];
			dataToSend = [sendString dataUsingEncoding:NSUTF8StringEncoding];
			[self.serialPort sendData:dataToSend];
			break;
		default:
			break;
	}
}

- (void)controlTextDidChange:(NSNotification *)notification
{
	// there was a change in a text control
	int tmpInt = 0;
	
	NSString *tmp = inputTextField.stringValue;
	NSString *tmp2 = inputTextField2.stringValue;

	if (tmp.length > 3)
	{
		inputTextField.stringValue = [tmp substringToIndex:tmp.length - 1];
	}
	
	if (tmp.length == 3)
	{
		tmpInt = [tmp intValue];
		if (tmpInt > 360 || tmpInt < 0)
		{
			[self showAlert:@"Heading must be between 000 and 360"];
			inputTextField.stringValue = @"";
		}
	}
	if ([[inputTextField stringValue] rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
	{
		NSLog(@"This is not a positive integer");
		inputTextField.stringValue = @"";
	}
		
	if (tmp2.length > 3)
	{
		inputTextField2.stringValue = [tmp2 substringToIndex:tmp2.length - 1];
	}
	else if (tmp2.length == 3)
	{
		int tmpInt = tmp2.intValue;
		if (tmpInt > 360 || tmpInt < 0)
		{
			//fieldCell.placeholderString = @"Heading must be between 000 and 360"; // inform user why field was blanked
			inputTextField2.stringValue = @"";
		}
	}
	else if ([tmp2 rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
	{
		//fieldCell.placeholderString = @"Enter a positive integer"; // inform user why field was blanked
		inputTextField2.stringValue = @"";
	}
	if ([tmp2 isEqualToString:@"0-1"])
	{
		inputTextField2.stringValue = @"";
	}
	NSLog(@"Field2 = %@", tmp2);
	NSLog(@"len = %lu", tmp2.length);
}

- (void)getSettings
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	// getting an NSString
	CurrentPort = [prefs stringForKey:@"portName"];
	//CurrentBaud = [prefs stringForKey:@"baudName"];
	 // getting an NSInteger
	//myInt = [prefs integerForKey:@"Port"];
	currentOnTopState = [prefs integerForKey:@"OnTopKey"];
	NSInteger r = [PreferenceController preferenceRotorTag];
	switch(r)
	{
		case 1:    //Alfaspid
			CurrentBaud = @"600";
			break;
		case 2:    //DCU
		case 3: //Prosistel A B C
			CurrentBaud = @"4800";
			break;
		case 4: //Prosistel CBOX/D
		case 5: //Prosistel CBOX/D
			CurrentBaud = @"9600";
			break;
		case 6: //SARTEK
			break;
		case 7: //Yaesu GS232
			CurrentBaud = @"9600";
			break;
		default:
			break;
	}

}

-(void)applicationWillTerminate:(NSNotification *)notification
{
	[serialPort close];
}

-(BOOL)applicationWillClose:(NSNotification *)notification
{
	return YES;
}

@end;