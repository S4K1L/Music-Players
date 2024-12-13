import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:music_player/api/api_services.dart';

class SpotifyController extends GetxController {
  final audioPlayer = AudioPlayer();

  var isLoading = false.obs;
  var currentTrackIndex = 0.obs;
  var tracks = [].obs;
  var isPlaying = false.obs;
  var currentTrackProgress = 0.0.obs;
  var currentTrackDuration = 0.0.obs;

  String get currentTrackName => tracks.isNotEmpty
      ? tracks[currentTrackIndex.value]['track']['name']
      : 'Unknown';
  String get currentTrackArtist => tracks.isNotEmpty
      ? tracks[currentTrackIndex.value]['track']['artists'][0]['name']
      : 'Unknown';

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
      if (duration != null) {
        currentTrackDuration.value = duration.inSeconds.toDouble();
      }
    });

    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        stopPlayback();
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

  Future<void> fetchTracks(String playlistId) async {
    try {
      isLoading(true);
      final token = await getAccessToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        tracks.value = jsonDecode(response.body)['items'];
      } else {
        Get.snackbar('Error', 'Failed to fetch tracks: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching tracks: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void togglePlayback() async {
    if (audioPlayer.playing) {
      audioPlayer.pause();
      isPlaying(false);
    } else {
      audioPlayer.play();
      isPlaying(true);
    }
  }

  void stopPlayback() {
    audioPlayer.stop();
    isPlaying(false);
    currentTrackProgress.value = 0.0;
  }

  void previousTrack() {
    if (currentTrackIndex.value > 0) {
      currentTrackIndex.value--;
      _playCurrentTrack();
    } else {
      Get.snackbar('Info', 'This is the first track.');
    }
  }

  void nextTrack() {
    if (currentTrackIndex.value < tracks.length - 1) {
      currentTrackIndex.value++;
      _playCurrentTrack();
    } else {
      Get.snackbar('Info', 'This is the last track.');
    }
  }

  void _playCurrentTrack() async {
    try {
      final trackUrl = tracks[currentTrackIndex.value]['track']['preview_url'];
      if (trackUrl != null) {
        await audioPlayer.setUrl(trackUrl);
        togglePlayback();
      } else {
        Get.snackbar('Error', 'Preview URL is not available for this track.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error playing track: ${e.toString()}');
    }
  }

  void playTrack(int index) async {
    try {
      if (index < 0 || index >= tracks.length) {
        Get.snackbar('Error', 'Invalid track index.');
        return;
      }
      currentTrackIndex.value = index;
      final trackUrl = tracks[index]['track']['preview_url'];
      if (trackUrl != null) {
        await audioPlayer.setUrl(trackUrl);
        togglePlayback();
      } else {
        Get.snackbar('Error', 'Preview URL is not available for this track.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error playing track: ${e.toString()}');
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
        tracks.value = jsonDecode(response.body)['playlists']['items'];
      } else {
        Get.snackbar('Error', 'Failed to fetch playlists: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching playlists: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

}
