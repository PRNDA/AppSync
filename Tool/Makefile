# AppSync for iOS
# Copyright (c) 2014 Linus Yang

ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TOOL_NAME = postinst prerm

postinst_FILES = postinst.c misc.c
postinst_CFLAGS += -fvisibility=hidden -DBUILD_POSTINST -DBUILD_RUNONCE
postinst_FRAMEWORKS = CoreFoundation
postinst_INSTALL_PATH = /DEBIAN

appsync_FILES = postinst.c misc.c
appsync_CFLAGS += -fvisibility=hidden -DBUILD_POSTINST -DINJECT_HACK
appsync_FRAMEWORKS = CoreFoundation
appsync_INSTALL_PATH = /usr/bin

prerm_FILES = postinst.c
prerm_CFLAGS += -fvisibility=hidden
prerm_FRAMEWORKS = CoreFoundation
prerm_INSTALL_PATH = /DEBIAN

include $(THEOS_MAKE_PATH)/tool.mk
