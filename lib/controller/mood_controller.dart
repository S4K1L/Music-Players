import 'dart:convert';

import 'package:get/get.dart';
import 'package:music_player/controller/spotify_controller.dart';
import 'package:http/http.dart' as http;

class MoodController extends GetxController {
  final SpotifyController spotifyController = SpotifyController();

  final RxString selectedMood = ''.obs;
  final RxList<Map<String, dynamic>> recommendedTracks = <Map<String, dynamic>>[].obs;

  void selectMood(String mood) async {
    selectedMood.value = mood;
    try {
      final tracks = await fetchTracks(mood);
      recommendedTracks.assignAll(tracks);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchTracks(String mood) async {
    final accessToken = await spotifyController.getAccessToken();
    final url = Uri.parse('https://api.spotify.com/v1/recommendations?seed_genres=$mood');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['tracks']);
    } else {
      throw Exception('Failed to fetch tracks');
    }
  }
}
