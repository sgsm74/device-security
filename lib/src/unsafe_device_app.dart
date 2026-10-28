import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'device_security_report.dart';

/// Standalone app shell shown when the device fails security checks.
///
/// Call [runApp] with this widget and return early from `main` so the rest of
/// the app never initializes.
class UnsafeDeviceApp extends StatelessWidget {
  const UnsafeDeviceApp({
    super.key,
    required this.report,
    this.fontFamily,
    this.primaryColor = const Color(0xff3A57E8),
  });

  final DeviceSecurityReport report;

  /// Optional host-app font (e.g. `IranYekan`). Falls back to the platform default.
  final String? fontFamily;

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: UnsafeDevicePage(report: report, primaryColor: primaryColor),
    );
  }
}

/// Blocking screen explaining why the device is not allowed.
class UnsafeDevicePage extends StatelessWidget {
  const UnsafeDevicePage({
    super.key,
    required this.report,
    this.primaryColor = const Color(0xff3A57E8),
  });

  final DeviceSecurityReport report;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final reasons = report.blockingReasons;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                Icon(Icons.security, size: 72, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 24),
                Text(
                  'امکان ورود به برنامه وجود ندارد',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  'دستگاه شما شرایط امنیتی لازم را ندارد.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                ),
                if (reasons.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final reason in reasons)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('•  '),
                                Expanded(child: Text(reason)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('خروج از برنامه'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
