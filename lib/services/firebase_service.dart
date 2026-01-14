import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // Collection Name: "user_history"
  static final CollectionReference historyRef = 
      FirebaseFirestore.instance.collection('user_history');

  static Future<void> saveInteraction({
    required String userText,
    required String aiResponse,
    required Map<String, dynamic>? product,
  }) async {
    try {
      await historyRef.add({
        'user_query': userText,
        'ai_response': aiResponse,
        'timestamp': FieldValue.serverTimestamp(),
        'has_product': product != null,
        // If there is a product, save its details too
        'product_data': product ?? {}, 
      });
      print("✅ Saved to Firebase!");
    } catch (e) {
      print("❌ Firebase Error: $e");
    }
  }
}