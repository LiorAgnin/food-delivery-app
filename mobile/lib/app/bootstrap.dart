import 'package:flutter_riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../application/ports.dart';
import '../data/data_plane.dart';
import '../data/session/prefs_session_store.dart';

final class AppBootstrap {
  const AppBootstrap({required this.overrides});

  final List<Override> overrides;
}

/// Composition root. Tests bind fakes at this same seam.
///
/// [baseUrl] is the `--dart-define=API_BASE_URL` the Patrol launcher passes
/// through. Production omits it and [dataPlaneBindings] uses the platform
/// default.
AppBootstrap bootstrapApp({required SharedPreferences prefs, String? baseUrl}) {
  return AppBootstrap(
    overrides: [
      sessionStoreProvider.overrideWithValue(PrefsSessionStore(prefs)),
      ...dataPlaneBindings(baseUrl: baseUrl),
    ],
  );
}
