# device_security

پلاگین داخلی فلاتر برای تشخیص:

| چک | اندروید | iOS |
|---|---|---|
| روت / جیلبریک | ✅ | ✅ |
| شبیه‌ساز | ✅ | ✅ |
| USB Debugging | ✅ | ❌ (همیشه false) |
| Developer Options | ✅ | ❌ (همیشه false) |

بدون هیچ وابستگی سوم‌شخص برای چک‌های نیتیو. UI مسدودکننده آماده هم همراه پکیج است.

## نصب

```yaml
dependencies:
  device_security:
    git:
      url: http://192.168.100.8/Store-FlutterApps/Device_Security/_git/Device_Security
      ref: master
```

## استفاده پیشنهادی (مسدود کردن ورود)

```dart
import 'package:device_security/device_security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final blocked = await blockedDeviceSecurityReport();
  if (blocked != null) {
    runApp(UnsafeDeviceApp(report: blocked, fontFamily: 'IranYekan'));
    return;
  }

  runApp(const MyApp());
}
```

`blockedDeviceSecurityReport()` در حالت debug چیزی برنمی‌گرداند تا توسعه روی امولاتور ممکن باشد. در release اگر دستگاه ناامن باشد، گزارش را برمی‌گرداند.

## چک خام

```dart
final report = await DeviceSecurity.check();
if (!report.isSafe) {
  // report.isRooted / isEmulator / isUsbDebugging / isDeveloperOptions
  // report.blockingReasons
}

final rooted = await DeviceSecurity.isRooted();
```

## تنظیمات اضافی

### iOS (اختیاری)
برای چک URL Scheme جیلبریک، به `ios/Runner/Info.plist` اضافه کنید:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>cydia</string>
  <string>sileo</string>
  <string>zbra</string>
  <string>filza</string>
  <string>undecimus</string>
</array>
```

بدون این کلید بقیه‌ی چک‌ها کار می‌کنند و فقط این یکی همیشه false برمی‌گرداند.

### اندروید
هیچ تنظیمی لازم نیست. بلوک `<queries>` داخل manifest پلاگین به‌صورت خودکار با اپ merge می‌شود.

## نکات

- در حالت debug روی امولاتور `isEmulator` طبیعتاً `true` است؛ helper پکیج در debug چک را رد می‌کند.
- تشخیص روت صددرصدی نیست (Magisk DenyList و امثالش). برای امنیت جدی Play Integrity با اعتبارسنجی سرور لازم است.
- روی custom ROM ها احتمال false positive وجود دارد.
# device-security
