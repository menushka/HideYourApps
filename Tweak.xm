@interface SBApplicationIcon : NSObject
- (NSString *)applicationBundleID;
@end

NSArray *appsToHide;

%hook SBIconListModel

- (id)placeIcon:(SBApplicationIcon *)icon atIndex:(unsigned long long*)arg2 {
	if(![appsToHide containsObject:[icon applicationBundleID]]) {
		return %orig;
	}
	return nil;
}

- (id)insertIcon:(SBApplicationIcon *)icon atIndex:(unsigned long long*)arg2 options:(unsigned long long)arg3 {
	if(![appsToHide containsObject:[icon applicationBundleID]]) {
		return %orig;
	}
	return nil;
}

- (BOOL)addIcon:(SBApplicationIcon *)icon asDirty:(BOOL)arg2 {
	if(![appsToHide containsObject:[icon applicationBundleID]]) {
		return %orig;
	}
	return NO;
}

%end


void loadPrefs() {
	NSMutableDictionary *appList = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/ca.menushka.hideyourapps.preferences.plist"];
    NSMutableArray *_appsToHide = [[NSMutableArray alloc] init];
    for (NSString *key in appList) {
        if ([[appList objectForKey:key] boolValue]) {
            [_appsToHide addObject:key];
        }
    }

    appsToHide = [_appsToHide copy];
}

%ctor {
	@autoreleasepool {
		loadPrefs();
	}
}