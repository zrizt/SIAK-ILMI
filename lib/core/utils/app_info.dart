import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static Future<PackageInfo> get info async {
    return PackageInfo.fromPlatform();
  }

  static Future<String> get version async {
    final packageInfo = await info;
    return packageInfo.version;
  }

  static Future<String> get buildNumber async {
    final packageInfo = await info;
    return packageInfo.buildNumber;
  }

  static Future<String> get fullVersion async {
    final packageInfo = await info;
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }
}