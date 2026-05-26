import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds a pending command string that can be executed after user approval.
/// The command is typically a PowerShell command that runs the downloaded installer.
final pendingCommandProvider = StateProvider<String?>((ref) => null);
