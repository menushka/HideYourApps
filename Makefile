TARGET = iphone:11.2
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HideYourApps
HideYourApps_FILES = $(wildcard *.xm) $(wildcard *.m)
HideYourApps_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += hideyourappspreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
