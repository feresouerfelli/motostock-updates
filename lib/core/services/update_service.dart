import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/pending_command_provider.dart';

class UpdateService {
  final Ref _ref;
  UpdateService(this._ref);

  static const _repoUrl = 'https://raw.githubusercontent.com/feresouerfelli/motostock-updates/main/latest.json';

  Future<bool> checkForUpdates() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Fetch remote latest.json
      final response = await http.get(Uri.parse(_repoUrl));
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final remoteVersion = data['version'] as String? ?? '';
      final downloadUrl = data['exe_url'] as String? ?? '';

      if (remoteVersion.isEmpty || downloadUrl.isEmpty) return false;

      // Compare semantic versions (simple string compare works for typical "major.minor.patch")
      if (_isNewerVersion(remoteVersion, currentVersion)) {
        // Download the exe to a temporary location within the workspace
        final bytes = await http.get(Uri.parse(downloadUrl)).then((r) => r.bodyBytes);
        final dir = await getApplicationSupportDirectory();
        final filePath = '${dir.path}/motostock_update_${remoteVersion}.exe';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        // Prepare silent install command (Inno Setup supports /VERYSILENT)
        final command = '"$filePath" /VERYSILENT';
        // Store the command in a provider so UI can trigger it later
        _ref.read(pendingCommandProvider.notifier).state = command;
        return true;
      }
    } catch (_) {
      // ignore errors, treat as no update
    }
    return false;
  }

  bool _isNewerVersion(String remote, String local) {
    // Simple numeric comparison split by '.'
    final remoteParts = remote.split('.').map(int.tryParse).whereType<int>().toList();
    final localParts = local.split('.').map(int.tryParse).whereType<int>().toList();
    for (var i = 0; i < remoteParts.length; i++) {
      final r = remoteParts[i];
      final l = i < localParts.length ? localParts[i] : 0;
      if (r > l) return true;
      if (r < l) return false;
    }
    return false;
  }
}
