import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:music_player/api/api_services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:music_player/controller/bookmark_controller.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // For detecting mobile platforms
import 'package:flutter/foundation.dart';
import '../utils/web_handle/safe_js.dart'; // For kIsWeb

class SpotifyController extends GetxController {
  final audioPlayer = AudioPlayer();

  final BookmarkController bookmarkController = Get.put(BookmarkController());
  var isLoading = false.obs;
  var currentTrackIndex = 0.obs;
  var currentTrack = Rxn<Map<String, dynamic>>(); // Nullable Map
  var tracks = <Map<String, dynamic>>[].obs;
  var playList = <Map<String, dynamic>>[].obs;
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
      final credentials =
          base64.encode(utf8.encode('$apiClientId:$apiClientSecret'));
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

  Future<void> fetchPlayList() async {
    try {
      print("-----------------------------------------");
      isLoading(true);
      final token = await getAccessToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        playList.value = (responseData['items'] as List)
            .map((item) => item['track'] as Map<String, dynamic>)
            .where((track) =>
                track['album'] != null && track['album']['images'] != null)
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

  Future<void> fetchTrackList(String playlistId) async {
    try {
      isLoading(true);
      final token = await getAccessToken();
      if (token == null) {
        print('Failed to retrieve access token');
        return;
      }

      // Fetch tracks for the specified playlist
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final playlistTracks = (jsonDecode(response.body)['items'] as List)
            .map((item) => item['track'] as Map<String, dynamic>)
            .toList();

        // Get all bookmarked track IDs
        final bookmarkedTrackIds = bookmarkController.bookmarkedTracks;

        // Filter bookmarked tracks not in the playlist
        final playlistTrackIds =
            playlistTracks.map((track) => track['id']).toSet();
        final missingBookmarkedTrackIds = bookmarkedTrackIds
            .where((id) => !playlistTrackIds.contains(id))
            .toList();

        // Fetch data for missing bookmarked tracks
        final List<Map<String, dynamic>> missingBookmarkedTracks = [];
        for (final id in missingBookmarkedTrackIds) {
          final trackResponse = await http.get(
            Uri.parse('https://api.spotify.com/v1/tracks/$id'),
            headers: {'Authorization': 'Bearer $token'},
          );

          if (trackResponse.statusCode == 200) {
            final trackData =
                jsonDecode(trackResponse.body) as Map<String, dynamic>;
            missingBookmarkedTracks.add(trackData);
          } else {
            print('Failed to fetch track data for ID $id');
          }
        }

        // Combine playlist tracks with fetched bookmarked tracks
        tracks.value = [...playlistTracks, ...missingBookmarkedTracks];
      } else {
        Get.snackbar(
            'Error', 'Failed to fetch playlist tracks: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching tracks: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }


  void playTrack(String trackId) async {
    if (trackId.isEmpty) {
      Get.snackbar(
        'Playback Error',
        'Track ID is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Construct Spotify URL
    final spotifyUrl = Uri.parse("https://open.spotify.com/track/$trackId");

    try {
      // Use launchUrl with options for better compatibility
      final bool launched = await launchUrl(
        spotifyUrl,
        mode: LaunchMode.externalApplication, // Ensures external browser or app
      );

      if (!launched) {
        throw 'Could not launch Spotify URL.';
      }
    } catch (e) {
      // Log error and show a snackbar
      print('Failed to open URL: $e');
      Get.snackbar(
        'Error',
        'Failed to open Spotify URL. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  Future<void> launchSpotifyUrl(String url) async {
    try {
      if (kIsWeb) {
        // Web environment
        print("Opening URL in web browser: $url");
        SafeJs.openUrl(url); // Handle web-specific URL opening
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile environment
        print("Opening URL on mobile: $url");
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception("Could not launch URL: $url");
        }
      } else {
        // Unsupported platform
        print("Unsupported platform for opening URL: $url");
      }
    } catch (e) {
      print("Error opening URL: $e");
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
      playTrack(tracks[currentTrackIndex.value]['id']);
    } else {
      Get.snackbar('Info', 'This is the first track.');
    }
  }

  void nextTrack() {
    if (currentTrackIndex.value < tracks.length - 1) {
      currentTrackIndex.value++;
      playTrack(tracks[currentTrackIndex.value]['id']);
    } else {
      Get.snackbar('Info', 'This is the last track.');
    }
  }
}
