import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/controller/spotify_controller.dart';
import 'package:music_player/utils/constant/colors.dart';

class RecommendedPage extends StatelessWidget {
  final SpotifyController spotifyController = Get.put(SpotifyController());

  RecommendedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kBackGroundColor,
        elevation: 0,
        title: const Text(
          "Bookmarked Songs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(
            () {
          final bookmarkedTracks = spotifyController.bookmarkedTracks
              .map((id) => spotifyController.tracks
              .firstWhereOrNull((track) => track['id'] == id))
              .where((track) => track != null)
              .toList();

          if (bookmarkedTracks.isEmpty) {
            return const Center(
              child: Text(
                'No bookmarked songs yet!',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: bookmarkedTracks.length,
            itemBuilder: (context, index) {
              final track = bookmarkedTracks[index]!;
              return GestureDetector(
                onTap: () {
                  if (track['preview_url'] != null) {
                    spotifyController.playTrack(index);
                  } else {
                    Get.snackbar('Unavailable', 'No preview available for this track');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildTrackImage(track['album']['images'][0]['url']),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          track['name'] ?? 'Unknown',
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          spotifyController.toggleBookmark(track['id']);
                          Get.snackbar(
                            'Removed',
                            '${track['name']} removed from bookmarks',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTrackImage(String imageUrl) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
