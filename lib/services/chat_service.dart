import 'firebase_service.dart'; // Import the new service

class ChatService {
  static final List<Map<String, dynamic>> history = [];

  // This function adds to Local List AND Firebase
  static void addMessage(String role, String text, [Map<String, dynamic>? product]) {
    
    // 1. Add to Local Memory (for the Chat Screen)
    history.add({
      "role": role,
      "text": text,
      "time": DateTime.now().toString(),
      "product": product
    });

    // 2. If it's an AI message, save the WHOLE interaction to Firebase
    if (role == "ai") {
      // We assume the last message was the user.
      String lastUserText = history.length > 1 
          ? history[history.length - 2]['text'] 
          : "Unknown Query";

      FirebaseService.saveInteraction(
        userText: lastUserText,
        aiResponse: text,
        product: product,
      );
    }
  }
}