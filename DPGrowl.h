//
//  DPGrowl.h
//  iSyncIt
//
//  Created by Alex on 31/05/2008.
//  Copyright 2008 digital:pardoe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@interface DPGrowl : NSObject <GrowlApplicationBridgeDelegate>
{
	BOOL growlReady;
}

- (void)initializeGrowl : (int)noMessages;

- (void)showGrowlNotification : (NSString *)growlName : (NSString *)growlTitle : (NSString *)gowlDescription;

@end