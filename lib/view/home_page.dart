import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:music_player/api/api_services.dart';
import 'package:music_player/controller/bookmark_controller.dart';
import 'package:music_player/controller/spotify_controller.dart';
import 'package:music_player/utils/constant/colors.dart';

class HomePage extends StatelessWidget {
  final SpotifyController spotifyController = Get.put(SpotifyController());
  final BookmarkController bookmarkController = Get.put(BookmarkController());

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
          padding: EdgeInsets.all(16.0.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopSection(),
              SizedBox(height: 16.sp),
              _buildTrackGrid(),
              SizedBox(height: 20.sp),
              _buildSectionHeader("Jump Back In"),
              SizedBox(height: 10.sp),
              Obx(() => _buildHorizontalList(spotifyController.tracks)),
              SizedBox(height: 20.sp),
              _buildPlaybackControls(),
              SizedBox(height: 20.sp),
              _buildSectionHeader("Your Shows"),
              SizedBox(height: 10.sp),
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.sp,
        mainAxisSpacing: 8.sp,
        childAspectRatio: 3.sp,
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
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: Row(
              children: [
                _buildTrackImage(track['album']['images'][0]['url']),
                SizedBox(width: 8.sp),
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
                    bookmarkController.isBookmarked(track['id'])
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: bookmarkController.isBookmarked(track['id'])
                        ? Colors.yellow
                        : Colors.white,
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
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.sp),
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
                        size: 40.sp,
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
      height: 150.sp,
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
                      padding: EdgeInsets.only(right: 16.0.sp),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => spotifyController.playTrack(index),
                            child: _buildTrackImage(imageUrl),
                          ),
                          SizedBox(height: 8.sp),
                          Text(
                            trackName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 10.sp,
                      child: IconButton(
                        icon: Icon(
                          bookmarkController.isBookmarked(trackId)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: bookmarkController.isBookmarked(trackId)
                              ? Colors.yellow
                              : Colors.white,
                        ),
                        onPressed: () {
                          bookmarkController.toggleBookmark(trackId);
                          Get.snackbar(
                            bookmarkController.isBookmarked(trackId)
                                ? 'Bookmarked'
                                : 'Removed',
                            '$trackName has been ${bookmarkController.isBookmarked(trackId) ? 'added to' : 'removed from'} your playlist',
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
      height: 100.sp,
      width: 100.sp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.sp),
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
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
