import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/router.dart';

class FoodDeliveryApp extends ConsumerWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Food Delivery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBF360C)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
