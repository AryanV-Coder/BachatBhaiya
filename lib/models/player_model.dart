enum ItemQuality { worst, medium, high }

class MarketItem {
  final String name;
  final String emoji;
  final String category;
  final ItemQuality quality;
  final int price;
  final int? rentalPrice;
  final String rentalUnit;
  final int? growthDays; // For seeds
  final int? profit; // For seeds
  final String? description; // For quality details
  bool owned;
  int quantity;

  MarketItem({
    required this.name,
    required this.emoji,
    required this.category,
    required this.quality,
    required this.price,
    this.description,
    this.rentalPrice,
    this.rentalUnit = 'day',
    this.growthDays,
    this.profit,
    this.owned = false,
    this.quantity = 0,
  });

  String get qualityLabel {
    switch (quality) {
      case ItemQuality.worst:
        return 'Worst Quality';
      case ItemQuality.medium:
        return 'Medium Quality';
      case ItemQuality.high:
        return 'High Quality';
    }
  }
}

class RentedItem {
  final MarketItem item;
  final DateTime expiryTime;
  final int durationDays;

  RentedItem({
    required this.item,
    required this.expiryTime,
    required this.durationDays,
  });

  Duration get remainingTime => expiryTime.difference(DateTime.now());
}

class StoredCrop {
  final String name;
  final String emoji;
  int quantity;
  final int sellPrice;

  StoredCrop({
    required this.name,
    required this.emoji,
    this.quantity = 0,
    required this.sellPrice,
  });
}

class LandSegment {
  final int id;
  bool isOwned;
  bool isPloughed;
  double ploughProgress; // 0.0 to 1.0
  MarketItem? sownCrop;
  DateTime? sowTime;
  final int purchasePrice;

  LandSegment({
    required this.id,
    this.isOwned = false,
    this.isPloughed = false,
    this.ploughProgress = 0.0,
    this.sownCrop,
    this.sowTime,
    this.purchasePrice = 1000,
  });

  bool get isReadyToHarvest {
    if (sownCrop == null || sowTime == null) return false;
    // Using minutes instead of days for game testing
    return DateTime.now().difference(sowTime!) >=
        Duration(minutes: sownCrop!.growthDays ?? 0);
  }
}

class PlayerModel {
  final String name;
  double levelProgress;
  double emergencyFund;
  int totalBalance;
  int level;
  int paristhitiQuestionsAsked;

  // Storage for harvested crops
  List<StoredCrop> storageInventory = [];
  // Rented equipment/vehicles/labor
  List<RentedItem> rentedItems = [];

  // 2x2 Grid of land segments
  List<LandSegment> landSegments = [
    LandSegment(id: 0, isOwned: true), // Top-left owned
    LandSegment(id: 1, isOwned: false, purchasePrice: 10000),
    LandSegment(id: 2, isOwned: false, purchasePrice: 16000),
    LandSegment(id: 3, isOwned: false, purchasePrice: 30000),
  ];

  // Market items
  List<MarketItem> marketItems = [
    // Wheat
    MarketItem(
      name: 'Wheat',
      emoji: '🌾',
      category: 'seeds',
      quality: ItemQuality.worst,
      price: 600,
      growthDays: 1,
      profit: 1600,
    ),
    MarketItem(
      name: 'Wheat',
      emoji: '🌾',
      category: 'seeds',
      quality: ItemQuality.medium,
      price: 1200,
      growthDays: 2,
      profit: 3000,
    ),
    MarketItem(
      name: 'Wheat',
      emoji: '🌾',
      category: 'seeds',
      quality: ItemQuality.high,
      price: 2400,
      growthDays: 3,
      profit: 6000,
    ),
    // Sickle
    MarketItem(
      name: 'Sickle',
      emoji: '🔪',
      category: 'equipment',
      quality: ItemQuality.worst,
      price: 3000,
      rentalPrice: 200,
      description: 'Old, rusty, and blunt. Hard to use.',
    ),
    MarketItem(
      name: 'Sickle',
      emoji: '🔪',
      category: 'equipment',
      quality: ItemQuality.medium,
      price: 6000,
      rentalPrice: 500,
      description: 'Standard steel sickle. Reliable.',
    ),
    MarketItem(
      name: 'Sickle',
      emoji: '🔪',
      category: 'equipment',
      quality: ItemQuality.high,
      price: 12000,
      rentalPrice: 1000,
      description: 'High-carbon steel. Sharp and efficient.',
    ),
    // Vehicles
    MarketItem(
      name: 'Bullock Cart',
      emoji: '🐃',
      category: 'vehicle',
      quality: ItemQuality.worst,
      price: 100000,
      rentalPrice: 4000,
      description: 'Slow but traditional. Relies on animal power.',
    ),
    MarketItem(
      name: 'Tractor',
      emoji: '🚜',
      category: 'vehicle',
      quality: ItemQuality.worst,
      price: 300000,
      rentalPrice: 20000,
      description: '15 years old, rusty, slow. Frequent breakdowns.',
    ),
    MarketItem(
      name: 'Tractor',
      emoji: '🚜',
      category: 'vehicle',
      quality: ItemQuality.medium,
      price: 900000,
      rentalPrice: 60000,
      description: 'Reliable utility tractor. Good for most tasks.',
    ),
    MarketItem(
      name: 'Tractor',
      emoji: '🚜',
      category: 'vehicle',
      quality: ItemQuality.high,
      price: 2400000,
      rentalPrice: 160000,
      description: 'New, fast and efficient. Latest technology.',
    ),
    // Labor
    MarketItem(
      name: 'Farm Help',
      emoji: '👨‍🌾',
      category: 'labor',
      quality: ItemQuality.worst,
      price: 0,
      rentalPrice: 4000,
      description: 'Unskilled daily wager. Needs supervision.',
    ),
    MarketItem(
      name: 'Farm Help',
      emoji: '👨‍🌾',
      category: 'labor',
      quality: ItemQuality.medium,
      price: 0,
      rentalPrice: 10000,
      description: 'Experienced farmer. Knows basic techniques.',
    ),
    MarketItem(
      name: 'Farm Help',
      emoji: '👨‍🌾',
      category: 'labor',
      quality: ItemQuality.high,
      price: 0,
      rentalPrice: 24000,
      description: 'Expert agriculturist. Maximizes yield.',
    ),
  ];

  // Stock market data
  List<StockItem> marketStocks = [
    StockItem(
      name: 'NIFTY 50',
      currentPrice: 22345.67,
      changePercent: 0.45,
      high: 22410,
      low: 22290,
      isIndex: true,
      history: [22100, 22250, 22180, 22300, 22345.67],
    ),
    StockItem(
      name: 'NIFTY NEXT 50',
      currentPrice: 48123.45,
      changePercent: 0.65,
      high: 48250,
      low: 48010,
      isIndex: true,
      history: [47800, 47950, 48100, 48050, 48123.45],
    ),
    StockItem(
      name: 'NIFTY MIDCAP 50',
      currentPrice: 14567.89,
      changePercent: 0.32,
      high: 14620,
      low: 14510,
      isIndex: true,
      history: [14400, 14500, 14480, 14550, 14567.89],
    ),
    StockItem(
      name: 'TCS',
      currentPrice: 4012.34,
      changePercent: 0.78,
      high: 4035,
      low: 3995,
      isIndex: false,
      history: [3950, 3980, 4000, 3990, 4012.34],
    ),
  ];

  PlayerModel({
    required this.name,
    this.levelProgress = 0.45,
    this.emergencyFund = 6000,
    this.totalBalance = 40000,
    this.level = 1,
    this.paristhitiQuestionsAsked = 0,
  });
}

class StockItem {
  final String name;
  final double currentPrice;
  final double changePercent;
  final double high;
  final double low;
  final bool isIndex;
  final List<double> history;
  int ownedShares;

  StockItem({
    required this.name,
    required this.currentPrice,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.isIndex,
    required this.history,
    this.ownedShares = 0,
  });
}
