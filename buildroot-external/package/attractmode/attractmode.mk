ATTRACTMODE_VERSION = v2.6.1
ATTRACTMODE_SITE = $(call github,mickelson,attract,$(ATTRACTMODE_VERSION))
ATTRACTMODE_LICENSE = GPL-3.0
ATTRACTMODE_LICENSE_FILES = COPYING
ATTRACTMODE_DEPENDENCIES = sdl2 sdl2_image sdl2_ttf fontconfig zlib jpeg

define ATTRACTMODE_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) \
		CC="$(TARGET_CC)" CXX="$(TARGET_CXX)" \
		STATIC=0
endef

define ATTRACTMODE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/attract $(TARGET_DIR)/usr/bin/attract
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/attract
	cp -a $(@D)/config/* $(TARGET_DIR)/usr/share/attract/ 2>/dev/null || true
endef

$(eval $(generic-package))
