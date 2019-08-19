#import <Cephei/HBPreferences.h>

@interface SBApplicationIcon : NSObject
- (NSString *)applicationBundleID;
@end

BOOL prefEnabled;
NSMutableDictionary *prefAppsToHide;

%group HideYourAppsEnabled

%hook SBIconListModel

BOOL checkIfHide(NSString *appID) {
	id value = [prefAppsToHide objectForKey:appID];
	if (value) {
		return [value boolValue];
	} else {
		return NO;
	}
}

- (id)placeIcon:(SBApplicationIcon *)icon atIndex:(unsigned long long*)arg2 {
	if (!checkIfHide([icon applicationBundleID])) {
		return %orig;
	}
	return nil;
}

- (id)insertIcon:(SBApplicationIcon *)icon atIndex:(unsigned long long*)arg2 options:(unsigned long long)arg3 {
	if (!checkIfHide([icon applicationBundleID])) {
		return %orig;
	}
	return nil;
}

- (BOOL)addIcon:(SBApplicationIcon *)icon asDirty:(BOOL)arg2 {
	if (!checkIfHide([icon applicationBundleID])) {
		return %orig;
	}
	return NO;
}

%end

%end

void loadPrefs() {
	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:@"ca.menushka.hideyourapps.preferences.settings"];

	prefEnabled = [prefs boolForKey:@"enabled" default:YES];
	prefAppsToHide = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/ca.menushka.hideyourapps.preferences.plist"];
}

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("ca.menushka.hideyourapps.preferences/ReloadPrefs"), NULL, kNilOptions);

	if (prefEnabled) {
		%init(HideYourAppsEnabled);
	}
}