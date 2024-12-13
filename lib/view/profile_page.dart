import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music_player/controller/profile_controller.dart';
import 'package:music_player/utils/constant/constant.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../utils/constant/colors.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 22, color: kWhiteColor, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: Obx(
            () => Skeletonizer(
          enabled: profileController.isLoading.value,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 200.sp,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(30.sp),
                        ),
                      ),
                    ),
                     Positioned(
                      top: 130.sp,
                      child: CircleAvatar(
                        radius: 60.sp,
                        backgroundImage: const AssetImage(logo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                Text(
                  profileController.user.value.name ?? 'Name not available',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: kWhiteColor),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.email, 'Email', profileController.user.value.email ?? 'Not available'),
                          const SizedBox(height: 20),
                          _buildInfoRow(Icons.password, 'Password', profileController.user.value.password ?? 'Not available'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 45.sp,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(60),
                        topLeft: Radius.circular(60),
                      ),
                      color: Colors.green,
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Implement logout logic here
                        profileController.logout();
                      },
                      child: const Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // Info row widget for displaying user info
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 20),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}