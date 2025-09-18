import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  // -------------------- LOGIN --------------------
  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged in successfully! 🚀',
            style: GoogleFonts.roboto(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Login failed',
            style: GoogleFonts.roboto(color: Colors.white),
          ),
          backgroundColor: Colors.black54,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // -------------------- SIGNUP --------------------
  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Email and password cannot be empty.',
            style: GoogleFonts.roboto(color: Colors.white),
          ),
          backgroundColor: Colors.black54,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await credential.user?.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created successfully! 🎉',
            style: GoogleFonts.roboto(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        message = 'Password should be at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.roboto(color: Colors.white),
          ),
          backgroundColor: Colors.black54,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unexpected error: $e',
            style: GoogleFonts.roboto(color: Colors.white),
          ),
          backgroundColor: Colors.black54,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // Custom Neumorphic Container
  Widget _neumorphicContainer({
    required Widget child,
    double borderRadius = 16,
    double height = 56,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Light shadow (top-left)
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-6, -6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          // Dark shadow (bottom-right)
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(6, 6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          // Inner light shadow for depth
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          // Inner dark shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }

  // Custom Neumorphic Button
  Widget _neumorphicButton({
    required VoidCallback onPressed,
    required String text,
    Color textColor = Colors.black,
    double borderRadius = 16,
    double height = 60,
    Color accentColor = Colors.transparent,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: accentColor != Colors.transparent
              ? Border.all(
            color: accentColor.withOpacity(0.3),
            width: 2,
          )
              : null,
          boxShadow: [
            // Light shadow (top-left)
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-6, -6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            // Dark shadow (bottom-right)
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(6, 6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            // Inner light shadow for depth
            BoxShadow(
              color: Colors.white.withOpacity(0.4),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            // Inner dark shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Shader linearGradient = const LinearGradient(
      colors: <Color>[Colors.purple, Colors.blue, Colors.cyan],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lottie Animation
                    Lottie.asset(
                      'assets/lottie/AI logo Foriday.json',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12), // Increased gap to move Lottie up
                    // App Name
                    Text(
                      'AIVerse',
                      style: GoogleFonts.roboto(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()..shader = linearGradient, // gradient text
                        letterSpacing: 3.0,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unleash the Power of AI',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: Colors.black54,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 32), // Reduced gap to move fields up

                    // Email Field - Neumorphic Container
                    _neumorphicContainer(
                      borderRadius: 20,
                      height: 60,
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          floatingLabelBehavior: FloatingLabelBehavior.never, // keeps floating
                          floatingLabelStyle: GoogleFonts.roboto(
                            color: Colors.deepPurple,
                            fontSize: 14, // smaller when floating
                            fontWeight: FontWeight.w600,
                          ),
                          labelStyle: GoogleFonts.roboto(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.black54,
                            size: 24,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18, // 👈 increased top padding so label floats above icon
                          ),
                        ),
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _neumorphicContainer(
                      borderRadius: 20,
                      height: 60,
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          floatingLabelStyle: GoogleFonts.roboto(
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          labelStyle: GoogleFonts.roboto(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.black54,
                            size: 24,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.black54,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18, // 👈 avoids overlap with prefix/suffix icons
                          ),
                        ),
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        obscureText: _obscurePassword,
                      ),
                    ),

                    const SizedBox(height: 40), // Increased gap to move buttons down

                    // Loading Indicator or Buttons
                    _loading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      strokeWidth: 3,
                    )
                        : Column(
                      children: [
                        // Login Button - Neumorphic Button with Blue Accent
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: _neumorphicButton(
                            onPressed: _login,
                            text: 'Login',
                            textColor: Colors.black,
                            accentColor: Colors.blue,
                            borderRadius: 20,
                            height: 60,
                          ),
                        ),
                        const SizedBox(height: 24), // Increased gap between buttons

                        // Signup Button - Neumorphic Button with Green Accent
                        FadeInUp(
                          duration: const Duration(milliseconds: 1200),
                          child: _neumorphicButton(
                            onPressed: _signup,
                            text: 'Create Account',
                            textColor: Colors.black,
                            accentColor: Colors.green,
                            borderRadius: 20,
                            height: 60,
                          ),
                        ),
                      ],
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
}