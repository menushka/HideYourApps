@interface SBApplicationIcon : NSObject
- (id) applicationBundleID;
@end

@interface SBIconIndexMutableList
-(id)nodes;
@end

NSArray *appsToHide;

%hook SBIconIndexMutableList

-(void)addNode:(id)arg1 {
	if ([arg1 isMemberOfClass: NSClassFromString(@"SBApplicationIcon")]) {
		if ([appsToHide containsObject: [arg1 applicationBundleID]]) {
			return;	
		}
	} 
	%log;
	%orig;
}

-(void)insertNode:(id)arg1 atIndex:(unsigned long long)arg2 {
	if ([arg1 isMemberOfClass: NSClassFromString(@"SBApplicationIcon")]) {
		if ([appsToHide containsObject: [arg1 applicationBundleID]]) {
			return;	
		}
	}
	%log;
	%orig;
}

-(void)replaceNodeAtIndex:(unsigned long long)arg1 withNode:(id)arg2 {
	if ([arg2 isMemberOfClass: NSClassFromString(@"SBApplicationIcon")]) {
		if ([appsToHide containsObject: [arg2 applicationBundleID]]) {
			return;	
		}
	}
	%log;
	%orig;
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