import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:snaptext_ai/constants/colors.dart';
import 'package:snaptext_ai/firebase_options.dart';
import 'package:snaptext_ai/main_screen.dart';
import 'package:snaptext_ai/provider/premium_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  // await dotenv.load(fileName: '.env');
  // Stripe.publishableKey =
  //     dotenv.env['STRIPE_PUBLISHABLE_KEY'] ??
  //     "";
  Stripe.publishableKey =
      "pk_test_51RJMXI2NsikHabpo1eCJNWGbl4cEvavTUsQADcxeMJuA5grsViXNUo1YrBHCT3domQowCg9pkIYExIWuvj77nqDD00Jep7KrSz";

  // Apply Stripe settings
  await Stripe.instance.applySettings();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PremiumProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SnapText AI",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: mainColor,
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(color: mainColor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: mainColor),
            ),
            backgroundColor: mainColor,
          ),
        ),
      ),
      home: MainScreen(),
    );
  }
}
