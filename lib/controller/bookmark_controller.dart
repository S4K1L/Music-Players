import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class BookmarkController extends GetxController {
  var bookmarkedTracks = <String>{}.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get userId => auth.currentUser?.uid ?? "";

  bool isBookmarked(String trackId) => bookmarkedTracks.contains(trackId);

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
  }
}
