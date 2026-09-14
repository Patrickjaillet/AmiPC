ATTRACTMODE_VERSION = v2.6.1
ATTRACTMODE_SITE = $(call github,mickelson,attract,$(ATTRACTMODE_VERSION))
ATTRACTMODE_LICENSE = GPL-3.0
ATTRACTMODE_LICENSE_FILES = COPYING
ATTRACTMODE_DEPENDENCIES = sdl2 sfml fontconfig zlib jpeg expat freetype

define ATTRACTMODE_BUILD_CMDS
	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig" \
	PKG_CONFIG_LIBDIR="$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig" \
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	$(MAKE) -C $(@D) \
		PATH="$(BR_PATH)" \
		AR="$(TARGET_AR)" \
		AS="$(TARGET_AS)" \
		LD="$(TARGET_LD)" \
		CC="$(TARGET_CC)" \
		CXX="$(TARGET_CXX)" \
		RANLIB="$(TARGET_RANLIB)" \
		STRIP="$(TARGET_STRIP)" \
		PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
		STATIC=0 \
		NO_MOVIE=1 \
		NO_SWF=1 \
		USE_GLES=1 \
		USE_DRM=1
endef

define ATTRACTMODE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/attract $(TARGET_DIR)/usr/bin/attract
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/attract
	cp -a $(@D)/config/* $(TARGET_DIR)/usr/share/attract/ 2>/dev/null || true
endef

$(eval $(generic-package))
