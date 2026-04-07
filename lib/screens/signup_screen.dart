import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signin_screen.dart';
import 'home_screen.dart'; // เพิ่มใน import section

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void signUpWithEmailAndPassword() async {
    // Basic validation
    if (nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name', isError: true);
      return;
    }

    if (emailController.text.trim().isEmpty ||
        !emailController.text.contains('@')) {
      _showSnackBar('Please enter a valid email', isError: true);
      return;
    }

    if (passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', isError: true);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      // Update the user's display name
      await credential.user?.updateDisplayName(nameController.text.trim());

      // Reload user to get updated profile
      await credential.user?.reload();

      setState(() {
        _isLoading = false;
      });

      _showSnackBar('Account created successfully!', isError: false);

      // Navigate back to sign in
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              HomeScaffold(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 600),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Try again later.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }

      _showSnackBar(errorMessage, isError: true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showSnackBar(
        'An unexpected error occurred. Please try again.',
        isError: true,
      );
      print('Unexpected error: $e');
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 4), // Longer duration for error messages
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color.fromARGB(255, 14, 58, 74), // Gray-Blue
              const Color.fromARGB(255, 133, 188, 207), // Light Blue
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: Offset(-0.5, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(
                          opacity: _fadeController,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Weather Icon Animation
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: Offset(0, -0.5),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.elasticOut,
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _fadeController,
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person_add_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Welcome Text
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _fadeController,
                        child: Column(
                          children: [
                            Text(
                              'Create\nAccount',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Join our weather community',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 48),

                    // Sign Up Form Card
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _fadeController,
                        child: Container(
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Name Field
                              _buildInputField(
                                'Name',
                                Icons.person_outline,
                                nameController,
                                false,
                              ),
                              SizedBox(height: 20),

                              // Email Field
                              _buildInputField(
                                'Email',
                                Icons.email_outlined,
                                emailController,
                                false,
                              ),
                              SizedBox(height: 20),

                              // Password Field
                              _buildInputField(
                                'Password',
                                Icons.lock_outline,
                                passwordController,
                                true,
                                isFirst: true,
                              ),
                              SizedBox(height: 20),

                              // Confirm Password Field
                              _buildInputField(
                                'Re-Password',
                                Icons.lock_outline,
                                confirmPasswordController,
                                true,
                                isFirst: false,
                              ),
                              SizedBox(height: 32),

                              // Sign Up Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color.fromARGB(255, 14, 58, 74),
                                      const Color.fromARGB(255, 133, 188, 207),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                        255,
                                        14,
                                        58,
                                        74,
                                      ).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : signUpWithEmailAndPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Sign up',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              SizedBox(height: 24),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: Colors.grey.shade300),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'or',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: Colors.grey.shade300),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),

                              // Social Login Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildSocialButton(
                                    Icons.g_mobiledata,
                                    Color(0xFFDB4437),
                                  ),
                                  _buildSocialButton(
                                    Icons.facebook,
                                    Color(0xFF4267B2),
                                  ),
                                  _buildSocialButton(Icons.apple, Colors.black),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Login Link
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: Offset(0, 0.7),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _fadeController,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => SignInScreen(),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          const begin = Offset(-1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOutCubic;

                                          var tween = Tween(
                                            begin: begin,
                                            end: end,
                                          ).chain(CurveTween(curve: curve));

                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                    transitionDuration: Duration(
                                      milliseconds: 300,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign in',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    TextEditingController controller,
    bool isPassword, {
    bool isFirst = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword
                ? (isFirst ? !_isPasswordVisible : !_isConfirmPasswordVisible)
                : false,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        (isFirst
                                ? _isPasswordVisible
                                : _isConfirmPasswordVisible)
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isFirst) {
                            _isPasswordVisible = !_isPasswordVisible;
                          } else {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          }
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
