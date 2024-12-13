import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/controller/login_controller.dart';
import 'package:music_player/utils/constant/colors.dart';
import 'package:music_player/view/reset_password.dart';
import 'package:music_player/view/signup_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppbarColor,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: kWhiteColor,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E0B0A), Color(0xFF1DB954)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Music Player",
                style: TextStyle(
                  color: Color(0xFF1DB954),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50*4),
              const Text(
                "Login here",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _buildInputField(
                controller: loginController.emailController,
                hintText: "Email",
                icon: Icons.email,
              ),
              const SizedBox(height: 15),
              _buildPasswordInputField(
                controller: loginController.passwordController,
                call: LoginController(),
                hintText: "Password",
                icon: Icons.lock,
              ),
              const SizedBox(height: 30),
              // Log In button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    loginController.loginUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Center(
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Forgot password and sign-up links
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap:(){
                        Get.to(() => ResetPassword(),
                            transition: Transition.rightToLeft);
                      },
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Don’t remember the password? ",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Recover here",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: (){
                        Get.to(() => SignupPage(),
                            transition: Transition.rightToLeft);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Signup here",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          prefixIcon: Icon(icon, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildPasswordInputField({
    required TextEditingController controller,
    required LoginController call,
    required String hintText,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Obx(
            () => TextField(
          controller: controller,
          obscureText: !call.isPasswordVisible.value,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            prefixIcon: Icon(icon, color: Colors.white),
            suffixIcon: GestureDetector(
              onTap: call.togglePasswordVisibility,
              child: Icon(
                call.isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.grey,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

