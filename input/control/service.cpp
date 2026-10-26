// SPDX-License-Identifier: Apache-2.0
#include "Control.h"
#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/properties.h>
#include <hidl/HidlTransportSupport.h>
#include <hwbinder/IPCThreadState.h>
#include <private/android_filesystem_config.h>
#include <vendor/pixelos/nabu/input/1.0/IInputControl.h>
#include <cerrno>
#include <mutex>
using vendor::pixelos::nabu::input::V1_0::IInputControl;
using vendor::pixelos::nabu::input::V1_0::State;
using android::hardware::Return;
struct Sysfs final : nabu::Backend {
    bool read(const std::string& path, std::string& out) override { return android::base::ReadFileToString(path, &out); }
    bool write(const std::string& path, const std::string& value) override { return android::base::WriteStringToFile(value, path); }
    std::string property(const std::string& name, const std::string& fallback) override { return android::base::GetProperty(name, fallback); }
    bool save(const std::string& name, const std::string& value) override { return android::base::SetProperty(name, value); }
};
struct InputControl final : IInputControl {
    std::mutex mutex;
    Sysfs backend;
    Return<void> getState(getState_cb cb) override {
        std::lock_guard<std::mutex> lock(mutex);
        auto uid = android::hardware::IPCThreadState::self()->getCallingUid();
        if (uid % AID_USER_OFFSET != AID_SYSTEM) { cb(State{-1,-1,-1,-1,-1,-1}); return {}; }
        auto s = nabu::readState(backend);
        cb(State{s[0], s[1], s[2], s[3], s[4], s[5]}); return {};
    }
    Return<int32_t> setControl(int32_t control, int32_t value) override {
        // These are device-wide choices. Secondary users may inspect, but cannot change them.
        if (android::hardware::IPCThreadState::self()->getCallingUid() != AID_SYSTEM) return -EACCES;
        std::lock_guard<std::mutex> lock(mutex);
        int result = nabu::setControl(backend, control, value);
        if (result) LOG(ERROR) << "Input control " << control << " failed: " << result;
        return result;
    }
};
int main(int argc, char** argv) {
    android::base::InitLogging(argv);
    (void)argc;
    android::hardware::configureRpcThreadpool(1, true);
    android::sp<InputControl> service = new InputControl();
    if (service->registerAsService() != android::OK) return 1;
    android::hardware::joinRpcThreadpool(); return 1;
}
