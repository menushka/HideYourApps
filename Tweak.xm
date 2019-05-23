@interface SBApplicationIcon : NSObject
- (NSString *)applicationBundleID;
@end

@interface SBIconIndexMutableList : NSObject
- (void)removeNodeAtIndex:(NSUInteger)index;
@end

@interface SBIconListModel : NSObject
- (void)removeIcon:(SBApplicationIcon *)icon;
- (NSUInteger)indexForIcon:(SBApplicationIcon *)icon;
@end

@interface SBIconListView : UIView
@property (nonatomic, retain) SBIconListModel *model;
- (NSArray *)icons;
- (void)removeIcon:(SBApplicationIcon *)icon;
- (void)setIconsNeedLayout;
- (void)layoutIconsNow;
- (void)hya_removeHiddenApps; // New
@end

@interface SBFolderController : UIViewController
@property (nonatomic, retain) NSArray *iconListViews;
@end

NSArray *appsToHide;

%hook SBFolderController

- (void)viewDidLoad {
	%orig;
	for(SBIconListView *listView in self.iconListViews) {
		[listView hya_removeHiddenApps];
	}
}

%end

%hook SBIconListView

%new
- (void)hya_removeHiddenApps {
	SBIconListModel *model = [self model];
	SBIconIndexMutableList *indexList = (SBIconIndexMutableList *)[model valueForKey:@"_icons"];

	NSArray *icons = [self icons];

	for(SBApplicationIcon *icon in icons) {
		if([appsToHide containsObject:[icon applicationBundleID]]) {
			NSUInteger index = [model indexForIcon:icon];
			[indexList removeNodeAtIndex:index];
			[model removeIcon:icon];
			[self removeIcon:icon];
		}
	}

	[self setIconsNeedLayout];
	[self layoutIconsNow];
}

- (void)setEditing:(BOOL)editing {
	%orig;
	[self hya_removeHiddenApps];
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