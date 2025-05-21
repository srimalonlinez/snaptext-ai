import 'package:flutter/material.dart';
import 'package:snaptext_ai/services/Stripe/stripe_storage.dart';

class PremiumProvider with ChangeNotifier {
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  Future<void> checkPremiumStatus() async {
    _isPremium = await StripeStorage().checkIfPremium();
    notifyListeners();
  }

  void activatePremium() {
    _isPremium = true;
    notifyListeners();
  }
}
