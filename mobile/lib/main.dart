import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final boot = bootstrapApp(prefs: prefs);
  runApp(
    ProviderScope(overrides: boot.overrides, child: const FoodDeliveryApp()),
  );
}
