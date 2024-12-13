import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/controller/spotify_controller.dart';
import 'package:music_player/utils/constant/colors.dart';
import 'package:music_player/utils/constant/constant.dart';

class MusicPlayerPage extends StatelessWidget {
  MusicPlayerPage({super.key});
  final SpotifyController spotifyController = Get.put(SpotifyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      body: Obx(
            () => spotifyController.isLoading.value
            ? Center(
          child: CircularProgressIndicator(),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album Art
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  spotifyController.tracks.isNotEmpty
                      ? spotifyController.tracks[
                  spotifyController.currentTrackIndex.value]['track']['album']['images'][0]['url']
                      : logo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Song Title and Artist
            Column(
              children: [
                Text(
                  spotifyController.currentTrackName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  spotifyController.currentTrackArtist,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Progress Bar
            Column(
              children: [
                Slider(
                  value: spotifyController.currentTrackProgress.value,
                  min: 0,
                  max: spotifyController.currentTrackDuration.value,
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
                  onChanged: (value) {
                    spotifyController.audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(Duration(seconds: spotifyController.currentTrackProgress.value.toInt())),
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        formatDuration(Duration(seconds: spotifyController.currentTrackDuration.value.toInt())),
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Playback Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  color: Colors.white,
                  iconSize: 48,
                  onPressed: () {
                    spotifyController.previousTrack();
                  },
                ),
                SizedBox(width: 20),
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      spotifyController.isPlaying.value ? Icons.pause : Icons.play_arrow,
                    ),
                    color: Colors.black,
                    iconSize: 48,
                    onPressed: () {
                      spotifyController.togglePlayback();
                    },
                  ),
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  color: Colors.white,
                  iconSize: 48,
                  onPressed: () {
                    spotifyController.nextTrack();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
