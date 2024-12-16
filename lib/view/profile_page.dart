import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music_player/controller/profile_controller.dart';
import 'package:music_player/utils/constant/colors.dart';
import '../utils/constant/constant.dart';
import 'reset_password.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kPrimaryColor,
        title: const Text(
          'Profile Settings',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final userData = profileController.user.value;
        if (userData.email == null) {
          return const Center(
            child: Text(
              'Failed to load account details.',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        return SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 10.sp,
                    color: kPrimaryColor,
                    padding: EdgeInsets.symmetric(vertical: 20.sp),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: kBackGroundColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30.sp),
                        topLeft: Radius.circular(30.sp),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 20.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 80.sp),
                          Text(
                            profileController.user.value.name ?? 'Not available',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: kWhiteColor,
                            ),
                          ),
                          _buildSettingTile(
                            'Change Name',
                            profileController.user.value.name ?? 'Not available',
                            Icons.person,
                            onTap: () async {
                              await _showChangeNameDialog(context);
                            },
                          ),
                          const Divider(),
                          _buildSettingTile(
                            'Email',
                            profileController.user.value.email ?? 'Not available',
                            Icons.email,
                          ),
                          const Divider(),
                          _buildSettingTile(
                            'Change Password',
                            '',
                            Icons.lock,
                            onTap: () {
                              Get.to(() => ResetPassword(),
                                  transition: Transition.rightToLeft);
                            },
                          ),
                          _buildSettingTile(
                            'Delete Account',
                            '',
                            Icons.delete,
                            onTap: () async {
                              final shouldDelete = await _showConfirmationDialog(
                                context,
                                title: 'Delete Account',
                                content:
                                'Are you sure you want to delete your account? This action cannot be undone.',
                                confirmText: 'Delete',
                                confirmColor: Colors.red,
                              );
                              if (shouldDelete == true) {
                                await profileController.deleteAccount();
                              }
                            },
                          ),
                          _buildSettingTile(
                            'Logout',
                            '',
                            Icons.output_rounded,
                            onTap: () async {
                              final shouldLogout = await _showConfirmationDialog(
                                context,
                                title: 'Logout',
                                content: 'Are you sure you want to log out?',
                                confirmText: 'Logout',
                                confirmColor: Colors.teal,
                              );
                              if (shouldLogout == true) {
                                await profileController.logout();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: CircleAvatar(
                  radius: 70.0.sp,
                  backgroundColor: kBackGroundColor,
                  child: Image.asset(user),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon,
      {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Icon(icon, color: Colors.teal),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor)),
      subtitle: subtitle.isNotEmpty
          ? Text(
        subtitle,
        style: const TextStyle(color: kWhiteColor),
      )
          : null,
      trailing:
      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _showChangeNameDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  await profileController.changeUsername(newName);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context,
      {required String title,
        required String content,
        required String confirmText,
        required Color confirmColor}) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                confirmText,
                style: TextStyle(color: confirmColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
