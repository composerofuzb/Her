import 'package:flutter/material.dart';
import 'developmental_stage.dart';

/// Dynamic performance expression reflecting performance, score, and streaks
enum PerformanceMood {
  /// Score >= 85: Radiant golden cosmic aura, triumphant pose, glowing eyes
  radiantCosmic,

  /// Active streak >= 7 days with solid score: Starlight electric energy, proud stance
  energizedStreak,

  /// Score 60–84: Attentive scholar, calm focus aura, reading posture
  steadyScholar,

  /// Score < 60 or missed day: Cozy resting pose, warm gentle aura, self-compassion
  restingRecharge,
}

extension PerformanceMoodX on PerformanceMood {
  String get label {
    switch (this) {
      case PerformanceMood.radiantCosmic:
        return 'Radiant Cosmic';
      case PerformanceMood.energizedStreak:
        return 'Supercharged Streak';
      case PerformanceMood.steadyScholar:
        return 'Focused Scholar';
      case PerformanceMood.restingRecharge:
        return 'Gentle Recharge';
    }
  }

  String get emoji {
    switch (this) {
      case PerformanceMood.radiantCosmic:
        return '✨';
      case PerformanceMood.energizedStreak:
        return '🔥';
      case PerformanceMood.steadyScholar:
        return '📖';
      case PerformanceMood.restingRecharge:
        return '☕';
    }
  }

  String get supportiveDialogue {
    switch (this) {
      case PerformanceMood.radiantCosmic:
        return "You're shining like a supernova today! Keep soaring! 🚀";
      case PerformanceMood.energizedStreak:
        return "Your dedication is unstoppable! Feel the momentum! ⚡";
      case PerformanceMood.steadyScholar:
        return "Steady progress compounds into greatness. Great focus! 📚";
      case PerformanceMood.restingRecharge:
        return "Every star recharges its light. Tomorrow is a fresh dawn! 💫";
    }
  }

  Color get primaryAuraColor {
    switch (this) {
      case PerformanceMood.radiantCosmic:
        return const Color(0xFFFFD700); // Gold
      case PerformanceMood.energizedStreak:
        return const Color(0xFFFF6D00); // Solar Orange
      case PerformanceMood.steadyScholar:
        return const Color(0xFF6C63FF); // Deep Cosmic Purple
      case PerformanceMood.restingRecharge:
        return const Color(0xFF64B5F6); // Soft Serene Sky Blue
    }
  }

  Color get secondaryAuraColor {
    switch (this) {
      case PerformanceMood.radiantCosmic:
        return const Color(0xFFFF80AB); // Magenta Pink
      case PerformanceMood.energizedStreak:
        return const Color(0xFFFFEA00); // Electric Yellow
      case PerformanceMood.steadyScholar:
        return const Color(0xFF00E5FF); // Bright Cyan
      case PerformanceMood.restingRecharge:
        return const Color(0xFFB39DDB); // Lavender Mist
    }
  }
}

/// Categories of customizable wardrobe and appearance elements
enum WardrobeCategory {
  skinTone,
  hairStyle,
  hairColor,
  outfit,
  accessory,
  aura,
}

class WardrobeItem {
  final String id;
  final String name;
  final WardrobeCategory category;
  final String emoji;
  final String description;
  final int requiredLevel;
  final int requiredXp;
  final int requiredStreak;
  final DevelopmentalStage? minimumStage;
  final Color? primaryColor;
  final Color? secondaryColor;

  const WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.description,
    this.requiredLevel = 1,
    this.requiredXp = 0,
    this.requiredStreak = 0,
    this.minimumStage,
    this.primaryColor,
    this.secondaryColor,
  });

  bool isUnlocked({
    required int userLevel,
    required int userXp,
    required int userStreak,
    DevelopmentalStage? currentStage,
  }) {
    if (userLevel < requiredLevel) return false;
    if (userXp < requiredXp) return false;
    if (userStreak < requiredStreak) return false;
    if (minimumStage != null && currentStage != null) {
      if (currentStage.index < minimumStage!.index) return false;
    }
    return true;
  }
}

/// Character customization configuration state
class CharacterCustomization {
  final String skinToneId;
  final String hairStyleId;
  final String hairColorId;
  final String outfitId;
  final String accessoryId;
  final String auraId; // 'auto' or a specific aura id

  const CharacterCustomization({
    this.skinToneId = 'warmPeach',
    this.hairStyleId = 'twinBuns',
    this.hairColorId = 'midnightBlack',
    this.outfitId = 'middleSchoolCasual',
    this.accessoryId = 'starPin',
    this.auraId = 'auto',
  });

  CharacterCustomization copyWith({
    String? skinToneId,
    String? hairStyleId,
    String? hairColorId,
    String? outfitId,
    String? accessoryId,
    String? auraId,
  }) {
    return CharacterCustomization(
      skinToneId: skinToneId ?? this.skinToneId,
      hairStyleId: hairStyleId ?? this.hairStyleId,
      hairColorId: hairColorId ?? this.hairColorId,
      outfitId: outfitId ?? this.outfitId,
      accessoryId: accessoryId ?? this.accessoryId,
      auraId: auraId ?? this.auraId,
    );
  }

  Map<String, dynamic> toMap() => {
        'skinToneId': skinToneId,
        'hairStyleId': hairStyleId,
        'hairColorId': hairColorId,
        'outfitId': outfitId,
        'accessoryId': accessoryId,
        'auraId': auraId,
      };

  factory CharacterCustomization.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CharacterCustomization();
    return CharacterCustomization(
      skinToneId: map['skinToneId'] as String? ?? 'warmPeach',
      hairStyleId: map['hairStyleId'] as String? ?? 'twinBuns',
      hairColorId: map['hairColorId'] as String? ?? 'midnightBlack',
      outfitId: map['outfitId'] as String? ?? 'middleSchoolCasual',
      accessoryId: map['accessoryId'] as String? ?? 'starPin',
      auraId: map['auraId'] as String? ?? 'auto',
    );
  }

  /// Evaluates the dynamic performance mood from today's performance
  PerformanceMood evaluateMood({
    required int todayScore,
    required int streakDays,
  }) {
    if (todayScore >= 85) {
      return PerformanceMood.radiantCosmic;
    } else if (streakDays >= 7 && todayScore >= 60) {
      return PerformanceMood.energizedStreak;
    } else if (todayScore >= 60) {
      return PerformanceMood.steadyScholar;
    } else {
      return PerformanceMood.restingRecharge;
    }
  }
}

/// Catalog of all unlockable wardrobe options (100% free, earned through XP and milestones)
class WardrobeCatalog {
  WardrobeCatalog._();

  // ── Skin Tones ─────────────────────────────────────────────────────────────
  static const List<WardrobeItem> skinTones = [
    WardrobeItem(
      id: 'fairStarlight',
      name: 'Fair Starlight',
      category: WardrobeCategory.skinTone,
      emoji: '🏻',
      description: 'Bright gentle starlight porcelain tone.',
      primaryColor: Color(0xFFFFDFC4),
    ),
    WardrobeItem(
      id: 'warmPeach',
      name: 'Warm Peach',
      category: WardrobeCategory.skinTone,
      emoji: '🏼',
      description: 'Warm peach starlight glow.',
      primaryColor: Color(0xFFF0C097),
    ),
    WardrobeItem(
      id: 'goldenTan',
      name: 'Golden Tan',
      category: WardrobeCategory.skinTone,
      emoji: '🏽',
      description: 'Luminous sun-kissed golden tone.',
      primaryColor: Color(0xFFD4976A),
    ),
    WardrobeItem(
      id: 'richChestnut',
      name: 'Rich Chestnut',
      category: WardrobeCategory.skinTone,
      emoji: '🏾',
      description: 'Warm rich chestnut radiant tone.',
      primaryColor: Color(0xFFA66432),
    ),
    WardrobeItem(
      id: 'deepBronze',
      name: 'Deep Bronze',
      category: WardrobeCategory.skinTone,
      emoji: '🏿',
      description: 'Lustrous deep cosmic bronze tone.',
      primaryColor: Color(0xFF633A18),
    ),
    WardrobeItem(
      id: 'cosmicLavender',
      name: 'Nebula Starlight',
      category: WardrobeCategory.skinTone,
      emoji: '🔮',
      description: 'Otherworldly celestial starlight tone.',
      requiredLevel: 6,
      primaryColor: Color(0xFFCE93D8),
    ),
  ];

  // ── Hair Styles ────────────────────────────────────────────────────────────
  static const List<WardrobeItem> hairStyles = [
    WardrobeItem(
      id: 'twinBuns',
      name: 'Space Buns',
      category: WardrobeCategory.hairStyle,
      emoji: '👧',
      description: 'Playful cosmic double buns for energetic explorers.',
      requiredLevel: 1,
    ),
    WardrobeItem(
      id: 'bob',
      name: 'Sleek Bob',
      category: WardrobeCategory.hairStyle,
      emoji: '💇‍♀️',
      description: 'Crisp and focused modern chin-length cut.',
      requiredLevel: 1,
    ),
    WardrobeItem(
      id: 'ponytail',
      name: 'High Ponytail',
      category: WardrobeCategory.hairStyle,
      emoji: '👱‍♀️',
      description: 'Energetic high ponytail ready for active study sessions.',
      requiredLevel: 2,
    ),
    WardrobeItem(
      id: 'longWavy',
      name: 'Starlight Waves',
      category: WardrobeCategory.hairStyle,
      emoji: '👩‍🦱',
      description: 'Flowing wavy locks with celestial bounce.',
      requiredLevel: 3,
    ),
    WardrobeItem(
      id: 'braids',
      name: 'Cosmic Braids',
      category: WardrobeCategory.hairStyle,
      emoji: '🧑‍🦱',
      description: 'Intricate crown braids with star weave.',
      requiredLevel: 4,
    ),
    WardrobeItem(
      id: 'pixie',
      name: 'Starlight Pixie',
      category: WardrobeCategory.hairStyle,
      emoji: '✨',
      description: 'Sharp and chic pixie cut for determined scholars.',
      requiredLevel: 5,
    ),
  ];

  // ── Hair Colors ────────────────────────────────────────────────────────────
  static const List<WardrobeItem> hairColors = [
    WardrobeItem(
      id: 'midnightBlack',
      name: 'Midnight Black',
      category: WardrobeCategory.hairColor,
      emoji: '🖤',
      description: 'Deep cosmic void black with subtle sheen.',
      primaryColor: Color(0xFF1E1E28),
    ),
    WardrobeItem(
      id: 'chestnutBrown',
      name: 'Warm Chestnut',
      category: WardrobeCategory.hairColor,
      emoji: '🤎',
      description: 'Rich earthy chestnut brown tone.',
      primaryColor: Color(0xFF5D4037),
    ),
    WardrobeItem(
      id: 'goldenAmber',
      name: 'Golden Amber',
      category: WardrobeCategory.hairColor,
      emoji: '💛',
      description: 'Gleaming amber starlight gold.',
      primaryColor: Color(0xFFFFA000),
      requiredLevel: 2,
    ),
    WardrobeItem(
      id: 'cosmicViolet',
      name: 'Cosmic Violet',
      category: WardrobeCategory.hairColor,
      emoji: '💜',
      description: 'Vibrant nebula violet starlight hue.',
      primaryColor: Color(0xFF7B1FA2),
      requiredLevel: 3,
    ),
    WardrobeItem(
      id: 'roseGold',
      name: 'Rose Starlight',
      category: WardrobeCategory.hairColor,
      emoji: '🌸',
      description: 'Pastel rose starlight blush shimmer.',
      primaryColor: Color(0xFFEC407A),
      requiredLevel: 4,
    ),
    WardrobeItem(
      id: 'starlightSilver',
      name: 'Astral Silver',
      category: WardrobeCategory.hairColor,
      emoji: '🤍',
      description: 'Polished platinum silver cosmic glow.',
      primaryColor: Color(0xFFCFD8DC),
      requiredLevel: 6,
    ),
  ];

  // ── Outfits ────────────────────────────────────────────────────────────────
  static const List<WardrobeItem> outfits = [
    WardrobeItem(
      id: 'middleSchoolCasual',
      name: 'Cosmic Explorer T-Shirt',
      category: WardrobeCategory.outfit,
      emoji: '👕',
      description: 'Comfortable cotton explorer tee with cosmic planet patch.',
      requiredLevel: 1,
      primaryColor: Color(0xFF6C63FF),
      secondaryColor: Color(0xFFFFC107),
    ),
    WardrobeItem(
      id: 'starAcademy',
      name: 'Star Academy Uniform',
      category: WardrobeCategory.outfit,
      emoji: '👔',
      description: 'Smart academic blazer with golden star crest.',
      requiredLevel: 2,
      primaryColor: Color(0xFF1E3A8A),
      secondaryColor: Color(0xFFFFD700),
    ),
    WardrobeItem(
      id: 'cozyHoodie',
      name: 'Nebula Study Hoodie',
      category: WardrobeCategory.outfit,
      emoji: '🧥',
      description: 'Warm oversized lavender hoodie for cozy late-afternoon study.',
      requiredLevel: 3,
      primaryColor: Color(0xFF7C3AED),
      secondaryColor: Color(0xFFC084FC),
    ),
    WardrobeItem(
      id: 'varsityJacket',
      name: 'Starlight Varsity Jacket',
      category: WardrobeCategory.outfit,
      emoji: '🥼',
      description: 'Classic high school varsity letterman jacket with star emblem.',
      requiredLevel: 4,
      minimumStage: DevelopmentalStage.highSchool,
      primaryColor: Color(0xFFDC2626),
      secondaryColor: Color(0xFFFFFFFF),
    ),
    WardrobeItem(
      id: 'techScholar',
      name: 'Tech Scholar Streetwear',
      category: WardrobeCategory.outfit,
      emoji: '🦺',
      description: 'Modern cyberpunk-inspired utility vest and clean tech gear.',
      requiredLevel: 5,
      minimumStage: DevelopmentalStage.highSchool,
      primaryColor: Color(0xFF0F172A),
      secondaryColor: Color(0xFF06B6D4),
    ),
    WardrobeItem(
      id: 'collegiateChic',
      name: 'Collegiate Chic Blazer',
      category: WardrobeCategory.outfit,
      emoji: '👗',
      description: 'Refined university knit sweater and tailored blazer.',
      requiredLevel: 6,
      minimumStage: DevelopmentalStage.university,
      primaryColor: Color(0xFF334155),
      secondaryColor: Color(0xFFE2E8F0),
    ),
    WardrobeItem(
      id: 'executiveSuit',
      name: 'Cosmic Executive Suit',
      category: WardrobeCategory.outfit,
      emoji: '🕴️',
      description: 'Power blazer for internship presentations and thesis defenses.',
      requiredLevel: 8,
      minimumStage: DevelopmentalStage.university,
      primaryColor: Color(0xFF1E293B),
      secondaryColor: Color(0xFFF59E0B),
    ),
    WardrobeItem(
      id: 'graduationGown',
      name: 'University Graduation Regalia',
      category: WardrobeCategory.outfit,
      emoji: '🎓',
      description: 'Honor graduate ceremonial gown with starlight sash.',
      requiredLevel: 10,
      minimumStage: DevelopmentalStage.university,
      primaryColor: Color(0xFF1E1B4B),
      secondaryColor: Color(0xFFFFD700),
    ),
  ];

  // ── Accessories ────────────────────────────────────────────────────────────
  static const List<WardrobeItem> accessories = [
    WardrobeItem(
      id: 'starPin',
      name: 'Golden Star Pin',
      category: WardrobeCategory.accessory,
      emoji: '⭐',
      description: 'A modest golden star pin earned upon completing day 1.',
      requiredLevel: 1,
    ),
    WardrobeItem(
      id: 'none',
      name: 'None',
      category: WardrobeCategory.accessory,
      emoji: '❌',
      description: 'Clean minimalist look without head accessories.',
      requiredLevel: 1,
    ),
    WardrobeItem(
      id: 'glasses',
      name: 'Focus Reading Glasses',
      category: WardrobeCategory.accessory,
      emoji: '👓',
      description: 'Chic rounded tortoiseshell glasses that aid reading immersion.',
      requiredLevel: 2,
    ),
    WardrobeItem(
      id: 'catHeadphones',
      name: 'Cosmic Audio Headphones',
      category: WardrobeCategory.accessory,
      emoji: '🎧',
      description: 'Noise-cancelling study headphones with glowing celestial earcups.',
      requiredLevel: 3,
    ),
    WardrobeItem(
      id: 'nebulaBackpack',
      name: 'Nebula Explorer Backpack',
      category: WardrobeCategory.accessory,
      emoji: '🎒',
      description: 'Spacious starlight backpack for notebooks and laptop.',
      requiredLevel: 4,
    ),
    WardrobeItem(
      id: 'wisdomBrooch',
      name: 'Athena Wisdom Brooch',
      category: WardrobeCategory.accessory,
      emoji: '🦉',
      description: 'Intricate silver owl brooch awarded for academic rigor.',
      requiredLevel: 6,
    ),
    WardrobeItem(
      id: 'graduationCap',
      name: 'Golden Tassel Cap',
      category: WardrobeCategory.accessory,
      emoji: '🎓',
      description: 'Ceremonial mortarboard with sparkling gold tassel.',
      requiredLevel: 9,
      minimumStage: DevelopmentalStage.university,
    ),
  ];

  // ── Auras ──────────────────────────────────────────────────────────────────
  static const List<WardrobeItem> auras = [
    WardrobeItem(
      id: 'auto',
      name: 'Live Performance Mirror',
      category: WardrobeCategory.aura,
      emoji: '🪞',
      description: 'Dynamically transforms color and energy based on today\'s score & streak!',
      requiredLevel: 1,
    ),
    WardrobeItem(
      id: 'supernova',
      name: 'Supernova Radiance',
      category: WardrobeCategory.aura,
      emoji: '🌟',
      description: 'A permanent gleaming halo of brilliant golden starlight.',
      requiredLevel: 5,
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFFF80AB),
    ),
    WardrobeItem(
      id: 'streakFlame',
      name: 'Solar Plasma Flame',
      category: WardrobeCategory.aura,
      emoji: '🔥',
      description: 'A crackling solar flame aura honoring relentless daily streaks.',
      requiredLevel: 4,
      requiredStreak: 7,
      primaryColor: Color(0xFFFF6D00),
      secondaryColor: Color(0xFFFFEA00),
    ),
    WardrobeItem(
      id: 'zenScholar',
      name: 'Serene Starlight Zen',
      category: WardrobeCategory.aura,
      emoji: '🧘‍♀️',
      description: 'A calm, tranquil cyan ring that fosters deep uninterrupted concentration.',
      requiredLevel: 3,
      primaryColor: Color(0xFF00E5FF),
      secondaryColor: Color(0xFF6C63FF),
    ),
    WardrobeItem(
      id: 'cosmicGalaxy',
      name: 'Galactic Vortex',
      category: WardrobeCategory.aura,
      emoji: '🌌',
      description: 'Swirling spiral galaxy with drifting star clusters.',
      requiredLevel: 8,
      primaryColor: Color(0xFF9C27B0),
      secondaryColor: Color(0xFF3F51B5),
    ),
  ];

  static List<WardrobeItem> getByCategory(WardrobeCategory category) {
    switch (category) {
      case WardrobeCategory.skinTone:
        return skinTones;
      case WardrobeCategory.hairStyle:
        return hairStyles;
      case WardrobeCategory.hairColor:
        return hairColors;
      case WardrobeCategory.outfit:
        return outfits;
      case WardrobeCategory.accessory:
        return accessories;
      case WardrobeCategory.aura:
        return auras;
    }
  }

  static WardrobeItem? findItem(String id) {
    for (final list in [skinTones, hairStyles, hairColors, outfits, accessories, auras]) {
      for (final item in list) {
        if (item.id == id) return item;
      }
    }
    return null;
  }
}
