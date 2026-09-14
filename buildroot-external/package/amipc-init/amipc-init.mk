AMIPC_INIT_VERSION = 1.0
AMIPC_INIT_SITE_METHOD = local
AMIPC_INIT_SITE = $(BR2_EXTERNAL_AMIPC_PATH)/package/amipc-init/files

define AMIPC_INIT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(AMIPC_INIT_SITE)/amipc-start.sh $(TARGET_DIR)/usr/bin/amipc-start
	$(INSTALL) -D -m 0755 $(AMIPC_INIT_SITE)/amipc-usb-mount.sh $(TARGET_DIR)/usr/bin/amipc-usb-mount.sh
	$(INSTALL) -D -m 0755 $(AMIPC_INIT_SITE)/amipc-update.sh $(TARGET_DIR)/usr/bin/amipc-update
	$(INSTALL) -D -m 0755 $(AMIPC_INIT_SITE)/amipc-set-langue.sh $(TARGET_DIR)/usr/bin/amipc-set-langue
	$(INSTALL) -D -m 0755 $(AMIPC_INIT_SITE)/amipc-set-luminosite.sh $(TARGET_DIR)/usr/bin/amipc-set-luminosite
	$(INSTALL) -D -m 0755 $(AMIPC_INIT_SITE)/amipc-set-reseau.sh $(TARGET_DIR)/usr/bin/amipc-set-reseau
	$(INSTALL) -D -m 0755 $(AMIPC_INIT_SITE)/amipc-set-shader.sh $(TARGET_DIR)/usr/bin/amipc-set-shader
	$(INSTALL) -D -m 0755 $(AMIPC_INIT_SITE)/amipc-detecter-langue.sh $(TARGET_DIR)/usr/bin/amipc-detecter-langue
	$(INSTALL) -D -m 0755 $(AMIPC_INIT_SITE)/amipc-verifier-bios.sh $(TARGET_DIR)/usr/bin/amipc-verifier-bios
	$(INSTALL) -D -m 0755 $(AMIPC_INIT_SITE)/amipc-verifier-reseau.sh $(TARGET_DIR)/usr/bin/amipc-verifier-reseau
	$(INSTALL) -D -m 0644 $(AMIPC_INIT_SITE)/amipc-bios-reference.txt $(TARGET_DIR)/etc/amipc/bios-reference.txt
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/etc/amipc
	$(INSTALL) -D -m 0644 $(AMIPC_INIT_SITE)/amipc.conf $(TARGET_DIR)/etc/amipc/amipc.conf
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/data/retroarch
	cp -a $(BR2_EXTERNAL_AMIPC_PATH)/../config/retroarch/. $(TARGET_DIR)/data/retroarch/
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/data/attract
	cp -a $(BR2_EXTERNAL_AMIPC_PATH)/../config/attract/. $(TARGET_DIR)/data/attract/
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/attract/layouts/amipc
	cp -a $(BR2_EXTERNAL_AMIPC_PATH)/../themes/amipc/. $(TARGET_DIR)/usr/share/attract/layouts/amipc/
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/data/i18n
	cp -a $(BR2_EXTERNAL_AMIPC_PATH)/../i18n/. $(TARGET_DIR)/data/i18n/
	$(INSTALL) -D -m 0644 $(BR2_EXTERNAL_AMIPC_PATH)/../VERSION $(TARGET_DIR)/etc/amipc/VERSION
endef

$(eval $(generic-package))
