# SPDX-License-Identifier: Apache-2.0
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += vendor/xiaomi/dolby-nabu/input/sepolicy/public
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += vendor/xiaomi/dolby-nabu/input/sepolicy/private
BOARD_VENDOR_SEPOLICY_DIRS += vendor/xiaomi/dolby-nabu/input/sepolicy/vendor
TARGET_ENABLE_NABU_STOCK_TOUCHFEATURE ?= false
ifeq ($(TARGET_ENABLE_NABU_STOCK_TOUCHFEATURE),true)
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += vendor/xiaomi/dolby-nabu/input/configs/touchfeature-matrix.xml
endif
