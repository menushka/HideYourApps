@interface SBApplicationIcon : NSObject
- (id) applicationBundleID;
@end

@interface SBIconListView : UIView
@end

@interface SBRootIconListView : SBIconListView
@end

@interface SBIconListModel : NSObject
@property (nonatomic, retain) NSString *similarityHash;
@property (nonatomic, retain) NSArray *cachedIcons;
- (NSString *) generateHash:(NSArray<SBApplicationIcon *> *) icons;
- (void)cacheIcons:(NSArray<SBApplicationIcon *> *) icons result:(NSArray *) appsToHide;
@end

NSArray *appsToHide;

%hook SBIconListModel

%property (nonatomic, retain) NSString *similarityHash;
%property (nonatomic, retain) NSArray *cachedIcons;

- (id)icons {
	NSArray<SBApplicationIcon *> *icons = %orig;

	if ([[self generateHash: icons] isEqualToString: self.similarityHash]) return self.cachedIcons;

	NSMutableArray *newIcons = [NSMutableArray arrayWithCapacity:[icons count]];
	for (int i = 0; i < [icons count]; i++) {
		if (![appsToHide containsObject: [icons[i] applicationBundleID]]) {
			[newIcons addObject: icons[i]];
		}
	}
	NSLog(@"HideYourApps: icons - %@", self);
	NSArray *result = [newIcons copy];

	[self cacheIcons: icons result: result];

	return result;
}

%new
- (NSString *)generateHash:(NSArray<SBApplicationIcon *> *) icons {
	return [[icons valueForKey:@"applicationBundleID"] componentsJoinedByString:@""];
}

%new
- (void)cacheIcons:(NSArray<SBApplicationIcon *> *) icons result:(NSArray *) result {
	self.similarityHash = [self generateHash: icons];
	self.cachedIcons = result;
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