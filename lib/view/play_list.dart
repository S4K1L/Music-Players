import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/api/api_services.dart';
import 'package:music_player/controller/spotify_controller.dart';
import 'package:music_player/utils/constant/colors.dart';

class RecommendedPage extends StatelessWidget {
  final SpotifyController spotifyController = Get.put(SpotifyController());

  RecommendedPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch playlists on page load
    spotifyController.fetchPlaylists();

    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kBackGroundColor,
        elevation: 0,
        title: const Text(
          "Playlists",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(
            () => spotifyController.isLoading.value
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : spotifyController.tracks.isEmpty
            ? const Center(
          child: Text(
            'No playlists found',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTab("Playlists", isSelected: true),
                  _buildTab("Artists"),
                  _buildTab("Albums"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Playlist List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: spotifyController.tracks.length,
                itemBuilder: (context, index) {
                  final playlist = spotifyController.tracks[index];
                  return GestureDetector(
                    onTap: () {
                      spotifyController.fetchTracks(playlistId);
                      Get.snackbar('Selected', 'Playlist: ${playlist['name']}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(
                                    playlist['images'][0]['url']), // Dynamic image
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'by ${playlist['owner']['display_name']}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[800] : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
