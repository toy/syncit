/*
 * ISI_MenusController.h
 *
 * iSyncIt
 * Simple Sync Software
 * 
 * Created By digital:pardoe
 * 
 */

#import <Cocoa/Cocoa.h>
#import "DPGrowl.h"
#import "ISI_Bluetooth.h"
#import "ISI_WindowController.h"
#import "ISI_Sync.h"
#import "ISI_StartupChecks.h"
#import "ISI_Scheduling.h"
#import "SS_PrefsController.h"

@interface ISI_MenusController : NSObject
{
    IBOutlet NSMenuItem *menuBT_Out_SendFile;
    IBOutlet NSMenuItem *menuBT_Out_SetUpDev;
    IBOutlet NSMenuItem *menuBT_Out_TurnOn;
    IBOutlet NSMenu *menuMM_Out;
    IBOutlet NSMenuItem *menuMM_Out_Bluetooth;
    IBOutlet NSMenuItem *menuMM_Out_LastSync;
	IBOutlet NSMenuItem *menuMM_Out_CheckUpdates;
	
	NSStatusItem *menuBarItem;
	
	NSUserDefaults *defaults;
	BOOL enableBluetooth;
	BOOL menuBarIcon;
	
	ISI_Scheduling *schedulingControl;
	ISI_Sync *syncControl;
	SS_PrefsController *prefs;
	DPGrowl *growler;
}

- (void)initialiseMenu;

- (void)changeMenu;

- (void)readMenuDefaults;

- (IBAction)menuBM_Act_SendFile:(id)sender;

- (IBAction)menuBM_Act_SetUpDev:(id)sender;

- (IBAction)menuBM_Act_TurnOn:(id)sender;

- (IBAction)menuMM_Act_ChangeLog:(id)sender;

- (IBAction)menuMM_Act_Preferences:(id)sender;

- (IBAction)menuMM_Act_SyncNow:(id)sender;

- (IBAction)menuMM_Act_AboutDialog:(id)sender;

- (IBAction)menuMM_Act_Donate:(id)sender;

@end
