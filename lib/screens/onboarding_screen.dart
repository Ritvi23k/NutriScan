// =============================================================================
// screens/onboarding_screen.dart
// =============================================================================
// 3-page carousel highlighting: AI Food Scanning, Indian Food Database,
// and Macro Tracking. Includes smooth page indicator and "Get Started" button.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      icon: Icons.camera_alt_rounded,
      iconColor: AppTheme.primaryMint,
      bgGradient: [const Color(0xFF0D3B26), const Color(0xFF1BA885)],
      title: 'AI Food Scanner',
      subtitle:
          'Just snap a photo of your meal and our AI instantly identifies the food, calculates calories, and breaks down macros.',
      highlight: 'Powered by AI Vision',
    ),
    _OnboardingPageData(
      icon: Icons.restaurant_rounded,
      iconColor: AppTheme.accentOrange,
      bgGradient: [const Color(0xFF4A2800), const Color(0xFFFFB347)],
      title: 'Indian Food Database',
      subtitle:
          'Roti, Dal, Paneer, Biryani, Idli, Dosa — track your favorite desi meals with accurate nutrition data for 35+ Indian dishes.',
      highlight: '35+ Indian Foods',
    ),
    _OnboardingPageData(
      icon: Icons.insights_rounded,
      iconColor: AppTheme.accentPurple,
      bgGradient: [const Color(0xFF2D1B69), const Color(0xFFA78BFA)],
      title: 'Smart Macro Tracking',
      subtitle:
          'Track protein, carbs, fats, water intake, and daily streaks. Beautiful charts show your 7-day journey and 30-day history.',
      highlight: 'Complete Nutrition',
    ),
  ];

  void _onGetStarted() async {
    final storage = StorageService();
    await storage.setOnboardingComplete();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SignInScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) => _buildPage(_pages[index]),
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 20,
            child: TextButton(
              onPressed: _onGetStarted,
              child: Text(
                'Skip',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        expansionFactor: 3,
                        spacing: 6,
                        dotColor: Colors.white.withOpacity(0.3),
                        activeDotColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Get Started / Next button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _onGetStarted();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPageData page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: page.bgGradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Icon with glow
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: page.iconColor.withOpacity(0.3),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  page.icon,
                  size: 72,
                  color: Colors.white,
                ),
              ),
              const Spacer(flex: 1),

              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  page.highlight,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                page.title,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                page.subtitle,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final List<Color> bgGradient;
  final String title;
  final String subtitle;
  final String highlight;

  _OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.bgGradient,
    required this.title,
    required this.subtitle,
    required this.highlight,
  });
}
