import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/routing/app_router.dart';

/// Modern sidebar drawer displaying past conversation and translation history.
///
/// Features:
/// - Brand sage theme header with quick close button.
/// - Filter chips: All, Conversation, Sign → Speech, Text → Sign.
/// - Chronological session cards with time badges and message counts.
/// - Quick resume/view action for any past session.
/// - Clear history option with confirmation dialog.
class HistoryDrawer extends StatefulWidget {
  const HistoryDrawer({super.key});

  @override
  State<HistoryDrawer> createState() => _HistoryDrawerState();
}

class _HistoryDrawerState extends State<HistoryDrawer> {
  String _selectedFilter = 'All';

  // Sample past history sessions
  final List<_HistoryItem> _items = [
    _HistoryItem(
      id: 'h_1',
      title: 'Doctor Consultation — General Checkup',
      subtitle: 'Doctor: "Take this medicine twice daily after meals."',
      type: _HistoryType.conversation,
      time: '11:20 AM',
      date: 'Today',
      badge: '12 messages',
    ),
    _HistoryItem(
      id: 'h_2',
      title: 'Sign Translation: Medical Store',
      subtitle: 'Detected: "Where is the nearest pharmacy?"',
      type: _HistoryType.signToSpeech,
      time: '09:45 AM',
      date: 'Today',
      badge: '98% confidence',
    ),
    _HistoryItem(
      id: 'h_3',
      title: 'Text Translation: Train Schedule',
      subtitle: 'Input: "What time is the train to New Delhi?"',
      type: _HistoryType.textToSign,
      time: '04:15 PM',
      date: 'Yesterday',
      badge: 'ISL 3D Sign',
    ),
    _HistoryItem(
      id: 'h_4',
      title: 'Bank Account Opening Discussion',
      subtitle: 'Officer: "Please provide your Aadhaar and signature."',
      type: _HistoryType.conversation,
      time: '02:30 PM',
      date: 'Yesterday',
      badge: '18 messages',
    ),
    _HistoryItem(
      id: 'h_5',
      title: 'Emergency Assistance Sign',
      subtitle: 'Detected: "I need immediate help, please call doctor."',
      type: _HistoryType.signToSpeech,
      time: '06:10 PM',
      date: 'Nov 14',
      badge: '99% confidence',
    ),
  ];

  List<_HistoryItem> get _filteredItems {
    if (_selectedFilter == 'All') return _items;
    if (_selectedFilter == 'Conversation') {
      return _items.where((i) => i.type == _HistoryType.conversation).toList();
    }
    if (_selectedFilter == 'Sign → Speech') {
      return _items.where((i) => i.type == _HistoryType.signToSpeech).toList();
    }
    if (_selectedFilter == 'Text → Sign') {
      return _items.where((i) => i.type == _HistoryType.textToSign).toList();
    }
    return _items;
  }

  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Past History?'),
        content: const Text(
          'This will remove all saved conversations and sign translation logs from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.graphite)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() => _items.clear());
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8FAF9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Drawer Header ──────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD6E8DE), // Luminous pastel sage
                    Color(0xFFEAF2ED), // Soft porcelain mist
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.forestSage.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.history_rounded,
                              color: AppColors.forestSage,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Past History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF202522),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.forestSage,
                        tooltip: 'Close sidebar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your past conversations & sign translations',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.graphite.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Filter Chips ───────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Conversation'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Sign → Speech'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Text → Sign'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── History List ───────────────────────────────────
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 48,
                            color: AppColors.graphite.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No history yet',
                            style: AppTypography.cardHeading.copyWith(
                              color: AppColors.graphite.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Conversations and signs will appear here.',
                            style: AppTypography.supporting,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return _buildHistoryCard(item);
                      },
                    ),
            ),

            // ── Bottom Action Footer ───────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.stone.withValues(alpha: 0.8),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_items.length} sessions saved',
                    style: AppTypography.supporting.copyWith(
                      color: AppColors.graphite.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  if (_items.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearAllHistory,
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                      label: const Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forestSage : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.forestSage : const Color(0xFFE5E7EB),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.forestSage.withValues(alpha: 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.graphite,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(_HistoryItem item) {
    final IconData icon;
    final Color iconColor;
    final Color badgeBg;

    switch (item.type) {
      case _HistoryType.conversation:
        icon = Icons.forum_rounded;
        iconColor = AppColors.forestSage;
        badgeBg = const Color(0xFFD6E8DE);
        break;
      case _HistoryType.signToSpeech:
        icon = Icons.back_hand_rounded;
        iconColor = const Color(0xFF2C6B56);
        badgeBg = const Color(0xFFE0EFE8);
        break;
      case _HistoryType.textToSign:
        icon = Icons.translate_rounded;
        iconColor = const Color(0xFF386B52);
        badgeBg = const Color(0xFFE8F2EC);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAEFEA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202522),
                  ),
                ),
              ),
              Text(
                item.time,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8A9992),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF55605A),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.badge,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
              Text(
                item.date,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8A9992),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _HistoryType {
  conversation,
  signToSpeech,
  textToSign,
}

class _HistoryItem {
  final String id;
  final String title;
  final String subtitle;
  final _HistoryType type;
  final String time;
  final String date;
  final String badge;

  const _HistoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.time,
    required this.date,
    required this.badge,
  });
}
