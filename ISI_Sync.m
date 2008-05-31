/*
 * ISI_Sync.m
 *
 * iSyncIt
 * Simple Sync Software
 * 
 * Created By digital:pardoe
 * 
 */

#import "ISI_Sync.h"

@implementation ISI_Sync

- (void)startSync : (BOOL)defaultsValue growl : (DPGrowl*)theGrowl
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSDate date] forKey:@"ISI_LastSync"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// Stores the current status of the bluetooth power.
	char *currentStatus[3];
	
	// Assuming bluetooth is available and the user wishes it turn the power on (if needed).
	if (IOBluetoothPreferencesAvailable()) {
		if (defaultsValue == TRUE) {
			currentStatus[3] = BTPowerState() ? "on" : "off";
			if (currentStatus[3] == "off") {
				BTSetPowerState(1);
			}
		}
	}
	
	// Perform the sync by writing in an AppleScript and excecuting.
	NSString *syncNowString = @"tell application \"iSync\"\r if not (synchronize) then\r else\r repeat while (syncing is true)\r delay 5\r end repeat\r quit\r end if\r end tell";
	NSAppleScript *syncNowScript = [[NSAppleScript alloc] initWithSource:syncNowString];
	[syncNowScript executeAndReturnError:nil];
	
	// Assuming bluetooth is available reset it's state to the original.
	if (IOBluetoothPreferencesAvailable()) {
		if (defaultsValue == TRUE) {
			if (currentStatus[3] == "off") {
				BTSetPowerState(0);
			}
		}
	}
	
	if (theGrowl != nil)
	{
		[theGrowl showGrowlNotification : @"3" : @"Sync Complete" : @"Synchronization of your devices has been completed."];
	}
	
	[syncNowString release];
	[syncNowScript release];
}

@end