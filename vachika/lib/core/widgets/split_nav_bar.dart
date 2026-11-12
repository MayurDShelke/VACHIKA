import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Data model representing a tab item in [SplitNavBar].
class SplitNavItem {
  const SplitNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.tooltip,
  });

  /// The icon displayed when unselected (or default).
  final IconData icon;

  /// Optional icon to display when selected.
  final IconData? selectedIcon;

  /// Short text label displayed beneath the icon.
  final String label;

  /// Optional tooltip or accessibility label.
  final String? tooltip;
}

/// A floating navigation bar that dynamically splits when the 1st icon is active.
///
/// Behavior:
/// - When on the 1st icon (`currentIndex == 0`):
///   The 1st icon is separated into its own standalone circular button on the left,
///   and the other 3 icons are grouped together in a rounded rectangle pill dock
///   (as seen in Image 0).
/// - When on any other icon (`currentIndex != 0`):
///   The bar smoothly merges into a single unified rounded rectangle pill dock
///   containing all 4 icons, with the active tab highlighted by a soft capsule
///   bubble (as seen in Image 1).
class SplitNavBar extends StatelessWidget {
  const SplitNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.height = 64.0,
    this.circleDiameter = 62.0,
    this.gap = 10.0,
  }) : assert(items.length >= 2, 'SplitNavBar requires at least 2 items');

  /// Currently selected tab index.
  final int currentIndex;

  /// Callback when a tab is tapped.
  final ValueChanged<int> onTap;

  /// List of navigation items.
  final List<SplitNavItem> items;

  /// Height of the bar and circular button.
  final double height;

  /// Diameter of the standalone circular button.
  final double circleDiameter;

  /// Horizontal spacing between the circular button and the pill dock.
  final double gap;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final animationDuration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 280);

    final isFirstActive = currentIndex == 0;

    return Semantics(
      container: true,
      label: 'Main Navigation Bar',
      child: AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: isFirstActive
            ? KeyedSubtree(
                key: const ValueKey('split_layout'),
                child: _buildSplitLayout(context),
              )
            : KeyedSubtree(
                key: const ValueKey('unified_layout'),
                child: _buildUnifiedLayout(context),
              ),
      ),
    );
  }

  /// Split Layout:
  /// ( 1st Icon in Circle ) + [ Other 3 Icons in Pill Dock ]
  Widget _buildSplitLayout(BuildContext context) {
    final firstItem = items.first;
    final remainingItems = items.sublist(1);

    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Standalone Circle Button for 1st Icon ──
          _CircleTabButton(
            diameter: circleDiameter,
            item: firstItem,
            isSelected: true,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(0);
            },
          ),
          SizedBox(width: gap),

          // ── Rectangle Pill Dock for the remaining icons ──
          Expanded(
            child: _PillDockContainer(
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(remainingItems.length, (index) {
                  final actualIndex = index + 1;
                  final item = remainingItems[index];
                  return Expanded(
                    child: _DockItemButton(
                      item: item,
                      isSelected: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(actualIndex);
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Unified Layout:
  /// [ All 4 Icons in one rounded rectangle pill dock ]
  Widget _buildUnifiedLayout(BuildContext context) {
    return SizedBox(
      height: height,
      child: _PillDockContainer(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = currentIndex == index;
            return Expanded(
              child: _DockItemButton(
                item: item,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(index);
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Standalone Circular Button ─────────────────────────────────

class _CircleTabButton extends StatelessWidget {
  const _CircleTabButton({
    required this.diameter,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final double diameter;
  final SplitNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: item.tooltip ?? item.label,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.stone.withValues(alpha: 0.9),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.graphite.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: diameter * 0.72,
                  height: diameter * 0.72,
                  decoration: BoxDecoration(
                    color: AppColors.forestSage.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.selectedIcon ?? item.icon,
                    color: AppColors.forestSage,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pill Container ─────────────────────────────────────────────

class _PillDockContainer extends StatelessWidget {
  const _PillDockContainer({
    required this.child,
    required this.height,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: AppColors.stone.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.graphite.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}

// ── Item Button Inside Pill ────────────────────────────────────

class _DockItemButton extends StatelessWidget {
  const _DockItemButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final SplitNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.forestSage;
    final inactiveColor = AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.tooltip ?? item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 12 : 6,
              vertical: isSelected ? 5 : 4,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                  size: 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
