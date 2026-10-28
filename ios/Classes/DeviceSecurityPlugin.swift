import Flutter
import MachO
import UIKit

public class DeviceSecurityPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "device_security", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(DeviceSecurityPlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isRooted":
      result(JailbreakDetector.isJailbroken())
    case "isEmulator":
      result(JailbreakDetector.isSimulator())
    case "isUsbDebugging", "isDeveloperOptions":
      result(false)
    case "check":
      result([
        "isRooted": JailbreakDetector.isJailbroken(),
        "isEmulator": JailbreakDetector.isSimulator(),
        "isUsbDebugging": false,
        "isDeveloperOptions": false,
      ])
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

enum JailbreakDetector {
  static func isSimulator() -> Bool {
    #if targetEnvironment(simulator)
    return true
    #else
    return false
    #endif
  }

  static func isJailbroken() -> Bool {
    #if targetEnvironment(simulator)
    return false
    #else
    return hasSuspiciousPaths() || canWriteOutsideSandbox() || hasJailbreakSchemes() || hasSuspiciousDylibs()
    #endif
  }

  private static let suspiciousPaths = [
    "/Applications/Cydia.app", "/Applications/Sileo.app", "/Applications/Zebra.app",
    "/Applications/Installer.app", "/Applications/blackra1n.app", "/Applications/FakeCarrier.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib", "/Library/MobileSubstrate/DynamicLibraries",
    "/usr/libexec/cydia", "/usr/sbin/sshd", "/usr/bin/ssh", "/usr/sbin/frida-server",
    "/bin/bash", "/bin/sh", "/etc/apt", "/etc/ssh/sshd_config",
    "/private/var/lib/apt/", "/private/var/lib/cydia", "/private/var/stash",
    "/private/var/tmp/cydia.log", "/var/cache/apt", "/var/lib/cydia",
    "/var/jb", "/var/binpack", "/.installed_unc0ver", "/.bootstrapped_electra",
    "/usr/lib/libjailbreak.dylib", "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
  ]

  private static func hasSuspiciousPaths() -> Bool {
    let fm = FileManager.default
    for p in suspiciousPaths {
      if fm.fileExists(atPath: p) { return true }
      // fileExists can be hooked; fopen is a second opinion.
      if let f = fopen(p, "r") { fclose(f); return true }
    }
    return false
  }

  private static func canWriteOutsideSandbox() -> Bool {
    let path = "/private/jb_\(UUID().uuidString).txt"
    do {
      try "x".write(toFile: path, atomically: true, encoding: .utf8)
      try? FileManager.default.removeItem(atPath: path)
      return true
    } catch {
      return false
    }
  }

  private static let schemes = [
    "cydia://package/com.example", "sileo://package/com.example",
    "zbra://package/com.example", "filza://", "undecimus://",
  ]

  private static func hasJailbreakSchemes() -> Bool {
    // Requires LSApplicationQueriesSchemes in the host app's Info.plist; silently false otherwise.
    for s in schemes {
      if let url = URL(string: s), UIApplication.shared.canOpenURL(url) { return true }
    }
    return false
  }

  private static func hasSuspiciousDylibs() -> Bool {
    let needles = ["substrate", "substitute", "frida", "cycript", "libhooker", "sslkill", "ssl-kill"]
    let count = _dyld_image_count()
    for i in 0..<count {
      guard let cName = _dyld_get_image_name(i) else { continue }
      let name = String(cString: cName).lowercased()
      if needles.contains(where: { name.contains($0) }) { return true }
    }
    return false
  }
}
