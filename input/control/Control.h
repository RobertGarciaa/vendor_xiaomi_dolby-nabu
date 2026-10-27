// SPDX-License-Identifier: Apache-2.0
#pragma once
#include <array>
#include <string>
namespace nabu {
inline constexpr const char* kPen = "/sys/touchpanel/pen";
inline constexpr const char* kGen2 = "/sys/touchpanel/pen_gen2_force";
inline constexpr const char* kKeyboard = "/sys/devices/platform/soc/soc:xiaomi_keyboard/xiaomi_keyboard_conn_status";
inline constexpr const char* kProps[] = {"persist.vendor.nabu.input.pen", "persist.vendor.nabu.input.pen_gen2", "persist.vendor.nabu.input.keyboard"};
struct Backend {
    virtual ~Backend() = default;
    virtual bool read(const std::string& path, std::string& out) = 0;
    virtual bool write(const std::string& path, const std::string& value) = 0;
    virtual std::string property(const std::string& name, const std::string& fallback) = 0;
    virtual bool save(const std::string& name, const std::string& value) = 0;
};
// Same field order as the HIDL State. Every missing/invalid measurement is -1.
inline constexpr const char* kChargingMode = "/sys/class/power_supply/idt/reverse_chg_mode";
inline constexpr const char* kChargingState = "/sys/class/power_supply/wireless/reverse_pen_chg_state";
// Hardware charging link, not Bluetooth pairing or general stylus presence.
std::array<int, 2> readPenChargingState(Backend& backend);
std::array<int, 6> readState(Backend& backend);
int setControl(Backend& backend, int control, int value);
}
