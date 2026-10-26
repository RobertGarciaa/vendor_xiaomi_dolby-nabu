# SPDX-License-Identifier: Apache-2.0
AUDIO_FEATURE_ENABLED_DS2_DOLBY_DAP := false
BOARD_VENDOR_SEPOLICY_DIRS += vendor/xiaomi/dolby-nabu/sepolicy/vendor
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += vendor/xiaomi/dolby-nabu/sepolicy/public
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    vendor/xiaomi/dolby-nabu/configs/vintf/dolby_framework_compatibility_matrix.xml
