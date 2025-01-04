import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/controller/signup_controller.dart';
import 'package:music_player/utils/constant/constant.dart';
import 'package:music_player/view/login_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});
  final SignupController signupController = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF121212), Color(0xFF181818)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Circular avatars
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                background,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.only(top: 50*5),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(logo,fit: BoxFit.cover,height: 120,),
                  const Text(
                    "Millions of songs\nFree on Music Player",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Email login button
                  _buildButton(
                    icon: Icons.email,
                    text: "Continue with email",
                    color: Colors.white,
                    backgroundColor: const Color(0xFF1DB954),
                    onTap: () {
                      Get.to(()=> SignupPage(),transition: Transition.rightToLeft);
                    },
                  ),
                  const SizedBox(height: 10),
                  // Google login button
                  _buildButton(
                    icon: Icons.g_mobiledata,
                    text: "Continue with Google",
                    color: Colors.white,
                    borderColor: Colors.white,
                    onTap: () {
                      signupController.signUpWithGoogle();
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildButton(
                    icon: Icons.music_note,
                    text: "Already have an account ?",
                    color: Colors.white,
                    borderColor: Colors.white,
                    onTap: () {
                      Get.to(()=> LoginPage(),transition: Transition.rightToLeft);
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    required Color color,
    Color? backgroundColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(
          text,
          style: TextStyle(color: color, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          side: borderColor != null ? BorderSide(color: borderColor) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}