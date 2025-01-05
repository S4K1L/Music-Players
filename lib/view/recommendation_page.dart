import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/main.dart';
import 'package:music_player/utils/constant/colors.dart';
import '../controller/mood_controller.dart';
import '../controller/bookmark_controller.dart';
import '../controller/spotify_controller.dart';

class RecommendationsPage extends StatelessWidget {
  final MoodController moodController = Get.put(MoodController());
  final AudioPlayer audioPlayer = AudioPlayer();
  final SpotifyController spotifyController = Get.put(SpotifyController());

  final BookmarkController bookmarkController = Get.put(BookmarkController());

  RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () async {
            try {
              await audioPlayer.stop(); // Stop playback safely
            } catch (e) {
              print('Error stopping audio player: $e');
            } finally {
              Get.offNamed('/'); // Navigate to the home page
            }
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
            return GestureDetector(
              onTap: () {
                spotifyController.playTrack(track['id']);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.sp,horizontal: 8.sp),
                child: Container(
                  padding: EdgeInsets.all(8.0.sp),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8.0.sp),
                  ),
                  child: Row(
                    children: [
                      Image.network(
                        track['album']['images'][0]['url'],
                        height: 50.sp,
                        width: 50.sp,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 8.0.sp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track['name'] ?? 'Unknown',
                              style: const TextStyle(
                                color: kWhiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              track['artists'][0]['name'] ?? 'Unknown Artist',
                              style: TextStyle(
                                color: kWhiteColor,
                                fontSize: 12.0.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          bookmarkController.isBookmarked(track['id'])
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: bookmarkController.isBookmarked(track['id'])
                              ? Colors.yellow
                              : kWhiteColor,
                        ),
                        onPressed: () {
                          bookmarkController.toggleBookmark(track['id']);
                          Get.snackbar(
                            bookmarkController.isBookmarked(track['id'])
                                ? 'Bookmarked'
                                : 'Removed',
                            '${track['name']} has been ${bookmarkController.isBookmarked(track['id']) ? 'added to' : 'removed from'} your playlist',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
