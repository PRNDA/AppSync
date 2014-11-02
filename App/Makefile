TARGET = iphone:clang:latest:5.0
ARCHS = armv7 arm64
TARGET_CODESIGN_FLAGS="-Sentitlement.plist"

include theos/makefiles/common.mk

TOOL_NAME = appinst

appinst_FILES = appinst.m $(wildcard zipzap/zipzap/*.c) $(wildcard zipzap/zipzap/*.cpp) $(wildcard zipzap/zipzap/*.m) $(wildcard zipzap/zipzap/*.mm) misc.cpp
appinst_CFLAGS += --std=c++11 -stdlib=libc++ -fobjc-arc -include ./zipzap/zipzap/zipzap-Prefix.pch -I./zipzap/zipzap -fvisibility=hidden -Wno-unused-property-ivar -DINJECT_HACK -I../Tool
appinst_FRAMEWORKS = Foundation ImageIO CoreGraphics
appinst_PRIVATE_FRAMEWORKS = MobileCoreServices
appinst_LIBRARIES = z
appinst_INSTALL_PATH = /usr/bin

include $(THEOS_MAKE_PATH)/tool.mk

VERSION.INC_BUILD_NUMBER = 1
