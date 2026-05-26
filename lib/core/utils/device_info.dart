import 'dart:io';

class DeviceInfoHelper {
  DeviceInfoHelper._();

  static Future<String> getDeviceId() async {
    // Return a hardware ID or a generated UUID stored locally
    // For simplicity, we use a constant or generated one.
    // In a real app, use device_info_plus package.
    return 'WINDOWS-DEV-${Platform.localHostname}';
  }

  static String getMachineId() {
    return 'MOTO-PRO-LITE-${Platform.operatingSystem}';
  }

  static String getDeviceName() {
    return Platform.localHostname;
  }

  static Future<String> getMacAddress() async {
    // In a real app, use network_info_plus or get_mac_address
    // For now, return a deterministic ID based on hostname
    return '00:1A:2B:3C:4D:5E:${Platform.localHostname.hashCode % 99}';
  }
}
