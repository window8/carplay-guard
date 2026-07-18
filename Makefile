TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = SpringBoard
PACKAGE_VERSION = 1.0.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CarPlayGuard
CarPlayGuard_FILES = Tweak.x
CarPlayGuard_CFLAGS = -fobjc-arc
CarPlayGuard_FRAMEWORKS = Foundation AVFoundation MediaPlayer UIKit CoreTelephony

include $(THEOS_MAKE_PATH)/tweak.mk
