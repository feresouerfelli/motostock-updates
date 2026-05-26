import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motostock_pro/app.dart';
import 'package:motostock_pro/features/license/providers/license_provider.dart';

/// Enforces a maximum total purchase value of 200 DT for all stocked pieces.
class BudgetValidator {
  final Ref _ref;
  BudgetValidator(this._ref);

  static const double maxBudget = 200.0;

  Future<double> _currentTotal() async {
    final db = _ref.read(databaseProvider);
    final all = await db.getAllPieces();
    double total = 0;
    for (final p in all) {
      final price = p.prixAchat;
      final qty = p.quantiteEnStock;
      total += price * qty;
    }
    return total;
  }

  Future<bool> canAdd({required double newPrice, required int newQty}) async {
    final license = _ref.read(licenseProvider);
    final isActivated = license.valueOrNull?.isActivated ?? false;

    if (isActivated) return true; // No limit if activated

    final current = await _currentTotal();
    return current + (newPrice * newQty) <= maxBudget;
  }

  Future<double> remainingBudget() async {
    final license = _ref.read(licenseProvider);
    final isActivated = license.valueOrNull?.isActivated ?? false;

    if (isActivated) return 999999999.0; // "Unlimited"

    final current = await _currentTotal();
    return (maxBudget - current).clamp(0.0, maxBudget);
  }
}

final budgetValidatorProvider =
    Provider<BudgetValidator>((ref) => BudgetValidator(ref));
