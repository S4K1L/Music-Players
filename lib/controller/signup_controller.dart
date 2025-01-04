import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:music_player/model/user_model.dart';
import 'package:music_player/utils/components/bottom_bar.dart';
import '../utils/constant/colors.dart';

class SignupController extends GetxController {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // No need for .obs here

  // Firestore and FirebaseAuth instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Model
  var userModel = UserModel().obs;
  RxBool isLoading = false.obs;

  GlobalKey<FormState> get formKey => _formKey;

  // Password visibility toggle
  RxBool isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<UserModel?> signUp(String email, String password) async {
    isLoading.value = true;
    try {
      if (!_formKey.currentState!.validate()) {
        // Validate the form
        isLoading.value = false;
        Get.snackbar(
          'Invalid Input',
          'Please check your all data',
          colorText: kWhiteColor,
          backgroundColor: kPrimaryColor,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
        );
        return null;
      } else {
        UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = result.user;

        if (user != null) {
          // Create a UserModel object
          userModel.value = UserModel(
            name: usernameController.value.text,
            email: emailController.value.text,
            password: passwordController.value.text,
          );

          // Store user information in Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'name': userModel.value.name,
            'email': userModel.value.email,
            'password': userModel.value.password,
            'role': 'user',
            'uid': user.uid,
          });

          isLoading.value = false;
          // Success message
          Get.snackbar(
            'Registration Successful',
            'Welcome to Music Player',
            colorText: kWhiteColor,
            backgroundColor: kPrimaryColor,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
          );
          Get.offAll(()=> const BottomBar(),transition: Transition.leftToRight);
          return userModel.value;
        } else {
          isLoading.value = false;
          Get.snackbar('Registration Failed!', 'Try again!',
              colorText: kWhiteColor,
              backgroundColor: kPrimaryColor,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.only(bottom: 30, left: 16, right: 16));
          if (kDebugMode) {
            print("User is null");
          }
          return null;
        }
      }
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print("Error in registering: $e");
      }
      Get.snackbar(
        'Error',
        'Registration failed: $e',
        colorText: kWhiteColor,
        backgroundColor: kPrimaryColor,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
      );
      return null;
    }
  }

  Future<void> signUpWithGoogle() async {
    try {
      // Start Google Sign-In process
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the Google Sign-In process
        return;
      }

      // Obtain Google authentication details
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Assign user's information to userModel
        userModel.value = UserModel(
          name: googleUser.displayName,
          email: googleUser.email,
        );

        // Check if the user data already exists in Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          // If user does not exist in Firestore, add the user's data
          await _firestore.collection('users').doc(user.uid).set({
            'password': userModel.value.password,
            'name': userModel.value.name,
            'email': userModel.value.email,
            'uid': user.uid,
            'role': 'user',
          });
        }
        // Show success message
        Get.snackbar(
          'Login Success',
          'You have successfully logged in!',
          colorText: kWhiteColor,
          backgroundColor: kPrimaryColor,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
        );

        // Navigate to HomePage
        Get.to(() => const BottomBar());
      }
    } catch (e) {
      // Show error message if sign-in fails
      Get.snackbar(
        'Error',
        'Google sign-in failed: $e',
        colorText: kWhiteColor,
        backgroundColor: kRedColor,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
      );
      if (kDebugMode) print("Error in Google sign-in: $e");
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
