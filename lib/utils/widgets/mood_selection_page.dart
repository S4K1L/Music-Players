import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/controller/mood_controller.dart';
import 'package:music_player/utils/constant/colors.dart';
import 'package:music_player/view/recommendation_page.dart';

class MoodSelectionPage extends StatelessWidget {
  final MoodController moodController = Get.put(MoodController());

  // Map moods to corresponding emojis
  final Map<String, String> moodIcons = {
    'happy': '😊',
    'sad': '😢',
    'energetic': '⚡',
    'calm': '🌿',
  };

  final List<String> moods = ['happy', 'sad', 'energetic', 'calm'];

  MoodSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        title: const Text(
          'Mood right now!',
          style: TextStyle(color: kWhiteColor, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kBackGroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: moods.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                moodController.selectMood(moods[index]);
                Get.to(() => RecommendationsPage());
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      moodIcons[moods[index]]!,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      moods[index].capitalize!,
                      style: const TextStyle(
                        color: kWhiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
