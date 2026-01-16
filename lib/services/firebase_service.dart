import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Reference to the 'user_history' collection in Firestore
  static final CollectionReference historyRef = 
      FirebaseFirestore.instance.collection('user_history');

  /// SAVES an interaction to Firestore linked to the specific logged-in user
  static Future<void> saveInteraction({
    required String userText,
    required String aiResponse,
    required Map<String, dynamic>? product,
  }) async {
    try {
      // 1. Get the CURRENT logged-in user from Firebase Auth
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("❌ No user logged in. Data not saved.");
        return;
      }

      // 2. Save the data WITH the userId to ensure User 2 doesn't see User 1's data
      await historyRef.add({
        'userId': currentUser.uid,        // Links data to the specific user
        'user_email': currentUser.email,   // Helpful for debugging in Firebase Console
        'user_query': userText,
        'ai_response': aiResponse,
        'timestamp': FieldValue.serverTimestamp(),
        'has_product': product != null,
        // If there is a product, save its details too
        'product_data': product ?? {}, 
      });
      
      print("✅ Saved to Firebase for user: ${currentUser.email}");
    } catch (e) {
      print("❌ Firebase Error while saving: $e");
    }
  }

  /// FETCHES a stream of history records ONLY for the currently logged-in user
  static Stream<QuerySnapshot> getUserHistory() {
    // 1. Get the current user ID
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    // 2. If no user is found, return an empty stream to avoid crashes
    if (currentUser == null) {
      return const Stream.empty();
    }

    // 3. Query the collection: 
    // - Filter by userId (so User 2 only sees User 2's data)
    // - Order by timestamp (newest first)
    return historyRef
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}