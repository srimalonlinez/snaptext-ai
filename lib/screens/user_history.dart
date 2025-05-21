import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:snaptext_ai/constants/colors.dart';
import 'package:snaptext_ai/models/conversion_model.dart';
import 'package:snaptext_ai/provider/premium_provider.dart';
import 'package:snaptext_ai/services/store_conversions_firestore.dart';
import 'package:snaptext_ai/widgets/show_premium.dart';
import 'package:snaptext_ai/widgets/user_history.dart';

class UserHistory extends StatelessWidget {
  const UserHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremiumProvide = Provider.of<PremiumProvider>(context);

    //check is the premium status is not loading yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isPremiumProvide.checkPremiumStatus();
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History Conversions",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        actions: [
          isPremiumProvide.isPremium
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.star, color: Colors.yellowAccent),
              )
              : SizedBox(),
        ],
      ),
      body:
          isPremiumProvide.isPremium
              ? const UserHistoryWidget()
              : const ShowPremiumPannel(),
    );
  }
}
