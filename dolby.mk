# SPDX-License-Identifier: Apache-2.0
# Xiaomi Pad 5 stock Dolby Atmos; install this repository at vendor/xiaomi/dolby-nabu.
PRODUCT_SOONG_NAMESPACES += vendor/xiaomi/dolby-nabu

# The stock libqtigef builds its GEF HAL path from the literal "msmnile". nabu
# installs its one stock HAL as audio.primary.nabu.so, so the unpatched library
# could not find it and GEF returned -38. Ship a nabu-specific copy whose lookup
# string is retargeted instead of adding an audio.primary.msmnile.so symlink,
# which would collide with the qcom-caf source HAL at the same install path.
#
# libqtigef_nabu installs as /vendor/lib/libqtigef.so. sm8150-common-vendor.mk
# leaves the shared libqtigef out when TARGET_ENABLE_XIAOMI_DOLBY is true, so
# the corresponding Soong modules must also be mutually exclusive.
# Merely omitting a module from PRODUCT_PACKAGES does not remove its install rule.
$(call soong_config_set_bool,nabu_dolby,replace_qtigef,true)
PRODUCT_PACKAGES += libqtigef_nabu

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
    MiSound \
    nabu_dolby_capi_v2_dap_cpdp

PRODUCT_COPY_FILES += \
    vendor/xiaomi/dolby-nabu/configs/audio/audio_effects_dolby.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    vendor/xiaomi/dolby-nabu/configs/permissions/privapp-permissions-dolby-nabu.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-dolby-nabu.xml

# Match stock; DAP is loaded by the effects HAL, not Qualcomm's legacy DS2 path.
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.audio.dolby.dax.support=true \
    vendor.audio.dolby.ds2.enabled=false \
    vendor.audio.dolby.ds2.hardbypass=false
