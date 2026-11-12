import 'package:flutter/material.dart';

import '../../core/widgets/empty_state.dart';

/// History screen — list with date/time, search, delete.
///
/// Per DESIGN.md §5: opt-in and user-controlled.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to conversation repository via Riverpod
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const EmptyState(
        icon: Icons.history_rounded,
        message: 'No conversation history yet.\nPast sessions will appear here.',
      ),
    );
  }
}
