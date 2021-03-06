################################################################################
#
# swupdate-custom
#
################################################################################

SWUPDATE_CUSTOM_VERSION = master
SWUPDATE_CUSTOM_SITE = git://github.com/sbabic/swupdate.git 
SWUPDATE_CUSTOM_LICENSE = GPLv2+, MIT, Public Domain
SWUPDATE_CUSTOM_LICENSE_FILES = COPYING

# Upstream patch to fix build without MTD support
#SWUPDATE_CUSTOM_PATCH = https://github.com/sbabic/swupdate/commit/69c0e66994f01ce1bf2299fbce86aee7a1baa37b.patch \


# swupdate-custom bundles its own version of mongoose (version 3.8)

ifeq ($(BR2_PACKAGE_JSON_C),y)
SWUPDATE_CUSTOM_DEPENDENCIES += json-c
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_JSON_C=y
else
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_JSON_C=n
endif

ifeq ($(BR2_PACKAGE_LIBARCHIVE),y)
SWUPDATE_CUSTOM_DEPENDENCIES += libarchive
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBARCHIVE=y
else
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBARCHIVE=n
endif

ifeq ($(BR2_PACKAGE_LIBCONFIG),y)
SWUPDATE_CUSTOM_DEPENDENCIES += libconfig
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBCONFIG=y
else
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBCONFIG=n
endif

ifeq ($(BR2_PACKAGE_LIBCURL),y)
SWUPDATE_CUSTOM_DEPENDENCIES += libcurl
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBCURL=y
else
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBCURL=n
endif

ifeq ($(BR2_PACKAGE_LUA),y)
SWUPDATE_CUSTOM_DEPENDENCIES += lua host-pkgconf
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LUA=y
else
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LUA=n
endif

ifeq ($(BR2_PACKAGE_MTD),y)
SWUPDATE_CUSTOM_DEPENDENCIES += mtd
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBMTD=y
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBUBI=y
else
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBMTD=n
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBUBI=n
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
SWUPDATE_CUSTOM_DEPENDENCIES += openssl
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBSSL=y
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBCRYPTO=y
else
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBSSL=n
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBCRYPTO=n
endif

ifeq ($(BR2_PACKAGE_UBOOT_TOOLS),y)
SWUPDATE_CUSTOM_DEPENDENCIES += uboot-tools
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBUBOOTENV=y
else
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_LIBUBOOTENV=n
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
SWUPDATE_CUSTOM_DEPENDENCIES += zlib
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_ZLIB=y
else
SWUPDATE_CUSTOM_MAKE_ENV += HAVE_ZLIB=n
endif

SWUPDATE_CUSTOM_BUILD_CONFIG = $(@D)/.config

SWUPDATE_CUSTOM_KCONFIG_FILE = $(call qstrip,$(BR2_PACKAGE_SWUPDATE_CUSTOM_CONFIG))
SWUPDATE_CUSTOM_KCONFIG_EDITORS = menuconfig xconfig gconfig nconfig

ifeq ($(BR2_PREFER_STATIC_LIB),y)
define SWUPDATE_CUSTOM_PREFER_STATIC
	$(call KCONFIG_ENABLE_OPT,CONFIG_STATIC,$(SWUPDATE_CUSTOM_BUILD_CONFIG))
endef
endif

define SWUPDATE_CUSTOM_SET_BUILD_OPTIONS
	$(call KCONFIG_SET_OPT,CONFIG_CROSS_COMPILE,"$(TARGET_CROSS)", \
		$(SWUPDATE_CUSTOM_BUILD_CONFIG))
	$(call KCONFIG_SET_OPT,CONFIG_SYSROOT,"$(STAGING_DIR)", \
		$(SWUPDATE_CUSTOM_BUILD_CONFIG))
	$(call KCONFIG_SET_OPT,CONFIG_EXTRA_CFLAGS,"$(TARGET_CFLAGS)", \
		$(SWUPDATE_CUSTOM_BUILD_CONFIG))
	$(call KCONFIG_SET_OPT,CONFIG_EXTRA_LDFLAGS,"$(TARGET_LDFLAGS)", \
		$(SWUPDATE_CUSTOM_BUILD_CONFIG))
endef

define SWUPDATE_CUSTOM_KCONFIG_FIXUP_CMDS
	$(SWUPDATE_CUSTOM_PREFER_STATIC)
	$(SWUPDATE_CUSTOM_SET_BUILD_OPTIONS)
endef

define SWUPDATE_CUSTOM_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(SWUPDATE_CUSTOM_MAKE_ENV) $(MAKE) -C $(@D)
endef

define SWUPDATE_CUSTOM_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/swupdate $(TARGET_DIR)/usr/bin/swupdate
	$(if $(BR2_PACKAGE_SWUPDATE_CUSTOM_INSTALL_WEBSITE), \
		mkdir -p $(TARGET_DIR)/var/www/swupdate; \
		cp -dpf $(@D)/www/* $(TARGET_DIR)/var/www/swupdate)
endef

# Checks to give errors that the user can understand
# Must be before we call to kconfig-package
ifeq ($(BR2_PACKAGE_SWUPDATE_CUSTOM)$(BR_BUILDING),yy)
ifeq ($(call qstrip,$(BR2_PACKAGE_SWUPDATE_CUSTOM_CONFIG)),)
$(error No Swupdate configuration file specified, check your BR2_PACKAGE_SWUPDATE_CUSTOM_CONFIG setting)
endif
endif
$(eval $(kconfig-package))
