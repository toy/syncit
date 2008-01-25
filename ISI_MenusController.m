/*
 * ISI_MenusController.m
 *
 * iSyncIt
 * Simple Sync Software
 * 
 * Created By digital:pardoe
 * 
 */

#import "ISI_MenusController.h"

@implementation ISI_MenusController

/*
 * Growl Control Code
 * Seperated for ease of access during current development.
 *
 */
 
 
 - (void) initializeGrowl
{
	growlReady = YES;
	
	// Tells the Growl framework that this class will receive callbacks
	[GrowlApplicationBridge setGrowlDelegate:self];
	[self registrationDictionaryForGrowl];
}

- (NSDictionary*) registrationDictionaryForGrowl
{
	// For this application, only one notification is registered
	NSArray* defaultNotifications = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
	NSArray* allNotifications = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
	
	NSDictionary* growlRegistration = [NSDictionary dictionaryWithObjectsAndKeys: 
		defaultNotifications, GROWL_NOTIFICATIONS_DEFAULT,
		allNotifications, GROWL_NOTIFICATIONS_ALL, nil];
	
	return growlRegistration;
}

- (void) growlIsReady
{
	// Only get called when Growl is starting. Not called when Growl is already running so we leave growlReady to YES by default...
	growlReady = YES;
}

- (NSString *) applicationNameForGrowl
{
	return [NSString stringWithFormat:@"iSyncIt"];
}

- (void)showGrowlNotification : (NSString *)growlName : (NSString *)growlTitle : (NSString *)growlDescription
{
	if (!growlReady)
	{
		return;
	}

	// Don't forget to create relevant localizations for the Growl alerts.
	[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:NSLocalizedString(growlTitle, nil)]
								description:[NSString stringWithFormat:NSLocalizedString(growlDescription, nil)]
								notificationName:growlName
								iconData:nil
								priority:nil
								isSticky:nil
								clickContext:nil ];
}
 
 /*
  * End Growl Control Code
  *
  */

- (void)awakeFromNib
{
	// Pull to front, mainly for first runs.
	[NSApp activateIgnoringOtherApps:YES];
	
	// First run, start-up checks.
	startupChecks();
	
	// Load the user preferences file into memory.
	defaults = [NSUserDefaults standardUserDefaults];
	
	[self readMenuDefaults];
	
	[self initialiseMenu];
	
	[self initializeGrowl];

	// Read the bluetooth settings from user defaults.
	enableBluetooth = [defaults boolForKey:@"ISI_EnableBluetooth"];
	
	// Start the scheduler.
	schedulingControl = [[ISI_Scheduling alloc] init];
	[schedulingControl goSchedule];
}

- (void)initialiseMenu
{
	// Fill the menu bar item.
    menuBarItem = [[[NSStatusBar systemStatusBar]
            statusItemWithLength:NSSquareStatusItemLength] retain];
	
	// Set up the menu bar item & fill it.
    [menuBarItem setHighlightMode:YES];
	
	[self changeMenu];
	
	/* 
	 * To set the status bar item as text use:
	 *		[statusItem setTitle:[NSString stringWithFormat:@"%C",0x27B2]];
	 * instead of setImage.
	 *
	 */
	
	// Initialise the menu bar so the user can operate the program.
    [menuBarItem setMenu:menuMM_Out];
    [menuBarItem setEnabled:YES];
}

- (void)readMenuDefaults
{
	// Read the icon settings from user defaults.
	menuBarIcon = [defaults boolForKey:@"ISI_AlternateMenuBarItem"];
}

- (void)changeMenu
{
	if (menuBarIcon == TRUE) {
		if ((BTPowerState() ? "on" : "off") == "off") {
			[menuBarItem setImage:[NSImage imageNamed:@"ISI_MenuIconAlternate"]];
		} else {
			[menuBarItem setImage:[NSImage imageNamed:@"ISI_MenuIconAlternate_On"]]; 
		}
	} else {
		if ((BTPowerState() ? "on" : "off") == "off") {
			[menuBarItem setImage:[NSImage imageNamed:@"ISI_MenuIcon"]];
		} else {
			 [menuBarItem setImage:[NSImage imageNamed:@"ISI_MenuIcon_On"]];
		}
	}
	
	NSString *tempString = [@"" stringByAppendingString:[[defaults objectForKey:@"ISI_LastSync"] descriptionWithCalendarFormat:@"%a %d %b, %H:%M" timeZone:[NSTimeZone systemTimeZone] locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
	[menuMM_Out_LastSync setTitle:[[[@"" stringByAppendingString:NSLocalizedString(@"Last Sync", nil)] stringByAppendingString:@": "] stringByAppendingString:tempString]];
}

- (IBAction)menuBM_Act_SendFile:(id)sender
{
	// Opens the bluetooth file exchange.
	NSString *sendFilesString = @"tell application \"Bluetooth File Exchange\"\r activate\r end tell";
	NSAppleScript *sendFilesScript = [[NSAppleScript alloc] initWithSource:sendFilesString];
	[sendFilesScript executeAndReturnError:nil];
}

- (IBAction)menuBM_Act_SetUpDev:(id)sender
{
	// Open the bluetooth setup assistant.
	NSString *setDeviceString = @"tell application \"Bluetooth Setup Assistant\"\r activate\r end tell";
	NSAppleScript *setDeviceScript = [[NSAppleScript alloc] initWithSource:setDeviceString];
	[setDeviceScript executeAndReturnError:nil];
}

- (IBAction)menuBM_Act_TurnOn:(id)sender
{
	// Sets the power state to on or off depending on which one is already set.
	if (IOBluetoothPreferencesAvailable()) {
		if ((BTPowerState() ? "on" : "off") == "on") {
			BTSetPowerState(0);
			[self showGrowlNotification : @"2" : @"Bluetooth Off" : @"Your bluetooth hardware has been turned off."];
		} else {
			BTSetPowerState(1);
			[self showGrowlNotification : @"1" : @"Bluetooth On" : @"Your bluetooth hardware has been turned on."];
		}
	}
			
	[self changeMenu];
}

- (IBAction)menuMM_Act_ChangeLog:(id)sender
{
	// Makes sure the app is frontmost and displays the Change Log.
	[NSApp activateIgnoringOtherApps:YES];
	ISI_WindowController *changeLogWindow = [[ISI_WindowController alloc] initWithWindowNibName:@"ISI_ChangeLog"];
	[changeLogWindow showWindow:self];
}

- (IBAction)menuMM_Act_Preferences:(id)sender
{
	// Makes sure the app is frontmost and displays the Preferences.
	[NSApp activateIgnoringOtherApps:YES];
	ISI_WindowController *prefWindow = [[ISI_WindowController alloc] initWithWindowNibName:@"ISI_Preferences"];
	[prefWindow showWindow:self];
}

- (IBAction)menuMM_Act_SyncNow:(id)sender
{
	syncControl = [[ISI_Sync alloc] init];
	[syncControl startSync : enableBluetooth];
	// [self showGrowlNotification : @"3" : @"Sync Complete" : @"Synchronization of your devices has been completed."];
}

- (IBAction)menuMM_Act_AboutDialog:(id)sender
{
	// Makes sure the app is frontmost and displays the About dialog.
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:(id)sender];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{    
	// Deactivates the bluetooth menu if bluetooth is not available.
	if (!IOBluetoothPreferencesAvailable()) {
		if (menuItem == menuMM_Out_Bluetooth) {
			return NO;
		}
	}
	
	// Runs is bluetooth is available.
	if (IOBluetoothPreferencesAvailable()) {
		
		// Activates the necessary menu items that will always remain active with bluetooth.
		if (menuItem == menuMM_Out_Bluetooth) {
			return YES;
		}
		if (menuItem == menuBT_Out_TurnOn) {
			return YES;
		}
		
		// Enables the menu items and sets the bluetooth control menu item title if the bluetooth is turned on.
		if ((BTPowerState() ? "on" : "off") == "on") {
			[menuBT_Out_TurnOn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Turn Off", nil)]];
			if (menuItem == menuBT_Out_SendFile) {
				return YES;
			}
			if (menuItem == menuBT_Out_SetUpDev) {
				return YES;
			}
		}
		
		// Disables the menu items and sets the bluetooth control menu item title if the bluetooth is turned off.
		if ((BTPowerState() ? "on" : "off") == "off") {
			[menuBT_Out_TurnOn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Turn On", nil)]];
			if (menuItem == menuBT_Out_SendFile) {
				return NO;
			}
			if (menuItem == menuBT_Out_SetUpDev) {
				return NO;
			}
		}
	}
}

- (IBAction)menuMM_Act_Donate:(id)sender
{
	// Forces the user into donation.
	NSNumber *donateChecking = [[NSUserDefaults standardUserDefaults] objectForKey:@"ISI_Donation"];
	[NSApp activateIgnoringOtherApps:YES];
	donateChecking = [NSNumber numberWithBool:NSRunAlertPanel(NSLocalizedString(@"Making a donation.", nil), [NSString stringWithFormat:NSLocalizedString(@"Please make a donation by clicking the button on the right hand side of the website.", nil)], NSLocalizedString(@"Donate", nil), nil, nil) == NSAlertDefaultReturn];
	if (donateChecking) {
		[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://digitalpardoe.co.uk/"]];
	}
}


- (void)dealloc
{
	// De-allocate the necessary resources.
	[menuBT_Out_SendFile release];
    [menuBT_Out_SetUpDev release];
    [menuBT_Out_TurnOn release];
    [menuMM_Out release];
    [menuMM_Out_Bluetooth release];
    [menuMM_Out_LastSync release];
	[menuMM_Out release];
	[menuBarItem release];
	[schedulingControl release];
	[syncControl release];
	[defaults release];
	[super dealloc];
}

@end
