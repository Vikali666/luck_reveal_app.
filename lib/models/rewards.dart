class DailyStreak {
  final int currentStreak;
  final DateTime lastCheckIn;
  final List<bool> weekProgress; // [true, true, false...]
  final bool canClaimReward;

  DailyStreak({
    required this.currentStreak,
    required this.lastCheckIn,
    required this.weekProgress,
    required this.canClaimReward,
  });
}

class MysteryBox {
  final String id;
  final String name;
  final String description;
  final List<Reward> possibleRewards;
  final String animationAsset;
  final DateTime unlockDate;

  MysteryBox({
    required this.id,
    required this.name,
    required this.description,
    required this.possibleRewards,
    required this.animationAsset,
    required this.unlockDate,
  });
}

class Reward {
  final String type; // 'likes', 'super_likes', 'premium_days'
  final int amount;
  final String name;
  final String icon;
  final double probability; // 0-1

  Reward({
    required this.type,
    required this.amount,
    required this.name,
    required this.icon,
    required this.probability,
  });
}
