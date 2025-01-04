import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:music_player/api/api_services.dart';

class BookmarkController extends GetxController {
  var bookmarkedTracks = <String>{}.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get userId => auth.currentUser?.uid ?? "";

  get http => null;

  bool isBookmarked(String trackId) => bookmarkedTracks.contains(trackId);

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

  Future<void> toggleBookmark(String trackId) async {
    if (isBookmarked(trackId)) {
      // Remove from local and Firestore
      bookmarkedTracks.remove(trackId);
      await removeBookmarkFromFirestore(trackId);
    } else {
      // Add to local and Firestore
      bookmarkedTracks.add(trackId);
      await addBookmarkToFirestore(trackId);
    }
  }

  Future<void> addBookmarkToFirestore(String trackId) async {
    if (userId.isNotEmpty) {
      await firestore
          .collection('bookmarks')
          .doc(userId)
          .collection('tracks')
          .doc(trackId)
          .set({'addedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> removeBookmarkFromFirestore(String trackId) async {
    if (userId.isNotEmpty) {
      await firestore
          .collection('bookmarks')
          .doc(userId)
          .collection('tracks')
          .doc(trackId)
          .delete();
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
    print("Bookmarks: $bookmarkedTracks");
  }

  Future<List<Map<String, dynamic>>> fetchBookmarkedTracks() async {
    final List<Map<String, dynamic>> fetchedTracks = [];
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('Failed to retrieve access token.');
      }

      for (final id in bookmarkedTracks) {
        final response = await http.get(
          Uri.parse('https://api.spotify.com/v1/tracks/$id'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final trackData = jsonDecode(response.body) as Map<String, dynamic>;
          fetchedTracks.add(trackData);
        } else {
          print(
              'Failed to fetch track with ID: $id. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching bookmarked tracks: $e');
    }

    print(bookmarkedTracks);

    return fetchedTracks;
  }
}
