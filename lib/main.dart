import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/pack_selection_screen.dart';
import 'screens/onboarding_screen.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart'; // Add Superwall import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String apiKey =
      Platform.isIOS
          ? "pk_cb3e9b68d88a63a53d7b6bf8bc9f47d24e3c0ebc764e3072"
          : "MY_ANDROID_API_KEY";
  // Configure Superwall
  await Superwall.configure(apiKey);

  // --- Superwall Listeners Start ---
  Superwall.shared.setSubscriptionStatusDidChangeHandler((newStatus) {
    print("Subscription status changed: $newStatus");
    // TODO: Update global app state if necessary based on status change
    // e.g., refresh user profile, update UI elements showing subscription status
    if (newStatus == SubscriptionStatus.active) {
      // Maybe trigger a refresh or notify relevant parts of the app
      print("Subscription is now active. App state should be updated.");
    }
  });

  Superwall.shared.setOnPurchaseHandler((product) async {
    print("Purchase successful for product: ${product.identifier}");
    // IMPORTANT: Grant access to the purchased content/feature here.
    // This might involve:
    // - Setting a flag in user preferences/state management
    // - Making an API call to your backend
    // - Potentially navigating the user to the content they just unlocked

    // Example: If purchase unlocks *all* premium packs:
    // await AppState.instance.unlockPremiumFeatures(); // Hypothetical state management

    // Example: If purchase unlocks a *specific* pack (less common with Superwall's model, but possible)
    // You might need context from the registerEvent call, which isn't directly available here.
    // Usually, Superwall handles entitlement checking via subscriptionStatus.

    // For now, just print. Actual logic depends on app architecture.
    print(
      "User now has access (logic to be fully implemented based on app state).",
    );

    // You might want to dismiss the paywall view controller if it's still visible
    // Superwall might handle this automatically, check documentation.
    // Superwall.shared.dismiss(); // If needed

    return PurchaseResult.purchased; // Indicate success
  });

  Superwall.shared.setOnRestoreHandler((restorePurchasesResult) async {
    print(
      "Restore result: ${restorePurchasesResult.restoredSubscriptionStatus}",
    );
    if (restorePurchasesResult.restoredSubscriptionStatus ==
        SubscriptionStatus.active) {
      print("Restore successful, user is active.");
      // TODO: Update app state similar to onPurchase
    } else {
      print("Restore completed, but no active subscription found.");
      // TODO: Show appropriate message to user
    }
    return RestoreResult.restored; // Indicate restore process completed
  });

  // Add other handlers as needed (e.g., onDismiss, handleDeepLink, handleCustomPaywallAction)
  Superwall.shared.setOnDismissHandler((paywallInfo) {
    print("Paywall dismissed: ${paywallInfo.name}");
    // Handle dismissal if needed (e.g., user closed paywall without purchasing)
  });
  // --- Superwall Listeners End ---

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  final isDarkMode = prefs.getBool('darkMode') ?? true;

  runApp(
    FlamingoCardsApp(
      hasSeenOnboarding: hasSeenOnboarding,
      isDarkMode: isDarkMode,
    ),
  );
}

class FlamingoCardsApp extends StatefulWidget {
  final bool hasSeenOnboarding;
  final bool isDarkMode;

  const FlamingoCardsApp({
    super.key,
    required this.hasSeenOnboarding,
    required this.isDarkMode,
  });

  @override
  State<FlamingoCardsApp> createState() => _FlamingoCardsAppState();
}

class _FlamingoCardsAppState extends State<FlamingoCardsApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _setupDarkModeListener();
  }

  void _setupDarkModeListener() async {
    // Listen for changes to the dark mode setting
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload(); // Ensure we have the latest values

    // Set up a periodic check for changes (not ideal but works)
    // A better solution would be to use a state management solution like Provider
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        bool newDarkMode = prefs.getBool('darkMode') ?? true;
        if (newDarkMode != _isDarkMode) {
          setState(() {
            _isDarkMode = newDarkMode;
          });
        }
        _setupDarkModeListener();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Update system UI based on dark mode
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness:
            _isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Flamingo Cards',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor:
            _isDarkMode ? const Color(0xFF121212) : Colors.grey[100],
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                _isDarkMode ? Brightness.light : Brightness.dark,
          ),
        ),
        cardTheme: CardTheme(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          _isDarkMode
              ? ThemeData.dark().textTheme
              : ThemeData.light().textTheme,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFFFF4081),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFF4081),
            side: const BorderSide(color: Color(0xFFFF4081), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[800],
          contentTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4081),
          primary: const Color(0xFFFF4081),
          secondary: const Color(0xFFFF9B3D),
          tertiary: const Color(0xFF8E24AA),
          background: _isDarkMode ? const Color(0xFF121212) : Colors.grey[100]!,
          surface: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home:
          widget.hasSeenOnboarding
              ? const SplashScreen()
              : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const PackSelectionScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              var begin = const Offset(0.0, 1.0);
              var end = Offset.zero;
              var curve = Curves.easeOutQuint;

              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF4081), Color(0xFFFF9B3D)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flare,
                        size: 70,
                        color: Color(0xFFFF4081),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Text(
                      'Flamingo Cards',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Text(
                      'Connect Deeper. Play Together.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
