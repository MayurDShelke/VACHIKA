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

/// A floating navigation bar that dynamically splits active tabs into standalone
/// circular buttons with brand green theme accents, while grouping other connected
/// tabs into rounded rectangle pill docks ("radical rectangles").
///
/// Behavior:
/// - When on Tab 0 (Conversation Mode):
///   Tab 0 is in its own standalone circular button on the left (active, theme green),
///   and [Sign → Speech, Text → Sign, Profile] are grouped in a connected rounded rectangle dock.
/// - When on Tab 1 (Sign → Speech):
///   Tab 0 is in a clean white circle, Tab 1 is in its own circle (active, theme green),
///   and [Text → Sign, Profile] are connected in one rounded rectangle dock.
/// - When on Tab 2 (Text → Sign):
///   [Conversation, Sign → Speech] are connected together in one rounded rectangle dock, Tab 2 is in
///   its own standalone circle (active, theme green), and Profile is in a rounded capsule.
/// - When on Tab 3 (Profile):
///   [Conversation, Sign → Speech, Text → Sign] are all connected together in one rounded rectangle dock,
///   and Profile is in its own standalone circle (active, theme green).
class SplitNavBar extends StatelessWidget {
  const SplitNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.height = 62.0,
    this.circleDiameter = 60.0,
    this.gap = 8.0,
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

  /// Horizontal spacing between detached segments.
  final double gap;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final animationDuration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 260);

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
        child: KeyedSubtree(
          key: ValueKey<int>(currentIndex),
          child: _buildDynamicLayout(context),
        ),
      ),
    );
  }

  /// Dynamic layout that adapts based on the active tab
  Widget _buildDynamicLayout(BuildContext context) {
    if (items.length != 4) {
      return _buildGenericLayout(context);
    }

    switch (currentIndex) {
      case 0:
        return _buildHomeActiveLayout(context);
      case 1:
        return _buildDictionaryActiveLayout(context);
      case 2:
        return _buildHistoryActiveLayout(context);
      case 3:
        return _buildSettingsActiveLayout(context);
      default:
        return _buildGenericLayout(context);
    }
  }

  /// ── Case 0: Home active (Tab 0) ─────────────────────────────
  /// [ Home (Circle, active) ]  [ Dictionary | History | Settings (Pill) ]
  Widget _buildHomeActiveLayout(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CircleTabButton(
            diameter: circleDiameter,
            item: items[0],
            isSelected: true,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(0);
            },
          ),
          SizedBox(width: gap),
          Expanded(
            child: _PillDockContainer(
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 1; i < items.length; i++)
                    Expanded(
                      child: _DockItemButton(
                        item: items[i],
                        isSelected: false,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTap(i);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Case 1: Dictionary active (Tab 1) ───────────────────────
  /// [ Home (Circle) ]  [ Dictionary (Circle, active) ]  [ History | Settings (Pill) ]
  Widget _buildDictionaryActiveLayout(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Home in circle
          _CircleTabButton(
            diameter: circleDiameter,
            item: items[0],
            isSelected: false,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(0);
            },
          ),
          SizedBox(width: gap),

          // Dictionary in circle (active with theme green)
          _CircleTabButton(
            diameter: circleDiameter,
            item: items[1],
            isSelected: true,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(1);
            },
          ),
          SizedBox(width: gap),

          // History and Settings connected in one rounded rectangle
          Expanded(
            child: _PillDockContainer(
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _DockItemButton(
                      item: items[2],
                      isSelected: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(2);
                      },
                    ),
                  ),
                  Expanded(
                    child: _DockItemButton(
                      item: items[3],
                      isSelected: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(3);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Case 2: History active (Tab 2) ──────────────────────────
  /// [ Home | Dictionary (Pill) ]  [ History (Circle, active) ]  [ Settings (Capsule) ]
  Widget _buildHistoryActiveLayout(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Home and Dictionary connected in one rounded rectangle
          Expanded(
            flex: 5,
            child: _PillDockContainer(
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _DockItemButton(
                      item: items[0],
                      isSelected: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(0);
                      },
                    ),
                  ),
                  Expanded(
                    child: _DockItemButton(
                      item: items[1],
                      isSelected: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(1);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: gap),

          // History in circle (active with theme green)
          _CircleTabButton(
            diameter: circleDiameter,
            item: items[2],
            isSelected: true,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(2);
            },
          ),
          SizedBox(width: gap),

          // Settings in rounded capsule
          Expanded(
            flex: 3,
            child: _PillDockContainer(
              height: height,
              child: _DockItemButton(
                item: items[3],
                isSelected: false,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(3);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Case 3: Settings active (Tab 3) ─────────────────────────
  /// [ Home | Dictionary | History (Pill) ]  [ Settings (Circle, active) ]
  Widget _buildSettingsActiveLayout(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Home, Dictionary, and History connected in one rounded rectangle
          Expanded(
            child: _PillDockContainer(
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: _DockItemButton(
                        item: items[i],
                        isSelected: false,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTap(i);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: gap),

          // Settings in circle (active with theme green)
          _CircleTabButton(
            diameter: circleDiameter,
            item: items[3],
            isSelected: true,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(3);
            },
          ),
        ],
      ),
    );
  }

  /// Generic fallback for dynamic number of items
  Widget _buildGenericLayout(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CircleTabButton(
            diameter: circleDiameter,
            item: items[0],
            isSelected: currentIndex == 0,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(0);
            },
          ),
          SizedBox(width: gap),
          Expanded(
            child: _PillDockContainer(
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(items.length - 1, (index) {
                  final actualIndex = index + 1;
                  final isSelected = currentIndex == actualIndex;
                  return Expanded(
                    child: _DockItemButton(
                      item: items[actualIndex],
                      isSelected: isSelected,
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
    // Theme palette colors
    const activeGreenBg = Color(0xFFD6E8DE); // Luminous pastel sage from theme for active tab
    const inactiveBg = Colors.white;         // Pure clean white for inactive tab circle
    final activeBorder = const Color(0xFFB8D5C4).withValues(alpha: 0.90);
    const inactiveBorder = Color(0xFFE5E7EB); // Clean neutral border (no green)
    const inactiveIconColor = Color(0xFF6B7280); // Clean neutral muted icon

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.tooltip ?? item.label,
      child: Tooltip(
        message: item.label,
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? activeBorder : inactiveBorder,
                    width: isSelected ? 1.6 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.forestSage.withValues(alpha: 0.14)
                          : const Color(0xFF202522).withValues(alpha: 0.08),
                      blurRadius: isSelected ? 18 : 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: diameter * 0.72,
                    height: diameter * 0.72,
                    decoration: BoxDecoration(
                      color: isSelected ? activeGreenBg : inactiveBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                        color: isSelected
                            ? AppColors.forestSage
                            : inactiveIconColor,
                        size: 24,
                      ),
                    ),
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

// ── Pill Container ("radical rectangle") ───────────────────────

class _PillDockContainer extends StatelessWidget {
  const _PillDockContainer({
    required this.child,
    required this.height,
    this.hasActiveItem = false,
  });

  final Widget child;
  final double height;
  final bool hasActiveItem;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: hasActiveItem
              ? const Color(0xFFB8D5C4).withValues(alpha: 0.70)
              : const Color(0xFFE5EAE7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF202522).withValues(alpha: 0.08),
            blurRadius: 14,
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
    const inactiveColor = Color(0xFF638079);

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.tooltip ?? item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
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
                  ? const Color(0xFFD6E8DE).withValues(alpha: 0.75)
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
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? activeColor : inactiveColor,
                    letterSpacing: -0.1,
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
