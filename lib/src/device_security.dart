import 'package:flutter/services.dart';

import 'device_security_report.dart';
import 'platform.dart' as platform;

/// Native device integrity checks (root/jailbreak, emulator, USB debugging,
/// developer options). Every call is safe to invoke on any platform; on
/// unsupported platforms it returns `false`.
class DeviceSecurity {
  DeviceSecurity._();

  static const MethodChannel _channel = MethodChannel('device_security');

  static bool get _supported => platform.isAndroid || platform.isIOS;

  static Future<bool> _call(String method) async {
    if (!_supported) return false;
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Rooted (Android) or jailbroken (iOS).
  static Future<bool> isRooted() => _call('isRooted');

  /// Running on an Android emulator or iOS simulator.
  static Future<bool> isEmulator() => _call('isEmulator');

  /// USB debugging (adb) enabled. Android only; `false` elsewhere.
  static Future<bool> isUsbDebugging() =>
      platform.isAndroid ? _call('isUsbDebugging') : Future.value(false);

  /// Developer options enabled. Android only; `false` elsewhere.
  static Future<bool> isDeveloperOptions() =>
      platform.isAndroid ? _call('isDeveloperOptions') : Future.value(false);

  /// Runs all checks in a single native call and returns a report.
  static Future<DeviceSecurityReport> check() async {
    if (!_supported) {
      return const DeviceSecurityReport(
        isRooted: false,
        isEmulator: false,
        isUsbDebugging: false,
        isDeveloperOptions: false,
      );
    }
    Map<Object?, Object?> raw;
    try {
      raw = await _channel.invokeMethod<Map<Object?, Object?>>('check') ?? {};
    } on MissingPluginException {
      raw = {};
    }
    return DeviceSecurityReport(
      isRooted: raw['isRooted'] == true,
      isEmulator: raw['isEmulator'] == true,
      isUsbDebugging: raw['isUsbDebugging'] == true,
      isDeveloperOptions: raw['isDeveloperOptions'] == true,
    );
  }
}
