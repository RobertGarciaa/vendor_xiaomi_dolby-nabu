# Pen charging status

The IDT idtp9418 driver in the tracked crDroid nabu kernel returns **50** from
`reverse_pen_soc` when neither reverse nor boost mode is active. It is a driver
fallback, not a measurement. Never expose it as an attached pen's battery.

The control service accepts SOC/current only while IDT `reverse_chg_mode` is 1
and wireless `reverse_pen_chg_state` is 4, rechecking both after the readings.
The driver's INT_GET_CFG path sets state 4 when reverse/boost mode is active.
Missing/malformed nodes, faults, inactive mode, SOC 255 and transitions invalidate
the measurement. State 2 can also follow charge completion; it must not be
called disconnected or extrapolated to 100%. The link is described as charging
communication, not Bluetooth pairing or general physical pen presence.

`getState` keeps its original six-int layout. Transaction 3 adds the two charging
status values. Deploy the new app and generated control HAL together. The app
invalidates a measurement if its later status query no longer shows that link.
The original settings app's overflow menu includes the status; hardware controls
refresh every two seconds while resumed, without a background polling service.
No app receives direct sysfs access. The background monitor uses the same
read-only HIDL measurements through system_server, with an explicit HAL-client
policy rule. It does not write hardware state.

SmartDevil's non-Bluetooth capacitive pen uses ordinary touch input. There is no
identified telemetry path for its battery, identity, or presence. Dedicated pen
firmware controls and pressure/button features do not add those capabilities to
it. Leave normal finger/touch handling unchanged. A registered Goodix input
node, a magnet/Hall reading, and a zero charging current do not identify a pen.

Host tests cover the fake 50%, receiver-not-ready states, invalid/missing data,
100% without clamping, and unplug during a read. ASan/UBSan tests, current ARM64
platform-header compilation of the service and generated HIDL transport, and
signed APK resource/API verification passed. No full product build or physical
Xiaomi pen test was performed. The stock driver's I2C reads do not propagate all
errors; this userspace gate cannot prove every sampled SOC is fresh. Two reads
also cannot detect an entire detach/reattach occurring between samples.

## Background notifications

Framework patch 0007 starts a product-gated power-supply UEventObserver with a
separate HandlerThread for HIDL reads. It samples after boot/unlock, user switch,
locale changes and IDT/wireless events. Only receiver-ready charging links poll
at ten-second intervals, because IDT can update cached SOC without a uevent.
Missing HAL has at most five bootstrap attempts separated by thirty seconds;
idle capacitive pens have no periodic timer. Fresh power/user events can retry.

A private, non-exported receiver in the original settings APK posts a low-priority
notification only for a gated SOC of 0..100. Inactive/fault/missing/invalid data
cancels it, rather than retaining a stale percentage or declaring Bluetooth
disconnection. No notification is created for a SmartDevil capacitive pen.
Tapping opens the stock stylus/keyboard screen. The notification uses Korean or
English, respects notification settings, and requests POST_NOTIFICATIONS through
an initial non-fixed default grant. It must not override a user's denial.

User-locked accounts are sampled but not sent app broadcasts until unlocked;
user changes clear the old user's notification and refresh the current user's
state. Status broadcasts contain only a battery reading (or cancellation), not
stylus presence. Delivery is asynchronous, and a stopped/crashed original app
cannot be considered a proven receiver. Device verification must check boot,
HAL restart, detach, user switch and notification permission/channel changes.

The monitor/receiver compile against current platform APIs. APK build/signing,
byte-identical original resources, exact compatibility references, patch-chain
application and combined-reference SELinux checks are host validation only.
No full nabu ROM build or genuine Xiaomi pen runtime validation has occurred.
