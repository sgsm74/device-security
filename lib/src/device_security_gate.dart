import 'package:flutter/foundation.dart';

import 'device_security.dart';
import 'device_security_report.dart';

/// Returns a report when the app must stay blocked, otherwise `null`.
///
/// Native checks are skipped in debug so `flutter run` on an emulator
/// (USB debugging / developer options) still works. Release builds block
/// rooted, emulator, USB debugging, and developer-options devices.
///
/// On check failure, returns `null` (fail-open) so a plugin glitch does not
/// lock every user out.
Future<DeviceSecurityReport?> blockedDeviceSecurityReport() async {
  if (!kReleaseMode) return null;

  try {
    final report = await DeviceSecurity.check();
    return report.isSafe ? null : report;
  } catch (_) {
    return null;
  }
}
