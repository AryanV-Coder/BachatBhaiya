import 'package:flutter/material.dart';
import '../models/player_model.dart';

class StorageOverlay {
  static void openStorage(
    BuildContext context,
    PlayerModel player,
    VoidCallback onUpdate,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _StoragePanel(player: player, onUpdate: onUpdate),
    );
  }
}

class _StoragePanel extends StatefulWidget {
  final PlayerModel player;
  final VoidCallback onUpdate;

  const _StoragePanel({required this.player, required this.onUpdate});

  @override
  State<_StoragePanel> createState() => _StoragePanelState();
}

class _StoragePanelState extends State<_StoragePanel> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final inventory = widget.player.storageInventory;
    final ownedItems = widget.player.marketItems.where((item) => item.owned && item.category != 'seeds').toList();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width * 0.7,
          height: size.height * 0.6,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0E1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFB0A080), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8E0CC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '📦 VILLAGE STORAGE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: (inventory.isEmpty && widget.player.rentedItems.isEmpty && ownedItems.isEmpty)
                    ? Center(
                        child: Text(
                          'Your storage is empty.\nHarvest some crops or rent equipment!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.brown.shade300,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          if (inventory.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                'CROP INVENTORY',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 180,
                              child: GridView.builder(
                                padding: const EdgeInsets.all(20),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 15,
                                      mainAxisSpacing: 15,
                                      childAspectRatio: 0.8,
                                    ),
                                itemCount: inventory.length,
                                itemBuilder: (context, index) {
                                  final item = inventory[index];
                                  return _StorageItemCard(
                                    item: item,
                                    onSell: () => _confirmSell(item),
                                  );
                                },
                              ),
                            ),
                          ],
                          if (ownedItems.isNotEmpty) ...[
                            const Divider(),
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                'OWNED ITEMS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 180,
                              child: GridView.builder(
                                padding: const EdgeInsets.all(20),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 15,
                                      mainAxisSpacing: 15,
                                      childAspectRatio: 0.8,
                                    ),
                                itemCount: ownedItems.length,
                                itemBuilder: (context, index) {
                                  final item = ownedItems[index];
                                  return _OwnedItemCard(item: item);
                                },
                              ),
                            ),
                          ],
                          if (widget.player.rentedItems.isNotEmpty) ...[
                            const Divider(),
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                'RENTED ITEMS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: widget.player.rentedItems.length,
                                itemBuilder: (context, index) {
                                  final rented =
                                      widget.player.rentedItems[index];
                                  return _RentedItemCard(rented: rented);
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
              ),

              // Close Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D4037),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'BACK TO VILLAGE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSell(StoredCrop item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sell ${item.name}?'),
        content: Text(
          'Do you want to sell 1 ${item.name} for ₹${item.sellPrice}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (item.quantity > 0) {
                  item.quantity -= 1;
                  widget.player.totalBalance += item.sellPrice;
                  if (item.quantity == 0) {
                    widget.player.storageInventory.remove(item);
                  }
                }
              });
              widget.onUpdate();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('SELL'),
          ),
        ],
      ),
    );
  }
}

class _StorageItemCard extends StatelessWidget {
  final StoredCrop item;
  final VoidCallback onSell;

  const _StorageItemCard({required this.item, required this.onSell});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSell,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD5C8A8)),
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
            Text(item.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDDE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Qty: ${item.quantity}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${item.sellPrice} each',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnedItemCard extends StatelessWidget {
  final MarketItem item;

  const _OwnedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD5C8A8)),
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
          Text(item.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDDE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Qty: ${item.quantity}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.qualityLabel,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RentedItemCard extends StatelessWidget {
  final RentedItem rented;

  const _RentedItemCard({required this.rented});

  @override
  Widget build(BuildContext context) {
    final remaining = rented.remainingTime;
    final isExpired = remaining.isNegative;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? Colors.red.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Text(rented.item.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rented.item.name} (${rented.item.qualityLabel})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  isExpired
                      ? 'EXPIRED'
                      : 'Expires in: ${remaining.inDays}d ${remaining.inHours % 24}h ${remaining.inMinutes % 60}m',
                  style: TextStyle(
                    color: isExpired ? Colors.red : Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
