import 'package:flutter/material.dart';
import 'package:motostock_pro/core/theme/app_colors.dart';

enum StockLevel { ok, low, critical, out }

class StockBadge extends StatelessWidget {
  final int quantity;
  final int minQuantity;
  final bool showIcon;
  final bool compact;

  const StockBadge({
    super.key,
    required this.quantity,
    required this.minQuantity,
    this.showIcon = true,
    this.compact = false,
  });

  StockLevel get _level {
    if (quantity <= 0) return StockLevel.out;
    if (quantity < minQuantity) return StockLevel.critical;
    if (quantity < minQuantity * 1.5) return StockLevel.low;
    return StockLevel.ok;
  }

  Color get _color {
    return switch (_level) {
      StockLevel.ok => AppColors.stockOk,
      StockLevel.low => AppColors.stockLow,
      StockLevel.critical => AppColors.stockCritical,
      StockLevel.out => AppColors.stockOut,
    };
  }

  String get _label {
    return switch (_level) {
      StockLevel.ok => 'En stock',
      StockLevel.low => 'Stock faible',
      StockLevel.critical => 'Critique',
      StockLevel.out => 'Épuisé',
    };
  }

  IconData get _icon {
    return switch (_level) {
      StockLevel.ok => Icons.check_circle_outline_rounded,
      StockLevel.low => Icons.warning_amber_rounded,
      StockLevel.critical => Icons.error_outline_rounded,
      StockLevel.out => Icons.remove_circle_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          quantity.toString(),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_icon, color: color, size: 13),
            const SizedBox(width: 5),
          ],
          Text(
            '$quantity — $_label',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Affiche juste un point de couleur selon le niveau de stock
class StockDot extends StatelessWidget {
  final int quantity;
  final int minQuantity;

  const StockDot(
      {super.key, required this.quantity, required this.minQuantity});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (quantity <= 0) {
      color = AppColors.stockOut;
    } else if (quantity < minQuantity) {
      color = AppColors.stockCritical;
    } else if (quantity < minQuantity * 1.5) {
      color = AppColors.stockLow;
    } else {
      color = AppColors.stockOk;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)],
      ),
    );
  }
}
