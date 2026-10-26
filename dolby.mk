# SPDX-License-Identifier: Apache-2.0
# Xiaomi Pad 5 stock Dolby Atmos; install this repository at vendor/xiaomi/dolby-nabu.
PRODUCT_SOONG_NAMESPACES += vendor/xiaomi/dolby-nabu

PRODUCT_PACKAGES += \
    libdapparamstorage \
    libdlbdsservice \
    libsf_dolby_nabu \
    libhwdap \
    vendor.dolby.hardware.dms@2.0 \
    vendor.dolby.hardware.dms@2.0-impl \
    vendor.dolby.hardware.dms@2.0-service \
    dolby-dax-default.xml \
    vendor.dolby.hardware.dms@2.0-service.rc \
    DolbyControl \
    MiSound

PRODUCT_COPY_FILES += \
    vendor/xiaomi/dolby-nabu/configs/audio/audio_effects_dolby.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    vendor/xiaomi/dolby-nabu/configs/permissions/privapp-permissions-dolby-nabu.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-dolby-nabu.xml \
    vendor/xiaomi/dolby-nabu/proprietary/vendor/lib/rfsa/adsp/capi_v2_dap_cpdp.so:$(TARGET_COPY_OUT_VENDOR)/lib/rfsa/adsp/capi_v2_dap_cpdp.so

# Match stock; DAP is loaded by the effects HAL, not Qualcomm's legacy DS2 path.
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.audio.dolby.dax.support=true \
    vendor.audio.dolby.ds2.enabled=false \
    vendor.audio.dolby.ds2.hardbypass=false
