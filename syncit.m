#import <Foundation/Foundation.h>

int IOBluetoothPreferencesAvailable();
int IOBluetoothPreferenceGetControllerPowerState();
void IOBluetoothPreferenceSetControllerPowerState(int state);

#define BTPowerState IOBluetoothPreferenceGetControllerPowerState
BOOL BTSetPowerState(BOOL state) {
	IOBluetoothPreferenceSetControllerPowerState(state);

	for (int i = 0; i < 16; i++) {
		usleep(250000);
		if (state == BTPowerState()) {
			return TRUE;
		}
	}
	printf("Error: unable to turn Bluetooth %s in 4 seconds\n", state ? "on" : "off");
	return FALSE;
}

BOOL ISSync() {
	BOOL state = BTPowerState();

	if (!state) {
		if (!BTSetPowerState(TRUE)) {
			return FALSE;
		}
	}

	@try {
		NSString *syncNowScriptString =
		@"tell application \"iSync\"\r"\
			@"if synchronize then\r"\
				@"repeat while (syncing is true)\r"\
					@"delay 1\r"\
				@"end repeat\r"\
				@"quit\r"\
			@"end if\r"\
		@"end tell";
		NSAppleScript *syncNowScript = [[NSAppleScript alloc] initWithSource:syncNowScriptString];
		[syncNowScript executeAndReturnError:nil];
		[syncNowScript release];
	}
	@finally {
		if (!state) {
			if (!BTSetPowerState(FALSE)) {
				return FALSE;
			}
		}
	}

	return TRUE;
}

int main (int argc, const char *argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int result = EXIT_SUCCESS;

	if (!IOBluetoothPreferencesAvailable()) {
		fprintf(stderr, "Error: Bluetooth not available!\n");
		result = EXIT_FAILURE;
	} else {
		result = ISSync() ? EXIT_SUCCESS : EXIT_FAILURE;
	}

  [pool drain];
  return result;
}
