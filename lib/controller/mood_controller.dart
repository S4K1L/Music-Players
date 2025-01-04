import 'dart:convert';

import 'package:get/get.dart';
import 'package:music_player/controller/spotify_controller.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodController extends GetxController {
  final SpotifyController spotifyController = SpotifyController();

  final RxString selectedMood = ''.obs;
  final RxList<Map<String, dynamic>> recommendedTracks =
      <Map<String, dynamic>>[].obs;

  var bookmarkedTracks = <String>{}.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get userId => auth.currentUser?.uid ?? "";

  bool isBookmarked(String trackId) => bookmarkedTracks.contains(trackId);

  void selectMood(String mood) async {
    selectedMood.value = mood;
    try {
      final tracks = await fetchTopTracks(mood);
      recommendedTracks.assignAll(tracks);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> fetchBookmarksFromFirestore() async {
    if (userId.isNotEmpty) {
      try {
        var snapshot = await firestore
            .collection('bookmarks')
            .doc(userId)
            .collection('tracks')
            .get();

        bookmarkedTracks.clear();
        for (var doc in snapshot.docs) {
          bookmarkedTracks.add(doc.id);
        }
      } catch (e) {
        print("Error fetching bookmarks: $e");
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchTopTracks(String searchQuery) async {
    try {
      print('Fetching access token...');
      final accessToken = await spotifyController.getAccessToken();
      print('Access token obtained: $accessToken');

      // Map moods to corresponding genres
      final moodToGenreMap = {
        'calm': 'classical,ambient',
        'happy': 'pop,dance',
        'sad': 'blues,acoustic',
        'energetic': 'rock,edm',
        // Add more mood-to-genre mappings as needed
      };

      // Replace the search query with the corresponding genres
      final genres = moodToGenreMap[searchQuery.toLowerCase()] ?? searchQuery;
      print('Mapped search query (genres): $genres');

      // Step 4: Fetch tracks using the genres
      final url =
          Uri.parse('https://api.spotify.com/v1/search?q=$genres&type=track');
      print('URL created: $url');

      print('Sending GET request to Spotify API...');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      print('Response received with status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response body: ${json.encode(data)}');

        // Filter tracks that contain the selected mood in their name
        return List<Map<String, dynamic>>.from(data['tracks']['items'])
            .where((track) => !track['name']
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList()
          ..shuffle();
      } else {
        print('Error: Non-200 status code received.');
        print('Response body: ${response.body}');
        throw Exception('Failed to fetch tracks: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An exception occurred: $e');
      throw Exception('Failed to fetch tracks: $e');
    }
  }
}
