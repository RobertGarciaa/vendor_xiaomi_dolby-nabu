# SPDX-License-Identifier: Apache-2.0
# Keep the original stock UI and its nabu resource overlay.
ifeq ($(wildcard frameworks/base/services/core/java/com/android/server/policy/NabuInputPolicy.java),)
$(error Nabu input requires tools/apply-platform-patches.py --android-root before lunch/build)
endif

PRODUCT_SOONG_NAMESPACES += vendor/xiaomi/dolby-nabu
PRODUCT_PACKAGES += \
    NabuMiuiInputSettings \
    NabuMiuiInputSettingsOverlay \
    NabuStylusOta \
    nabu_touchfeature_hal

PRODUCT_SYSTEM_PROPERTIES += ro.nabu.input_port=true
PRODUCT_VENDOR_PROPERTIES += ro.vendor.touchfeature.type=43
PRODUCT_COPY_FILES += \
    vendor/xiaomi/dolby-nabu/input/configs/default-permissions-nabu-stylus.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/default-permissions/default-permissions-nabu-stylus.xml \
    vendor/xiaomi/dolby-nabu/input/configs/shortcuts.json:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/nabu-input/shortcuts.json \
    vendor/xiaomi/dolby-nabu/input/configs/privapp-permissions-nabu-input.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-nabu-input.xml \
    vendor/xiaomi/dolby-nabu/input/configs/nabu-input-hiddenapi.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/sysconfig/nabu-input-hiddenapi.xml
