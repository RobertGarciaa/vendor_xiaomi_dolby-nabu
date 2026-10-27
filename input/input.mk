# SPDX-License-Identifier: Apache-2.0
# Keep the original stock UI and its nabu resource overlay.
ifeq ($(wildcard frameworks/base/services/core/java/com/android/server/policy/NabuInputPolicy.java),)
$(error Nabu input requires the nabu framework patch from vendor/extraPatches branch seventeen_nabu)
endif

ifeq ($(wildcard frameworks/base/services/core/java/com/android/server/policy/NabuPenStatusMonitor.java),)
$(error Nabu pen notifications require framework patch 0007 from vendor/extraPatches)
endif

PRODUCT_SOONG_NAMESPACES += vendor/xiaomi/dolby-nabu
PRODUCT_PACKAGES += \
    NabuMiuiInputSettings \
    NabuMiuiInputSettingsOverlay \
    NabuStylusOta \
    nabu_input_control_service

PRODUCT_SYSTEM_PROPERTIES += ro.nabu.input_port=true
# Initial hardware choices; values saved in /data/property take precedence.
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.nabu.input.pen=1 \
    persist.vendor.nabu.input.pen_gen2=0 \
    persist.vendor.nabu.input.keyboard=enable_keyboard
# The tracked stock HAL needs /dev/xiaomi-touch; crDroid's kernel exposes sysfs.
# Keep it opt-in until a real HAL adapter or matching kernel ABI is supplied.
TARGET_ENABLE_NABU_STOCK_TOUCHFEATURE ?= false
ifeq ($(TARGET_ENABLE_NABU_STOCK_TOUCHFEATURE),true)
PRODUCT_PACKAGES += nabu_touchfeature_hal
PRODUCT_VENDOR_PROPERTIES += ro.vendor.touchfeature.type=43
endif
PRODUCT_COPY_FILES += \
    vendor/xiaomi/dolby-nabu/input/configs/nabu-input.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/nabu-input.rc \
    vendor/xiaomi/dolby-nabu/input/configs/default-permissions-nabu-stylus.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/default-permissions/default-permissions-nabu-stylus.xml \
    vendor/xiaomi/dolby-nabu/input/configs/shortcuts.json:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/nabu-input/shortcuts.json \
    vendor/xiaomi/dolby-nabu/input/configs/privapp-permissions-nabu-input.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-nabu-input.xml \
    vendor/xiaomi/dolby-nabu/input/configs/nabu-input-hiddenapi.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/sysconfig/nabu-input-hiddenapi.xml
