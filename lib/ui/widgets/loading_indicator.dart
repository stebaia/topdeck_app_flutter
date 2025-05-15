import 'package:flutter/material.dart';

/// Widget che mostra un indicatore di caricamento circolare
class LoadingIndicator extends StatelessWidget {
  /// Costruttore
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
} 