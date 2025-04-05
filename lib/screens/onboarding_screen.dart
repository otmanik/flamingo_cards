import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'pack_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  final List<String> _titles = [
    'Welcome to Flamingo Cards',
    'Connect with Others',
    'Explore & Discover',
  ];

  final List<String> _descriptions = [
    'The ultimate card game to spark meaningful conversations and create memorable moments.',
    'Perfect for date nights, family gatherings, parties, or deepening connections with friends.',
    'Browse through our diverse collection of card packs for every occasion and mood.',
  ];

  final List<IconData> _icons = [Icons.flare, Icons.people, Icons.explore];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _numPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PackSelectionScreen()),
      );
    }
  }

  Widget _buildPageAnimation(int pageIndex) {
    // Normally you would use Lottie animations here
    // For simplicity, we're using a container with icon
    final List<Color> backgroundColors = [
      const Color(0xFFFF4081),
      const Color(0xFF9C27B0),
      const Color(0xFFFF9B3D),
    ];

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: backgroundColors[pageIndex].withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          _icons[pageIndex],
          size: 100,
          color: backgroundColors[pageIndex],
        ),
      ),
    );

    // With Lottie, you would do:
    // return Lottie.asset(
    //   'assets/animations/animation_$pageIndex.json',
    //   width: 300,
    //   height: 300,
    //   fit: BoxFit.contain,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF5F7), Color(0xFFFFF0EA)],
              ),
            ),
          ),

          // Pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _numPages,
            itemBuilder: (context, index) {
              return _buildPage(
                title: _titles[index],
                description: _descriptions[index],
                iconData: _icons[index],
                pageIndex: index,
              );
            },
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Skip',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFF4081),
                ),
              ),
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _numPages,
                  effect: ExpandingDotsEffect(
                    activeDotColor: const Color(0xFFFF4081),
                    dotColor: const Color(0xFFFF4081).withOpacity(0.3),
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                  ),
                ),
                const SizedBox(height: 40),

                // Next button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4081),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      _currentPage == _numPages - 1 ? 'Get Started' : 'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required IconData iconData,
    required int pageIndex,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation or icon
          _buildPageAnimation(pageIndex),

          const SizedBox(height: 60),

          // Title
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Add some space at the bottom for the navigation controls
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
