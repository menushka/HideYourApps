TARGET = iphone:11.2
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = HideYourAppsPreferences
HideYourAppsPreferences_FILES = HYAPRootListController.m
HideYourAppsPreferences_INSTALL_PATH = /Library/PreferenceBundles
HideYourAppsPreferences_FRAMEWORKS = UIKit
HideYourAppsPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/HideYourAppsPreferences.plist$(ECHO_END)
