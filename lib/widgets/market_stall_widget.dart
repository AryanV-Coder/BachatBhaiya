import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/player_model.dart';

class MarketWidget extends StatefulWidget {
  final PlayerModel player;
  final VoidCallback onBalanceChanged;

  const MarketWidget({
    super.key,
    required this.player,
    required this.onBalanceChanged,
  });

  @override
  State<MarketWidget> createState() => MarketWidgetState();
}

class MarketWidgetState extends State<MarketWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  static void openMarket(
    BuildContext context,
    PlayerModel player,
    VoidCallback onUpdate,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _MarketOverlay(
        player: player,
        onPurchase: (item) {
          if (item.price > 0) {
            player.totalBalance -= item.price;
            item.owned = true;
          }
          item.quantity += 1;
          onUpdate();
        },
        onRent: (item, days) {
          if (item.rentalPrice != null) {
            int totalCost = item.rentalPrice! * days;
            if (player.totalBalance >= totalCost) {
              player.totalBalance -= totalCost;
              // Add to rented items
              player.rentedItems.add(
                RentedItem(
                  item: item,
                  expiryTime: DateTime.now().add(Duration(days: days)),
                  durationDays: days,
                ),
              );
              onUpdate();
            }
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(
      begin: 0,
      end: -5,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  // Opens the market panel as a dialog overlay
  void _openMarket(BuildContext context) {
    MarketWidgetState.openMarket(context, widget.player, () {
      if (mounted) setState(() {});
      widget.onBalanceChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMarket(context),
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _bounceAnim.value),
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Market stall graphic
            Container(
              width: 160,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(3, 4),
                  ),
                ],
                border: Border.all(color: Colors.amber.shade600, width: 2),
              ),
              child: Stack(
                children: [
                  // Tent stripes
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomPaint(painter: _TentStripePainter()),
                    ),
                  ),
                  // Market icon and label
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/market.png',
                          width: 90,
                        ), // Replaced emoji with image
                        const SizedBox(height: 6),
                        const Text(
                          'MARKET',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // "TAP" hint badge
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'TAP',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Market name label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.marketDark.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Village Market',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── The Market Overlay (shown as centered dialog when market is tapped) ────
class _MarketOverlay extends StatefulWidget {
  final PlayerModel player;
  final Function(MarketItem) onPurchase;
  final Function(MarketItem, int) onRent; // Added days parameter

  const _MarketOverlay({
    required this.player,
    required this.onPurchase,
    required this.onRent,
  });

  @override
  State<_MarketOverlay> createState() => _MarketOverlayState();
}

class _MarketOverlayState extends State<_MarketOverlay> {
  bool _isBuyMode = true; // BUY or RENTAL STORE
  String? _selectedCategory; // 'seeds', 'equipment', 'vehicle', 'labor'
  String? _selectedProductName; // Unique product name (e.g. 'Wheat')

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width * 0.75,
          height: size.height * 0.65,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0E1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFB0A080), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Row(
              children: [
                // ── Left: Shopkeeper ──
                SizedBox(
                  width: size.width * 0.25, // Increased width
                  child: Stack(
                    clipBehavior: Clip.none, // Allow overflowing if needed
                    children: [
                      Positioned(
                        bottom: -10, // Adjusted
                        left: -20, // Adjusted
                        right: -20, // Adjusted
                        child: Image.asset(
                          'assets/images/seller.png',
                          height: size.height * 0.65, // Explicit height
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Right: Content ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top Bar ──
                        Row(
                          children: [
                            if (_selectedCategory == null) ...[
                              _buildTabButton('BUY', _isBuyMode, () {
                                setState(() {
                                  _isBuyMode = true;
                                });
                              }),
                              const SizedBox(width: 10),
                              _buildTabButton('RENTAL STORE', !_isBuyMode, () {
                                setState(() {
                                  _isBuyMode = false;
                                });
                              }),
                            ] else ...[
                              _buildBackButton(),
                            ],
                            const Spacer(),
                            Text(
                              _selectedCategory == null
                                  ? 'MARKET'
                                  : _selectedCategory!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Content Area ──
                        Expanded(
                          child: _selectedCategory == null
                              ? _buildCategoryCards()
                              : _selectedProductName == null
                              ? _buildProductGrid()
                              : _buildQualitySubMenu(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD5C8A8) : const Color(0xFFE8E0CC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFB0A080), width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isActive ? Colors.black87 : Colors.black45,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedProductName != null) {
            _selectedProductName = null;
          } else {
            _selectedCategory = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD5C8A8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB0A080)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, size: 16, color: Colors.black87),
            SizedBox(width: 4),
            Text(
              'Back',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCards() {
    // Rental store excludes seeds
    final List<Map<String, String>> categories = [
      if (_isBuyMode) {'label': 'SEEDS', 'emoji': '🌾', 'id': 'seeds'},
      {'label': 'EQUIPMENT', 'emoji': '🔧', 'id': 'equipment'},
      {'label': 'VEHICLE', 'emoji': '🚜', 'id': 'vehicle'},
      {'label': 'LABOUR', 'emoji': '👷', 'id': 'labor'},
    ];

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildCategoryCard(cat['label']!, cat['emoji']!, () {
                setState(() => _selectedCategory = cat['id']);
              }),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String label, String emoji, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD5C8A8), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    // Get unique products by name in the selected category
    final itemsInCategory = widget.player.marketItems
        .where((item) => item.category == _selectedCategory)
        .toList();

    // In Rental mode, ensure item has a rental price
    final filteredItems = _isBuyMode
        ? itemsInCategory
        : itemsInCategory.where((item) => item.rentalPrice != null).toList();

    final uniqueProductNames = filteredItems
        .map((i) => i.name)
        .toSet()
        .toList();

    return Column(
      children: [
        _buildBalanceDisplay(),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: uniqueProductNames.length,
            itemBuilder: (context, index) {
              final name = uniqueProductNames[index];
              final sampleItem = filteredItems.firstWhere(
                (i) => i.name == name,
              );
              return _ProductCard(
                name: name,
                emoji: sampleItem.emoji,
                onTap: () {
                  setState(() => _selectedProductName = name);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQualitySubMenu() {
    final variations = widget.player.marketItems
        .where(
          (i) =>
              i.name == _selectedProductName && i.category == _selectedCategory,
        )
        .toList();

    // In Rental mode, variations must have rental price
    final filteredItems = _isBuyMode
        ? variations
        : variations.where((i) => i.rentalPrice != null).toList();

    return Column(
      children: [
        _buildBalanceDisplay(),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return _QualityCard(
                item: item,
                isBuyMode: _isBuyMode,
                playerBalance: widget.player.totalBalance,
                onAction: () {
                  if (_isBuyMode) {
                    if (widget.player.totalBalance >= item.price) {
                      widget.onPurchase(item);
                      setState(() {});
                    } else {
                      _showNoFunds();
                    }
                  } else {
                    _showRentalDurationDialog(item);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showRentalDurationDialog(MarketItem item) {
    int selectedDays = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Rent ${item.name}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How many days would you like to rent for?'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: selectedDays > 1
                        ? () => setDialogState(() => selectedDays--)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$selectedDays Days',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: selectedDays < 30
                        ? () => setDialogState(() => selectedDays++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Total Cost: ₹${(item.rentalPrice ?? 0) * selectedDays}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.player.totalBalance >=
                    (item.rentalPrice ?? 0) * selectedDays) {
                  widget.onRent(item, selectedDays);
                  Navigator.pop(ctx);
                  setState(() {});
                } else {
                  _showNoFunds();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'CONFIRM RENTAL',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceDisplay() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.currency_rupee, color: Colors.amber, size: 16),
            Text(
              '${widget.player.totalBalance}',
              style: const TextStyle(
                color: Color(0xFF8B6914),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoFunds() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not enough balance! 💰'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final String emoji;
  final VoidCallback onTap;

  const _ProductCard({
    required this.name,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD5C8A8), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityCard extends StatelessWidget {
  final MarketItem item;
  final bool isBuyMode;
  final int playerBalance;
  final VoidCallback onAction;

  const _QualityCard({
    required this.item,
    required this.isBuyMode,
    required this.playerBalance,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final price = isBuyMode ? item.price : (item.rentalPrice ?? 0);
    final canAfford = playerBalance >= price;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD5C8A8)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDDE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.category == 'seeds')
                  Text(
                    'Growth: ${item.growthDays} days | Profit: ₹${item.profit}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  )
                else ...[
                  if (item.description != null)
                    Text(
                      item.description!,
                      style: const TextStyle(
                        color: Colors.brown,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    isBuyMode
                        ? 'Purchase for permanent use'
                        : 'Rent per ${item.rentalUnit}',
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isBuyMode ? 'BUY ₹$price' : 'RENT ₹$price',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painter for the tent stripe decoration on the market stall ─────────────
class _TentStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width + size.height; x += 14) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter _) => false;
}
