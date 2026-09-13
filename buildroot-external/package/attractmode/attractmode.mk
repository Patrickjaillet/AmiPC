ATTRACTMODE_VERSION = v2.6.1
ATTRACTMODE_SITE = $(call github,mickelson,attract,$(ATTRACTMODE_VERSION))
ATTRACTMODE_LICENSE = GPL-3.0
ATTRACTMODE_LICENSE_FILES = COPYING
ATTRACTMODE_DEPENDENCIES = sdl2 sfml fontconfig zlib jpeg expat freetype

define ATTRACTMODE_BUILD_CMDS
	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig" \
	PKG_CONFIG_LIBDIR="$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig" \
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) \
		CC="$(TARGET_CC)" CXX="$(TARGET_CXX)" \
		PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
		STATIC=0
endef

define ATTRACTMODE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/attract $(TARGET_DIR)/usr/bin/attract
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/attract
	cp -a $(@D)/config/* $(TARGET_DIR)/usr/share/attract/ 2>/dev/null || true
endef

$(eval $(generic-package))
