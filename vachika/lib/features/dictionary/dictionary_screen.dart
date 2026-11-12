import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';

/// Dictionary screen — search, categories, sign name, video.
///
/// Per DESIGN.md §5: search, categories, sign name, description,
/// demo video, verified variants.
class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final _searchController = TextEditingController();
  // TODO: Connect to sign dictionary API via Riverpod

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dictionary')),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search ────────────────────────────────────
            Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: AppTextField(
                controller: _searchController,
                hintText: 'Search signs…',
                prefixIcon: Icons.search_rounded,
                semanticsLabel: 'Search the sign dictionary',
                onChanged: (value) {
                  // TODO: Filter signs
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Category Chips ────────────────────────────
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.screenPaddingHorizontal,
                children: const [
                  _CategoryChip(label: 'All', selected: true),
                  _CategoryChip(label: 'Greetings'),
                  _CategoryChip(label: 'Common'),
                  _CategoryChip(label: 'Needs'),
                  _CategoryChip(label: 'Questions'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Sign List ─────────────────────────────────
            const Expanded(
              child: EmptyState(
                icon: Icons.menu_book_rounded,
                message: 'Signs will appear here once the dictionary is loaded.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          // TODO: Filter by category
        },
      ),
    );
  }
}
