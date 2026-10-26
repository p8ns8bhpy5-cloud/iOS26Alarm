export TARGET = iphone:clang:17.0:17.0
export ARCHS = arm64 arm64e
export THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iOS26Alarm
iOS26Alarm_FILES = Hooks/iOS26Alarm.xm
iOS26Alarm_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
