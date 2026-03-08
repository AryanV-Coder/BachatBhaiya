import 'package:flutter/material.dart';
import '../models/player_model.dart';

class FieldOverlay {
  static void openField(BuildContext context, PlayerModel player) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _FieldPanel(player: player),
    );
  }
}

class _FieldPanel extends StatelessWidget {
  final PlayerModel player;

  const _FieldPanel({required this.player});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ownedSeeds = player.marketItems
        .where((s) => s.category == 'seeds' && s.owned)
        .toList();

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
                // ── Left: Farmer Character ──
                SizedBox(
                  width: size.width * 0.2,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          'assets/images/farmer.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Right: Owned Seeds ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ownedSeeds.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🏜️',
                                  style: TextStyle(fontSize: 30),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No seeds yet!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown.shade400,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(4),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.9,
                                ),
                            itemCount: ownedSeeds.length,
                            itemBuilder: (context, index) {
                              final seed = ownedSeeds[index];
                              return _OwnedSeedCard(seed: seed);
                            },
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
}

class _OwnedSeedCard extends StatelessWidget {
  final MarketItem seed;

  const _OwnedSeedCard({required this.seed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8BC34A), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(seed.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(
            '${seed.name} (${seed.quality.name})',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF8BC34A).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'x${seed.quantity}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF33691E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
