import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/player_model.dart';
import 'dart:math';

class StockMarketOverlay {
  static void openMarket(
    BuildContext context,
    PlayerModel player,
    VoidCallback onUpdate,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _StockMarketPanel(player: player, onUpdate: onUpdate),
    );
  }
}

class _StockMarketPanel extends StatelessWidget {
  final PlayerModel player;
  final VoidCallback onUpdate;

  const _StockMarketPanel({required this.player, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width * 0.9,
          height: size.height * 0.75,
          decoration: BoxDecoration(
            color: const Color(0xFFF3EDDE),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDCC8A0), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Balance Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MARKET WATCH: INDICES & STOCKS',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Text(
                        'Balance: ₹${player.totalBalance}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B6914),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Data Table
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: const Color(0xFFDCC8A0)),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.transparent,
                        ),
                        dataRowColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.transparent,
                        ),
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        dataTextStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        columnSpacing: 25,
                        horizontalMargin: 20,
                        showCheckboxColumn:
                            false, // Hides checkboxes when using onSelectChanged
                        columns: const [
                          DataColumn(label: Text('INDEX/STOCK')),
                          DataColumn(
                            label: Text('CURRENT PRICE'),
                            numeric: true,
                          ),
                          DataColumn(label: Text('%CHNG'), numeric: true),
                          DataColumn(label: Text('HIGH'), numeric: true),
                          DataColumn(label: Text('LOW'), numeric: true),
                          DataColumn(label: Text('MY SHARES'), numeric: true),
                        ],
                        rows: List.generate(
                          player.marketStocks.length,
                          (index) => _buildRow(
                            context,
                            player.marketStocks[index],
                            index,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, StockItem stock, int rowIndex) {
    bool positive = stock.changePercent >= 0;
    String prefix = stock.isIndex
        ? (rowIndex == 0 ? '🏳️ ' : '📈 ')
        : (rowIndex % 2 == 0 ? '⚙️ ' : '🏢 ');
    if (stock.name == 'INFOSYS') prefix = '💻 ';
    if (stock.name == 'NIFTY MIDCAP 50') prefix = '';

    return DataRow(
      color: WidgetStateProperty.resolveWith(
        (states) => rowIndex % 2 == 1
            ? Colors.white.withValues(alpha: 0.4)
            : Colors.transparent,
      ),
      onSelectChanged: (_) {
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          builder: (_) => _StockDetailDialog(
            stock: stock,
            player: player,
            onUpdate: onUpdate,
          ),
        );
      },
      cells: [
        DataCell(Text('$prefix${stock.name}')),
        DataCell(Text('₹${stock.currentPrice.toStringAsFixed(2)}')),
        DataCell(
          Text(
            '${positive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
            style: TextStyle(
              color: positive
                  ? const Color(0xFF1E824C)
                  : const Color(0xFFC0392B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(Text('₹${stock.high.toStringAsFixed(0)}')),
        DataCell(Text('₹${stock.low.toStringAsFixed(0)}')),
        DataCell(
          Text(
            '${stock.ownedShares}',
            style: TextStyle(
              color: stock.ownedShares > 0
                  ? Colors.blue.shade700
                  : Colors.black54,
              fontWeight: stock.ownedShares > 0
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _StockDetailDialog extends StatefulWidget {
  final StockItem stock;
  final PlayerModel player;
  final VoidCallback onUpdate;

  const _StockDetailDialog({
    required this.stock,
    required this.player,
    required this.onUpdate,
  });

  @override
  State<_StockDetailDialog> createState() => _StockDetailDialogState();
}

class _StockDetailDialogState extends State<_StockDetailDialog> {
  @override
  Widget build(BuildContext context) {
    bool isPositive = widget.stock.changePercent >= 0;
    Color trendColor = isPositive
        ? const Color(0xFF1E824C)
        : const Color(0xFFC0392B);
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: min(500, size.width * 0.8),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EDDE),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDCC8A0), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.stock.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${widget.stock.currentPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${isPositive ? '+' : ''}${widget.stock.changePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: trendColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Chart
                Container(
                  height: 180,
                  padding: const EdgeInsets.only(
                    top: 20,
                    right: 10,
                    left: 0,
                    bottom: 0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDCC8A0)),
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (widget.stock.history.length - 1).toDouble(),
                      minY: widget.stock.history.reduce(min) * 0.99,
                      maxY: widget.stock.history.reduce(max) * 1.01,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            widget.stock.history.length,
                            (index) => FlSpot(
                              index.toDouble(),
                              widget.stock.history[index],
                            ),
                          ),
                          isCurved: true,
                          color: trendColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: trendColor.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Ownership Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Shares:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.stock.ownedShares}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions (Buy / Sell)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTradeButton('Sell', Colors.red, () => _trade(-1)),
                    _buildTradeButton('Buy', Colors.green, () => _trade(1)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTradeButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _trade(int amount) {
    if (amount > 0) {
      // Buying
      double cost = widget.stock.currentPrice * amount;
      if (widget.player.totalBalance >= cost) {
        setState(() {
          widget.player.totalBalance -= cost.toInt();
          widget.stock.ownedShares += amount;
        });
        widget.onUpdate();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough funds to buy!')),
        );
      }
    } else {
      // Selling
      int sellAmount = -amount;
      if (widget.stock.ownedShares >= sellAmount) {
        setState(() {
          double revenue = widget.stock.currentPrice * sellAmount;
          widget.player.totalBalance += revenue.toInt();
          widget.stock.ownedShares -= sellAmount;
        });
        widget.onUpdate();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough shares to sell!')),
        );
      }
    }
  }
}
