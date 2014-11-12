# AppSync for iOS
# Copyright (c) 2014 Linus Yang

TARGET = iphone:clang:latest:5.0

SUBPROJECTS = Tweak Tool

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

VERSION.INC_BUILD_NUMBER = 1

stage::
	find "$(THEOS_STAGING_DIR)" -type f \( -iname "*.strings" -o -iname "*.plist" \) -exec plutil -convert binary1 {} \;
