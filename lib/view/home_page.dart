import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    spotifyController.fetchTracks('your_playlist_id');
    return Scaffold(
      backgroundColor: kBackGroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getGreetingMessage(),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Horizontal Grid of Cards
              Obx(
                    () => spotifyController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
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
                    final track = spotifyController.tracks[index]['track'];
                    return GestureDetector(
                      onTap: () => spotifyController.playTrack(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    track['album']['images'][0]['url'], // Album cover
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                track['name'], // Track name
                                style: const TextStyle(color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Section: Jump Back In
              const Text(
                "Jump Back In",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Obx(() => _buildHorizontalList(spotifyController.tracks)),

              const SizedBox(height: 20),

              // Playback Controls
              Obx(
                    () => spotifyController.tracks.isNotEmpty
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
                          icon: const Icon(Icons.skip_previous, color: Colors.white),
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
                    Obx(
                          () => Slider(
                        value: spotifyController.currentTrackProgress.value,
                        max: spotifyController.currentTrackDuration.value,
                        onChanged: (value) {
                          spotifyController.audioPlayer.seek(
                            Duration(seconds: value.toInt()),
                          );
                        },
                      ),
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Section: Your Shows
              const Text(
                "Your Shows",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Obx(() => _buildHorizontalList(spotifyController.tracks)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<dynamic> tracks) {
    return SizedBox(
      height: 150,
      child: tracks.isEmpty
          ? const Center(child: Text("No tracks available", style: TextStyle(color: Colors.white)))
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index]['track'];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => spotifyController.playTrack(index),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(
                          track['album']['images'][0]['url'], // Album cover
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  track['name'], // Track name
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
