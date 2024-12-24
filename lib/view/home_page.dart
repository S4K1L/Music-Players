import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/api/api_services.dart';
import 'package:music_player/controller/spotify_controller.dart';
import 'package:music_player/utils/constant/colors.dart';

class HomePage extends StatelessWidget {
  final SpotifyController spotifyController = Get.put(SpotifyController());

  HomePage({super.key});

  String getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 16) {
      return "Good Afternoon";
    } else if (hour < 19) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  @override
  Widget build(BuildContext context) {

    /// change it when your api works perfectly
    spotifyController.fetchTrackList(playlistId); // change it when your api works perfectly
    return Scaffold(
      backgroundColor: kBackGroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopSection(),
              const SizedBox(height: 16),
              _buildTrackGrid(),
              const SizedBox(height: 20),
              _buildSectionHeader("Jump Back In"),
              const SizedBox(height: 10),
              Obx(() => _buildHorizontalList(spotifyController.tracks)),
              const SizedBox(height: 20),
              _buildPlaybackControls(),
              const SizedBox(height: 20),
              _buildSectionHeader("Your Shows"),
              const SizedBox(height: 10),
              Obx(() => _buildHorizontalList(spotifyController.tracks)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          getGreetingMessage(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3,
      ),
      itemCount: spotifyController.tracks.length,
      itemBuilder: (context, index) {
        final track = spotifyController.tracks[index];

        return GestureDetector(
          onTap: () {
            if (track['preview_url'] != null) {
              spotifyController.playTrack(index);
            } else {
              Get.snackbar(
                  'Unavailable', 'No preview available for this track');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
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
                  icon: Icon(
                    spotifyController.isBookmarked(track['id'])
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: spotifyController.isBookmarked(track['id'])
                        ? Colors.yellow
                        : Colors.white,
                  ),
                  onPressed: () {
                    spotifyController.toggleBookmark(track['id']);
                    Get.snackbar(
                      spotifyController.isBookmarked(track['id'])
                          ? 'Bookmarked'
                          : 'Removed',
                      '${track['name']} has been ${spotifyController.isBookmarked(track['id']) ? 'added to' : 'removed from'} your playlist',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaybackControls() {
    return Obx(
      () => spotifyController.currentTrack.value != null
          ? Column(
              children: [
                Text(
                  "Now Playing: ${spotifyController.currentTrackName} by ${spotifyController.currentTrackArtist}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: spotifyController.previousTrack,
                    ),
                    IconButton(
                      icon: Icon(
                        spotifyController.isPlaying.value
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: spotifyController.togglePlayback,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: spotifyController.nextTrack,
                    ),
                  ],
                ),
                Slider(
                  value: spotifyController.currentTrackProgress.value,
                  max: spotifyController.currentTrackDuration.value,
                  onChanged: (value) {
                    spotifyController.currentTrackProgress.value = value;
                    // Seek logic
                  },
                ),
              ],
            )
          : const Center(
              child: Text(
                "No track playing",
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildHorizontalList(List<dynamic> tracks) {
    return SizedBox(
      height: 150,
      child: tracks.isEmpty
          ? const Center(
              child: Text(
                "No tracks available",
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];

                // Validate track data
                if (track is! Map ||
                    track['album'] == null ||
                    track['album']['images'] == null ||
                    track['album']['images'].isEmpty ||
                    track['name'] == null ||
                    track['id'] == null) {
                  return const SizedBox.shrink(); // Skip invalid tracks
                }

                final imageUrl = track['album']['images'][0]['url'];
                final trackName = track['name'];
                final trackId = track['id'];

                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => spotifyController.playTrack(index),
                            child: _buildTrackImage(imageUrl),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trackName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 10,
                      child: IconButton(
                        icon: Icon(
                          spotifyController.isBookmarked(trackId)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: spotifyController.isBookmarked(trackId)
                              ? Colors.yellow
                              : Colors.white,
                        ),
                        onPressed: () {
                          spotifyController.toggleBookmark(trackId);
                          Get.snackbar(
                            spotifyController.isBookmarked(trackId)
                                ? 'Bookmarked'
                                : 'Removed',
                            '$trackName has been ${spotifyController.isBookmarked(trackId) ? 'added to' : 'removed from'} your playlist',
                          );
                        },
                      ),
                    )
                  ],
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
