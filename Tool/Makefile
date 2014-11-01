ARCHS = armv7 arm64

include theos/makefiles/common.mk

TOOL_NAME = postinst prerm appsync

postinst_FILES = postinst.c
postinst_CFLAGS += -fvisibility=hidden -DBUILD_POSTINST
postinst_FRAMEWORKS = CoreFoundation
postinst_INSTALL_PATH = /DEBIAN

appsync_FILES = postinst.c
appsync_CFLAGS += -fvisibility=hidden -DBUILD_POSTINST
appsync_FRAMEWORKS = CoreFoundation
appsync_INSTALL_PATH = /usr/bin

prerm_FILES = postinst.c
prerm_CFLAGS += -fvisibility=hidden
prerm_FRAMEWORKS = CoreFoundation
prerm_INSTALL_PATH = /DEBIAN

include $(THEOS_MAKE_PATH)/tool.mk
