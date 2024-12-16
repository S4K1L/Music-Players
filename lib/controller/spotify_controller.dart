import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:music_player/api/api_services.dart';

class SpotifyController extends GetxController {
  final audioPlayer = AudioPlayer();

  var isLoading = false.obs;
  var currentTrackIndex = 0.obs;
  var currentTrack = Rxn<Map<String, dynamic>>(); // Nullable Map
  var tracks = <Map<String, dynamic>>[].obs;
  var isPlaying = false.obs;
  var currentTrackProgress = 0.0.obs;
  var currentTrackDuration = 0.0.obs;

  String get currentTrackName => currentTrack.value?['name'] ?? 'Unknown';

  String get currentTrackArtist {
    final artists = currentTrack.value?['artists'] as List?;
    return (artists != null && artists.isNotEmpty)
        ? artists[0]['name'] ?? 'Unknown Artist'
        : 'Unknown Artist';
  }

  String get currentTrackAlbumImageUrl {
    final images = currentTrack.value?['album']?['images'] ?? [];
    return images.isNotEmpty ? images[0]['url'] ?? '' : '';
  }

  @override
  void onInit() {
    super.onInit();
    _initializePlayerListeners();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  void _initializePlayerListeners() {
    audioPlayer.positionStream.listen((position) {
      currentTrackProgress.value = position.inSeconds.toDouble();
    });

    audioPlayer.durationStream.listen((duration) {
      currentTrackDuration.value = duration?.inSeconds.toDouble() ?? 0.0;
    });

    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        nextTrack();
      }
    });
  }

  Future<String?> getAccessToken() async {
    try {
      final credentials = base64.encode(utf8.encode('$apiClientId:$apiClientSecret'));
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['access_token'];
      } else {
        throw Exception('Failed to fetch access token: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching access token: ${e.toString()}');
      return null;
    }
  }

  Future<void> fetchTracks() async {
    try {
      isLoading(true);
      final token = await getAccessToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        tracks.value = (responseData['items'] as List)
            .map((item) => item['track'] as Map<String, dynamic>)
            .where((track) =>
        track != null &&
            track['album'] != null &&
            track['album']['images'] != null)
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to fetch tracks: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching tracks: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPlaylists() async {
    try {
      isLoading(true);
      final token = await getAccessToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/browse/featured-playlists'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        tracks.value = (jsonDecode(response.body)['playlists']['items'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to fetch playlists: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching playlists: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void playTrack(int index) async {
    if (index >= 0 && index < tracks.length) {
      final track = tracks[index];
      final url = track['preview_url'];

      // Check if preview_url is available
      if (url == null || url.isEmpty) {
        Get.snackbar('Error', 'This track has no preview available.');
        return;
      }

      try {
        // Log the URL for debugging
        print('Playing track with URL: $url');
        // Load and play the track
        currentTrack.value = track;
        await audioPlayer.setUrl(url);
        await audioPlayer.play();
        isPlaying(true);
      } catch (e) {
        Get.snackbar('Error', 'Failed to play track: ${e.toString()}');
        print('Error playing track: $e');
      }
    }
  }


  void togglePlayback() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
      isPlaying(false);
    } else {
      await audioPlayer.play();
      isPlaying(true);
    }
  }

  void stopPlayback() async {
    await audioPlayer.stop();
    isPlaying(false);
    currentTrackProgress.value = 0.0;
  }

  void previousTrack() {
    if (currentTrackIndex.value > 0) {
      currentTrackIndex.value--;
      playTrack(currentTrackIndex.value);
    } else {
      Get.snackbar('Info', 'This is the first track.');
    }
  }

  void nextTrack() {
    if (currentTrackIndex.value < tracks.length - 1) {
      currentTrackIndex.value++;
      playTrack(currentTrackIndex.value);
    } else {
      Get.snackbar('Info', 'This is the last track.');
    }
  }
}
