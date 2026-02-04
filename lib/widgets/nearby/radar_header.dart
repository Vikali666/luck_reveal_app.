import 'package:flutter/material.dart';
import '../../utils/luck_reveal_theme.dart';

class RadarHeader extends StatefulWidget {
  final int visibleUsers;
  final int maxUsers;
  final Function(int) onDistanceChanged;

  const RadarHeader({
    super.key,
    required this.visibleUsers,
    required this.maxUsers,
    required this.onDistanceChanged,
  });

  @override
  State<RadarHeader> createState() => _RadarHeaderState();
}

class _RadarHeaderState extends State<RadarHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _selectedDistance = 10;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: LuckRevealTheme.background.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: LuckRevealTheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: Tween(begin: 0.9, end: 1.1).animate(_pulseController),
                child: const Icon(
                  Icons.location_on,
                  color: LuckRevealTheme.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cerca de ti",
                    style: TextStyle(
                      color: LuckRevealTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${widget.visibleUsers}/${widget.maxUsers} usuarios visibles",
                    style: const TextStyle(
                      color: LuckRevealTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LuckRevealTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: LuckRevealTheme.primary),
                ),
                child: const Text(
                  "FREE",
                  style: TextStyle(
                    color: LuckRevealTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Distance Selector (Poker Chips style)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [10, 25, 50, 100].map((dist) {
                final isSelected = _selectedDistance == dist;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDistance = dist);
                    widget.onDistanceChanged(dist);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          isSelected ? LuckRevealTheme.primaryGradient : null,
                      color: isSelected
                          ? null
                          : Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: isSelected
                            ? LuckRevealTheme.accent
                            : Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: LuckRevealTheme.primary
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${dist}km",
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : LuckRevealTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
