ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = AppSync
AppSync_FILES = Tweak.x
AppSync_CFLAGS += -fvisibility=hidden
AppSync_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
