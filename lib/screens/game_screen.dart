import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../models/player_model.dart';
import '../widgets/hud_bar.dart';
import '../widgets/sidebar_button.dart';
import '../widgets/village_life.dart';
import '../widgets/stock_market_overlay.dart';
import '../widgets/market_stall_widget.dart';
import '../widgets/financial_quiz_overlay.dart';
import '../widgets/paristhiti_overlay.dart';
import '../widgets/storage_overlay.dart';
import '../widgets/profile_overlay.dart';
import '../widgets/chat_overlay.dart';
import '../world/background_world.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final PlayerModel _player = PlayerModel(name: 'Farmer');

  bool _isParisthitiMode = false;
  bool _isQuizMode = false;

  // TransformationController lets us set the initial pan position
  // so the map starts centred rather than at the top-left corner.
  final TransformationController _transformCtrl = TransformationController();

  @override
  void initState() {
    super.initState();

    // After the first frame we know the screen size, so we offset the
    // viewport to start near the centre of the world map.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      // Initial scale set to 0.8 for "less zoom" effect
      const initialScale = 0.8;
      final offsetX = (AppSizes.worldWidth * initialScale - size.width) / 2;
      final offsetY = (AppSizes.worldHeight * initialScale - size.height) / 2;

      _transformCtrl.value = Matrix4.identity()
        ..scale(initialScale, initialScale, 1.0)
        ..translate(-offsetX / initialScale, -offsetY / initialScale, 1.0);
    });
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── LAYER B: 2D-scrollable game world OR Quiz Mode ────────────────────────────
          if (_isQuizMode)
            Positioned.fill(
              child: FinancialQuizOverlay(
                player: _player,
                onQuit: () {
                  setState(() {
                    _isQuizMode = false;
                  });
                },
                onUpdate: () {
                  setState(() {});
                },
              ),
            )
          else if (_isParisthitiMode)
            Positioned.fill(
              child: ParisthitiOverlay(
                player: _player,
                onQuit: () {
                  setState(() {
                    _isParisthitiMode = false;
                  });
                },
                onUpdate: () {
                  setState(() {});
                },
              ),
            )
          else
            // InteractiveViewer provides map-style panning in ALL directions.
            // constrained: false  → the child can be larger than the viewport.
            // boundaryMargin      → how far past the edge the user can pan.
            // minScale / maxScale → disable pinch-zoom (set both to 1.0).
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformCtrl,
                constrained: false,
                boundaryMargin: EdgeInsets.zero, // Removed black border/padding
                minScale: 0.5, // Allow zooming out more
                maxScale: 2.0,
                panAxis: PanAxis.free,
                clipBehavior: Clip.none,
                child: SizedBox(
                  width: AppSizes.worldWidth,
                  height: AppSizes.worldHeight,
                  child: Stack(
                    children: [
                      // B1 — background image (non-interactive)
                      const BackgroundWorld(),

                      // B2 — all interactive game objects on top
                      _buildInteractiveLayer(),
                    ],
                  ),
                ),
              ),
            ),

          // ── LAYER C: Fixed HUD (never moves with map) ────────────────────
          if (!_isParisthitiMode && !_isQuizMode) _buildHUD(),

          // ── LAYER D: Fixed left sidebar ──────────────────────────────────
          if (!_isParisthitiMode && !_isQuizMode) _buildSidebar(),

          // ── LAYER E: World name badge ─────────────────────────────────────
          _buildWorldBadge(),
        ],
      ),
    );
  }

  Widget _buildInteractiveLayer() {
    return Stack(
      children: [
        // ── EXTRA HUTS (Village Setting) ──
        Positioned(
          top: 80,
          left: 140,
          child: Image.asset('assets/images/otherHuts.png', width: 220),
        ),
        Positioned(
          top: 250,
          left: 20,
          child: Image.asset('assets/images/otherHuts.png', width: 210),
        ),
        Positioned(
          top: 130,
          left: 530,
          child: Image.asset('assets/images/otherHuts.png', width: 230),
        ),
        Positioned(
          top: 60,
          left: 820,
          child: Image.asset('assets/images/otherHuts.png', width: 200),
        ),
        Positioned(
          top: 380, // Adjusted to avoid potential bush
          left: 750,
          child: Image.asset('assets/images/otherHuts.png', width: 240),
        ),
        Positioned(
          top: 320, // Lowered slightly
          left: 1100, // Moved left to avoid pond
          child: Image.asset('assets/images/otherHuts.png', width: 220),
        ),
        Positioned(
          top: 650, // Adjusted to avoid potential bush
          left: 550,
          child: Image.asset('assets/images/otherHuts.png', width: 230),
        ),

        Positioned(
          top: 150,
          left: 1000,
          child: Image.asset('assets/images/well.png', width: 180),
        ),

        Positioned(
          top: 200,
          left: 1450,
          child: Image.asset('assets/images/pond.png', width: 300),
        ),

        // ── CENTER (Main Screen/Spawn) ──
        // Static Hut image in the center (non-clickable)
        Positioned(
          top: 200,
          left: 1850,
          child: GestureDetector(
            onTap: () => StorageOverlay.openStorage(
              context,
              _player,
              () => setState(() {}),
            ),
            child: Image.asset('assets/images/storage.png', width: 250),
          ),
        ),
        Positioned(
          top: 480,
          left: 1000,
          child: Image.asset('assets/images/hutlevel1.png', width: 300),
        ),

        // ── LEFT SIDE (Market Area) ──
        // Stock Market building
        Positioned(
          top: 350,
          left: 300,
          child: GestureDetector(
            onTap: () => StockMarketOverlay.openMarket(
              context,
              _player,
              () => setState(() {}),
            ),
            child: Image.asset('assets/images/stock_market.png', width: 320),
          ),
        ),

        // Multiple Markets (Crowded look) - Now Clickable
        Positioned(
          top: 750,
          left: 100,
          child: GestureDetector(
            onTap: () => MarketWidgetState.openMarket(
              context,
              _player,
              () => setState(() {}),
            ),
            child: Image.asset('assets/images/market.png', width: 550),
          ),
        ),
        Positioned(
          top: 880,
          left: 80,
          child: GestureDetector(
            onTap: () => MarketWidgetState.openMarket(
              context,
              _player,
              () => setState(() {}),
            ),
            child: Image.asset('assets/images/market.png', width: 550),
          ),
        ),
        Positioned(
          top: 820,
          left: 10,
          child: GestureDetector(
            onTap: () => MarketWidgetState.openMarket(
              context,
              _player,
              () => setState(() {}),
            ),
            child: Image.asset('assets/images/market.png', width: 450),
          ),
        ),

        // ── RIGHT SIDE (Farming Area) ──
        // Fields shifted to bottom right corner with ploughed lines
        Positioned(
          bottom: 50,
          right: 150,
          child: Container(
            width: 550,
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF4E342E),
              border: Border.all(color: const Color(0xFF3E2723), width: 3),
            ),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 275 / 200,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final segment = _player.landSegments[index];
                return GestureDetector(
                  onTap: () => _handleFieldTap(segment),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF3E2723).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Ploughed lines
                        if (segment.isPloughed || segment.ploughProgress > 0)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _PloughedFieldPainter(),
                            ),
                          ),
                        // Sown crop
                        if (segment.sownCrop != null)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  segment.sownCrop!.emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                                if (!segment.isReadyToHarvest)
                                  const Icon(
                                    Icons.timer,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                        // Locked layer
                        if (!segment.isOwned)
                          Positioned.fill(
                            child: Container(
                              color: Colors.grey.withValues(alpha: 0.7),
                              child: const Center(
                                child: Text(
                                  '🔒',
                                  style: TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Farmer closer to the main hut
        Positioned(
          top: 600,
          left: 1000,
          child: Image.asset('assets/images/farmer.png', width: 60),
        ),

        // Fence Enclosure (Moved towards the fields)
        Positioned(
          top: 450, // Moved down towards field level
          left: 1750, // Shifted slightly left towards fields
          child: SizedBox(
            width: 250,
            height: 200,
            child: Stack(
              children: [
                // Top fence
                Positioned(top: 0, left: 0, right: 0, child: _buildFenceRow(3)),
                // Bottom fence
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildFenceRow(3),
                ),
                // Left fence (rotated)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: -20,
                  child: RotatedBox(quarterTurns: 1, child: _buildFenceRow(2)),
                ),
                // Right fence (rotated)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: -20,
                  child: RotatedBox(quarterTurns: 1, child: _buildFenceRow(2)),
                ),
              ],
            ),
          ),
        ),

        // Dynamic Vehicle Parking Area
        _buildParkingAreaItems(),

        // ── VILLAGE LIFE (Animated Characters - MOVED TO FRONT) ──
        Positioned.fill(
          child: IgnorePointer(
            child: VillageLife(
              worldWidth: AppSizes.worldWidth,
              worldHeight: AppSizes.worldHeight,
              obstacles: [
                // Field area
                Rect.fromLTWH(1500, 650, 550, 400),
                // Main Interactive Hut
                Rect.fromLTWH(1000, 480, 280, 200),
                // Storage House
                Rect.fromLTWH(1850, 200, 250, 250),
                // Fence Area
                Rect.fromLTWH(1750, 450, 250, 200),
                // Well
                Rect.fromLTWH(1000, 150, 150, 150),
                // Farmer
                Rect.fromLTWH(930, 520, 90, 90),
                // Pond
                Rect.fromLTWH(1450, 200, 280, 220),
                // Market Stalls
                Rect.fromLTWH(100, 750, 550, 150),
                Rect.fromLTWH(80, 880, 550, 150),
                Rect.fromLTWH(10, 820, 450, 150),
                // Stock Market
                Rect.fromLTWH(300, 350, 300, 250),
                // Other Huts
                Rect.fromLTWH(140, 80, 220, 160),
                Rect.fromLTWH(20, 250, 210, 150),
                Rect.fromLTWH(530, 130, 230, 170),
                Rect.fromLTWH(820, 60, 220, 150),
                Rect.fromLTWH(750, 380, 240, 180),
                Rect.fromLTWH(1080, 320, 240, 160),
                Rect.fromLTWH(540, 650, 240, 180),
                Rect.fromLTWH(1800, 200, 230, 170), // New hut near pond
                // Fence Area
                Rect.fromLTWH(1750, 450, 250, 200),
                // Tractor (Specific collision box inside the fence)
                Rect.fromLTWH(1790, 490, 140, 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Fixed HUD ────────────────────────────────────────────────────────────
  Widget _buildHUD() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSizes.sidebarWidth),
              Expanded(
                child: HudBar(
                  label: 'Level Progress',
                  progress: _player.levelProgress,
                  barColor: const Color(0xFFFF9933), // Tiranga Saffron
                  icon: Icons.star,
                  iconColor: const Color(0xFFFF9933),
                  textColor: const Color(0xFFE65100), // Deeper saffron for text
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HudBar(
                  label: 'Emergency Fund',
                  progress: null, // Bar removed as requested
                  balanceText: '₹${_player.emergencyFund.toInt()}',
                  barColor: Colors.white,
                  icon: Icons.shield,
                  iconColor: const Color(0xFF000080), // Tiranga Navy Blue
                  textColor: const Color(0xFF000080),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HudBar(
                  label: 'Total Balance',
                  balanceText: '₹${_player.totalBalance}',
                  barColor: const Color(0xFF138808), // Tiranga Green
                  icon: Icons.currency_rupee,
                  iconColor: const Color(0xFF138808),
                  textColor: const Color(0xFF1B5E20), // Deeper green for text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Positioned(
      left: 8,
      top: AppSizes.hudHeight + 10,
      child: Column(
        children: [
          SidebarButton(
            imagePath: 'assets/images/farmer.png',
            label: 'Profile',
            color: const Color(0xFFFF9933), // Tiranga Saffron
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ProfileOverlay(
                  player: _player,
                  onClose: () => Navigator.pop(context),
                ),
              );
            },
          ),
          SidebarButton(
            icon: Icons.chat_bubble,
            label: 'Chat',
            color: const Color(0xFF000080), // Tiranga Navy (for White section)
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ChatOverlay(
                  player: _player,
                  adjustBalance: (delta) {
                    setState(() {
                      _player.totalBalance += delta;
                    });
                  },
                  onClose: () => Navigator.pop(context),
                ),
              );
            },
          ),
          SidebarButton(
            imagePath: 'assets/images/quiz.png',
            label: 'Quiz',
            color: const Color(0xFF138808), // Tiranga Green
            onTap: () {
              setState(() {
                _isQuizMode = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorldBadge() {
    if (_isQuizMode) {
      return Positioned(
        top: 100,
        right: 18,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isQuizMode = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.exit_to_app, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'QUIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isParisthitiMode) {
      return Positioned(
        top: 100, // Positioned below the expanded HUD
        right: 18,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isParisthitiMode = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'BACK ->',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return Positioned(
      top: 100, // Positioned below the expanded HUD
      right: 18,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isParisthitiMode = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/bg.png'),
              fit: BoxFit.fill, // Stretches to fit the exact box size
              opacity: 0.9,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            // Constraints to keep it sized reasonably while allowing content to fit
            constraints: const BoxConstraints(minWidth: 140, minHeight: 90),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                SizedBox(height: 8),
                Text(
                  'Paristhiti AI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParkingAreaItems() {
    final vehicles = _player.marketItems
        .where((item) => item.category == 'vehicle' && (item.owned || _player.rentedItems.any((r) => r.item.name == item.name)))
        .toList();

    return Stack(
      children: [
        if (vehicles.any((v) => v.name == 'Bullock Cart'))
          Positioned(
            top: 480,
            left: 1760,
            child: Image.asset('assets/images/bullockCart.png', width: 140),
          ),
        if (vehicles.any((v) => v.name == 'Tractor'))
          Positioned(
            top: 530,
            left: 1840,
            child: const Text('🚜', style: TextStyle(fontSize: 80)),
          ),
      ],
    );
  }

  void _dialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFieldTap(LandSegment segment) {
    if (!segment.isOwned) {
      _confirmLandPurchase(segment);
    } else if (!segment.isPloughed) {
      _showPloughOptions(segment);
    } else if (segment.sownCrop == null) {
      _showSeedSelection(segment);
    } else if (segment.isReadyToHarvest) {
      _confirmHarvest(segment);
    } else {
      _dialog(
        'Crop Growing',
        'This ${segment.sownCrop!.name} is still growing. Please wait for it to mature!',
      );
    }
  }

  void _showPloughOptions(LandSegment segment) {
    final vehicles = _player.marketItems
        .where((item) => item.category == 'vehicle' && item.owned)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Plough Field?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a vehicle to plough the field:'),
            const SizedBox(height: 16),
            if (vehicles.isEmpty)
              const Text(
                'You don\'t own any vehicles! You can buy/rent one at the Market.',
                style: TextStyle(color: Colors.red),
              )
            else
              ...vehicles.map(
                (v) => ListTile(
                  leading: Text(v.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(v.name),
                  subtitle: Text(
                    v.name == 'Tractor'
                        ? 'Fast - Takes 10s'
                        : 'Slower - Takes 30s',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _startPloughing(segment, v);
                  },
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  void _startPloughing(LandSegment segment, MarketItem vehicle) {
    // Determine time based on quality/type
    int seconds = 30; // Default (Bullock Cart)
    if (vehicle.name == 'Tractor') {
      switch (vehicle.quality) {
        case ItemQuality.high:
          seconds = 5;
          break;
        case ItemQuality.medium:
          seconds = 10;
          break;
        case ItemQuality.worst:
          seconds = 20;
          break;
      }
    }

    setState(() {
      segment.ploughProgress = 0.1; // Start progress
    });

    _showPloughingProgress(segment, seconds);
  }

  void _showPloughingProgress(LandSegment segment, int seconds) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (segment.ploughProgress < 1.0) {
              setState(() {
                segment.ploughProgress += 0.1 / seconds; // Approximate
                if (segment.ploughProgress >= 1.0) {
                  segment.ploughProgress = 1.0;
                  segment.isPloughed = true;
                  Navigator.pop(ctx);
                }
              });
              setDialogState(() {});
            }
          });

          return AlertDialog(
            title: const Text('Ploughing in progress...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: segment.ploughProgress),
                const SizedBox(height: 8),
                Text('${(segment.ploughProgress * 100).toInt()}% Complete'),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmLandPurchase(LandSegment segment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Expand Your Farm?'),
        content: Text(
          'Do you want to buy this plot of land for ₹${segment.purchasePrice}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('MAYBE LATER'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_player.totalBalance >= segment.purchasePrice) {
                setState(() {
                  _player.totalBalance -= segment.purchasePrice;
                  segment.isOwned = true;
                });
                Navigator.pop(ctx);
              } else {
                _dialog(
                  'Insufficient Funds',
                  'You need more money to buy land!',
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              'PURCHASE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSeedSelection(LandSegment segment) {
    final ownedSeeds = _player.marketItems
        .where((item) => item.category == 'seeds' && item.quantity > 0)
        .toList();

    if (ownedSeeds.isEmpty) {
      _dialog(
        'No Seeds',
        'You don\'t have any seeds! Visit the Market to buy some.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Seed to Sow'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ownedSeeds.length,
            itemBuilder: (context, index) {
              final seed = ownedSeeds[index];
              return ListTile(
                leading: Text(seed.emoji, style: const TextStyle(fontSize: 24)),
                title: Text('${seed.name} (${seed.qualityLabel})'),
                subtitle: Text(
                  'Qty: ${seed.quantity} | Growth: ${seed.growthDays} mins',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmSow(segment, seed);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmSow(LandSegment segment, MarketItem seed) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sow Seed?'),
        content: Text('Do you want to sow ${seed.name} on this plot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                seed.quantity -= 1;
                segment.sownCrop = seed;
                segment.sowTime = DateTime.now();
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('SOW', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmHarvest(LandSegment segment) {
    final crop = segment.sownCrop!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ready to Harvest!'),
        content: Text(
          'Do you want to harvest this ${crop.name}? It will be moved to storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('NOT YET'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Add to storage
                try {
                  final storedItem = _player.storageInventory.firstWhere(
                    (item) => item.name == crop.name,
                  );
                  storedItem.quantity += 1;
                } catch (e) {
                  final newItem = StoredCrop(
                    name: crop.name,
                    emoji: crop.emoji,
                    quantity: 1,
                    sellPrice: crop.profit ?? 0,
                  );
                  _player.storageInventory.add(newItem);
                }

                // Clear segment
                segment.sownCrop = null;
                segment.sowTime = null;
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('HARVEST', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFenceRow(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Image.asset('assets/images/fence.png', width: 80),
      ),
    );
  }
}

class _PloughedFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3E2723).withValues(alpha: 0.4)
      ..strokeWidth = 2;

    for (double i = 10; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
