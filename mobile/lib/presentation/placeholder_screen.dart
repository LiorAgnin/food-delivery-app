import 'package:flutter/material.dart';

/// A route later agents own. The text starts with `TODO(owner)` so it can
/// be found without guessing a screen name.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}
