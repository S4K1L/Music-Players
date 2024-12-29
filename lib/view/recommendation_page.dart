import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/utils/constant/colors.dart';
import '../controller/mood_controller.dart';

class RecommendationsPage extends StatelessWidget {
  final MoodController moodController = Get.put(MoodController());
  final AudioPlayer audioPlayer = AudioPlayer();

  RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            audioPlayer.stop(); // Stop playback when navigating back
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: kWhiteColor),
        ),
        title: const Text(
          'Recommended Tracks',
          style: TextStyle(color: kWhiteColor),
        ),
        backgroundColor: kBackGroundColor,
      ),
      body: Obx(() {
        if (moodController.recommendedTracks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: moodController.recommendedTracks.length,
          itemBuilder: (context, index) {
            final track = moodController.recommendedTracks[index];
            return ListTile(
              leading: Image.network(track['album']['images'][0]['url']),
              title: Text(
                track['name'],
                style: const TextStyle(color: kWhiteColor),
              ),
              subtitle: Text(
                track['artists'][0]['name'],
                style: const TextStyle(color: kWhiteColor),
              ),
              onTap: () async {
                try {
                  // Get the track's preview URL
                  final trackUrl = track['preview_url'];
                  if (trackUrl != null) {
                    await audioPlayer.setUrl(trackUrl);
                    audioPlayer.play();
                  } else {
                    Get.snackbar(
                      "Playback Error",
                      "No preview available for this track.",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "An error occurred while playing the track.",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            );
          },
        );
      }),
    );
  }
}
