// SPDX-License-Identifier: Apache-2.0
#include "Control.h"
#include <cerrno>
#include <climits>
#include <cstdlib>
namespace nabu {
static int integer(const std::string& text, int minimum, int maximum) {
    if (text.empty()) return -1;
    char* end = nullptr;
    errno = 0;
    long value = strtol(text.c_str(), &end, 10);
    if (end == text.c_str() || errno || value < minimum || value > maximum) return -1;
    while (*end == ' ' || *end == '\n' || *end == '\r' || *end == '\t') ++end;
    return *end == '\0' ? static_cast<int>(value) : -1;
}
static int measured(Backend& b, const char* path, int minimum, int maximum) {
    std::string data;
    return b.read(path, data) ? integer(data, minimum, maximum) : -1;
}
std::array<int, 2> readPenChargingState(Backend& b) {
    return {measured(b, kChargingMode, 0, 1), measured(b, kChargingState, 0, 5)};
}
std::array<int, 6> readState(Backend& b) {
    auto requested = b.property(kProps[2], "enable_keyboard");
    // idtp9418 returns a fabricated 50% with reverse mode off. State 4 is
    // receiver-ready in this kernel; neither a Hall magnet nor TX mode alone
    // establishes a communicating pen. Recheck both after reading measurements.
    auto before = readPenChargingState(b);
    int battery = -1, current = -1;
    if (before[0] == 1 && before[1] == 4) {
        battery = measured(b, "/sys/class/power_supply/idt/reverse_pen_soc", 0, 100);
        current = measured(b, "/sys/class/power_supply/idt/reverse_iout", 0, INT_MAX);
        if (readPenChargingState(b) != before) battery = current = -1;
    }
    return {measured(b, kPen, 0, 1), measured(b, kGen2, 0, 1),
            requested == "enable_keyboard" ? 1 : requested == "disable_keyboard" ? 0 : -1,
            measured(b, kKeyboard, 0, 1), battery, current};
}
int setControl(Backend& b, int control, int value) {
    if (control < 0 || control > 2 || (value != 0 && value != 1)) return -EINVAL;
    const char* path = control == 0 ? kPen : control == 1 ? kGen2 : kKeyboard;
    const std::string next = control == 2 ? (value ? "enable_keyboard" : "disable_keyboard") : std::to_string(value);
    std::string before;
    // Check node availability even for keyboard; its read value reports connection only.
    if (!b.read(path, before)) return -ENODEV;
    int old = control == 2 ? readState(b)[2] : integer(before, 0, 1);
    if (old < 0) return -EIO;
    const std::string rollback = control == 2 ? (old ? "enable_keyboard" : "disable_keyboard") : std::to_string(old);
    if (!b.write(path, next)) return -EIO;
    if (control != 2 && measured(b, path, 0, 1) != value) {
        return b.write(path, rollback) ? -EIO : -EREMOTEIO;
    }
    if (!b.save(kProps[control], next)) {
        // A failed persistence operation must not silently leave a new runtime choice.
        return b.write(path, rollback) ? -EIO : -EREMOTEIO;
    }
    return 0;
}
}
