import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music_player/controller/signup_controller.dart';
import 'package:music_player/utils/constant/colors.dart';
import 'package:music_player/view/login_page.dart';
import 'package:music_player/view/reset_password.dart';

class SignupPage extends StatelessWidget {
  final SignupController signupController = Get.put(SignupController());

  SignupPage({super.key});

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
              Text(
                "Music Player",
                style: TextStyle(
                  color: const Color(0xFF1DB954),
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 50 * 4.sp),
              Text(
                "Register here",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30.sp),
              Form(
                key: signupController.formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      controller: signupController.usernameController,
                      hintText: "Username",
                      icon: Icons.person,
                    ),
                    SizedBox(height: 15.sp),
                    _buildInputField(
                      controller: signupController.emailController,
                      hintText: "Email",
                      icon: Icons.email,
                    ),
                    SizedBox(height: 15.sp),
                    _buildPasswordInputField(
                      controller: signupController.passwordController,
                      isPasswordVisible: signupController.isPasswordVisible,
                      togglePasswordVisibility:
                      signupController.togglePasswordVisibility,
                      hintText: "Password",
                      icon: Icons.lock,
                    ),
                    SizedBox(height: 15.sp),
                    _buildPasswordInputField(
                      controller: signupController.confirmPasswordController,
                      isPasswordVisible: signupController.isPasswordVisible,
                      togglePasswordVisibility:
                      signupController.togglePasswordVisibility,
                      hintText: "Repeat password",
                      icon: Icons.lock,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.sp),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.sp),
                child: ElevatedButton(
                  onPressed: () {
                    final confirmPassword =
                    signupController.confirmPasswordController.text.trim();
                    final password =
                    signupController.passwordController.text.trim();
                    if (password != confirmPassword) {
                      Get.snackbar("Error", "Passwords do not match.",
                          snackPosition: SnackPosition.BOTTOM);
                    } else {
                      signupController.signUp(
                        signupController.emailController.text,
                        signupController.passwordController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.sp),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15.sp),
                  ),
                  child: Center(
                    child: Text(
                      "SIGN UP",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.sp),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.sp),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap:(){
                        Get.to(() => ResetPassword(),
                            transition: Transition.rightToLeft);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Don’t remember the password? ",
                            style: TextStyle(color: Colors.white, fontSize: 12.sp),
                          ),
                          const Text(
                            "Recover here",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => LoginPage(),
                            transition: Transition.rightToLeft);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        child: Row(
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.white, fontSize: 12.sp),
                            ),
                            const Text(
                              "Login here",
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
      padding: EdgeInsets.symmetric(horizontal: 40.sp),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          prefixIcon: Icon(icon, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.sp),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildPasswordInputField({
    required TextEditingController controller,
    required RxBool isPasswordVisible,
    required VoidCallback togglePasswordVisibility,
    required String hintText,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.sp),
      child: Obx(
            () => TextField(
          controller: controller,
          obscureText: !isPasswordVisible.value,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            prefixIcon: Icon(icon, color: Colors.white),
            suffixIcon: GestureDetector(
              onTap: togglePasswordVisibility,
              child: Icon(
                isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.grey,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.sp),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
