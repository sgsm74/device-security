/// Result of a full device security scan.
class DeviceSecurityReport {
  const DeviceSecurityReport({
    required this.isRooted,
    required this.isEmulator,
    required this.isUsbDebugging,
    required this.isDeveloperOptions,
  });

  /// Rooted (Android) or jailbroken (iOS).
  final bool isRooted;

  /// Running on an emulator / simulator.
  final bool isEmulator;

  /// USB debugging (adb) enabled. Always `false` on iOS.
  final bool isUsbDebugging;

  /// Developer options enabled. Always `false` on iOS.
  final bool isDeveloperOptions;

  /// `true` when none of the risky conditions is present.
  bool get isSafe =>
      !isRooted && !isEmulator && !isUsbDebugging && !isDeveloperOptions;

  /// Human-readable Persian reasons for why the device is blocked.
  List<String> get blockingReasons => [
        if (isRooted) 'دستگاه روت یا جیلبریک شده است',
        if (isEmulator) 'برنامه روی شبیه‌ساز اجرا شده است',
        if (isUsbDebugging) 'اشکال‌زدایی USB فعال است',
        if (isDeveloperOptions) 'گزینه‌های برنامه‌نویس فعال است',
      ];

  Map<String, bool> toMap() => {
        'isRooted': isRooted,
        'isEmulator': isEmulator,
        'isUsbDebugging': isUsbDebugging,
        'isDeveloperOptions': isDeveloperOptions,
        'isSafe': isSafe,
      };

  @override
  String toString() => 'DeviceSecurityReport(${toMap()})';
}
