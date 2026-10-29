import 'dart:io' show Platform;

/// `--dart-define=API_BASE_URL=...` wins. Otherwise the iOS simulator uses
/// the host loopback and the Android emulator uses `10.0.2.2`, which is the
/// emulator's alias for the host machine. A physical device sets the define.
String resolveApiBaseUrl() {
  const fromEnv = String.fromEnvironment('API_BASE_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
  return 'http://localhost:3000/api';
}
