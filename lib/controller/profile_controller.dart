import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/controller/login_controller.dart';
import 'package:music_player/controller/signup_controller.dart';
import 'package:music_player/model/user_model.dart';
import 'package:music_player/utils/constant/colors.dart';
import 'package:music_player/view/login_page.dart';
import 'package:music_player/view/welcome_page.dart';

class ProfileController extends GetxController{
  var user = UserModel().obs;
  var isLoading = false.obs;

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;


  @override
  void onInit() {
    fetchLoggedInUser();
    super.onInit();
  }

  /// Fetch logged-in user
  Future<void> fetchLoggedInUser() async {
    isLoading(true);
    try {
      final currentUser = this.currentUser;
      if (currentUser != null) {
        final doc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          user.value = UserModel.fromSnapshot(doc);
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      isLoading(false);
    }
  }

  // Function to change username
  Future<void> changeUsername(String newUsername) async {
    try {
      // Get current user
      User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      // Update username in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': newUsername,
      });

      // Provide feedback to the user
      Get.snackbar("Success", "Username updated successfully");
    } catch (e) {
      // Handle errors
      Get.snackbar("Error", "Failed to update username: ${e.toString()}");
    }
  }


  /// Logout method
  Future<void> logout() async {
    try {
      if (_auth.currentUser != null) {
        await _auth.signOut();

        // Reset all models to their initial empty state
        user.value = UserModel();
        // Clear cache and delete UserController (if needed)
        await Get.delete<ProfileController>();
        await Get.delete<LoginController>();
        await Get.delete<SignupController>();

        Get.snackbar(
          'Logout Success',
          'You have successfully logged out!',
          colorText: kWhiteColor,
          backgroundColor: kPrimaryColor,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
        );

        // Navigate to login page
        Get.offAll(()=> WelcomePage());
      } else {
        if (kDebugMode) {
          print("No user is currently signed in");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error logging out: $e");
      }
      Get.snackbar('Error', 'An error occurred while logging out. Please try again.');
      rethrow;
    }
  }

  /// Delete the user's account and associated data from Firestore.
  Future<void> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'No user is logged in.');
        return;
      }

      String uid = user.uid; // Get the logged-in user's UID

      // Delete user-related data across Firestore collections
      WriteBatch batch = _firestore.batch();

      // Example collections to delete
      final List<String> collectionsToDelete = ['users', 'carbon'];

      for (String collection in collectionsToDelete) {
        QuerySnapshot querySnapshot = await _firestore
            .collection(collection)
            .where('userId', isEqualTo: uid)
            .get();

        for (var doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }
      }

      // Commit the batched deletion
      await batch.commit();

      // Delete the user's Firebase Authentication account
      await user.delete();

      // Navigate to the login screen after deletion
      Get.offAll(()=> LoginPage(),transition: Transition.rightToLeft);
      Get.snackbar('Success', 'Account and all related data deleted successfully.');
    } catch (error) {
      if (error.toString().contains('requires-recent-login')) {
        Get.snackbar(
          'Error',
          'Please log in again to delete your account due to security reasons.',
        );
      } else {
        Get.snackbar('Error', 'Failed to delete account: $error');
      }
    }
  }

}