import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'home_screen.dart';
import 'signin_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void navigateToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('SHOW_INTRO', false);
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 600),
      ),
    );
  }

  void nextPage() {
    if (currentIndex < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      navigateToHome();
    }
  }

  void skipToLast() {
    _pageController.animateToPage(
      2,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
              _slideController.reset();
              _slideController.forward();
            },
            children: [
              _buildPage(
                title: "Welcome to\nWeatherApp",
                subtitle: "Get real-time weather updates and accurate forecasts for any location worldwide. Your personal weather companion!",
                imagePath: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                primaryColor: Colors.blue,
                secondaryColor: const Color.fromARGB(255, 168, 227, 255),
              ),
              _buildPage(
                title: "Track Any\nLocation",
                subtitle: "Search weather conditions for any city around the globe. Get detailed forecasts and track multiple locations with ease.",
                imagePath: 'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                primaryColor: const Color.fromARGB(255, 14, 58, 74),
                secondaryColor: const Color.fromARGB(255, 133, 188, 207),
              ),
              _buildPage(
                title: "Smart Weather\nAlerts",
                subtitle: "Stay ahead with intelligent notifications, severe weather warnings, and personalized daily briefings.",
                imagePath: 'https://images.unsplash.com/photo-1500740516770-92bd004b996e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                primaryColor: const Color.fromARGB(255, 34, 45, 52),
                secondaryColor: const Color.fromARGB(255, 181, 227, 255),
              ),
            ],
          ),
          
          // Top Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: currentIndex < 2
                ? TextButton(
                    onPressed: skipToLast,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
          ),
          
          // Bottom Navigation
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(3, (index) => _buildDot(index)),
                  ),
                  
                  // Next/Done Button
                  GestureDetector(
                    onTap: nextPage,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: currentIndex == 2 ? 120 : 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: currentIndex == 0
                            ? const Color.fromARGB(255, 46, 114, 167)
                            : currentIndex == 1
                                ? const Color.fromARGB(255, 14, 58, 74)
                                : const Color.fromARGB(255, 34, 45, 52),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: (currentIndex == 0
                                    ? Colors.blue
                                    : currentIndex == 1
                                        ? const Color.fromARGB(255, 14, 58, 74)
                                        : const Color.fromARGB(255, 34, 45, 52))
                                .withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: currentIndex == 2
                            ? Text(
                                'Get Started',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required String imagePath,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.8),
            secondaryColor.withOpacity(0.9),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(40),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _scaleController,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.cloud,
                                size: 100,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: FadeTransition(
                        opacity: _fadeController,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.8),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: FadeTransition(
                        opacity: _fadeController,
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(right: 8),
      height: 8,
      width: currentIndex == index ? 24 : 8,
      decoration: BoxDecoration(
        color: currentIndex == index
            ? Colors.white
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
