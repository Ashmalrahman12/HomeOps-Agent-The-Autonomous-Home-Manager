import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:home_ops_agent/config/secrets.dart'; // Keep your secrets file

class AiService {
  final String apiKey = geminiApiKey; 
  

  // --- CENTRAL BRAIN FUNCTION ---
  // This handles both Video (Image) and Chat (Text only)
  Future<Map<String, dynamic>> _generateResponse({
    String? imagePath, 
    
    required String userQuestion, 
    required bool isMalayalam
  }) async {
    
    // Use the stable Flash model
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    
    String lang = isMalayalam ? "Malayalam" : "English";
    String currency = "Indian Rupees (₹)";

    // --- THE SMART PROMPT (HACKATHON OPTIMIZED) ---
    String systemInstruction = """
    You are an Expert Home Technician & Shopping Assistant.
    User Question: "$userQuestion"
    
    STRICT RULES:
    1. Language: Reply in $lang.
    2. Currency: ALWAYS use $currency for prices. (e.g. ₹450, not \$5).
    
    3. REPAIR FIRST LOGIC:
       - If user says "broken", "not working", "repair", or "fix":
         Your goal is to help them FIX it. Suggest a spare part (e.g., "Thermal Fuse", "Capacitor", "New Battery").
         Only suggest a brand new product if it is unfixable.
       - If user says "buy", "new", or "upgrade":
         Suggest the best new replacement product.

    FORMAT YOUR RESPONSE LIKE THIS:
    [Spoken Friendly Advice] ### [Product Name] | [Price] | [ImageKeyword]

    EXAMPLES:
    User: "My iron box is not working"
    AI: It sounds like a heating element issue. You might just need a new fuse. ### Thermal Fuse for Iron Box | ₹150 | electronic fuse

    User: "I want a new mouse"
    AI: This Logitech mouse is excellent for work. ### Logitech M331 Silent Mouse | ₹899 | black computer mouse

    (If no product is needed, just give the Spoken Answer without ###)
    """;

    try {
      GenerateContentResponse response;
      
      if (imagePath != null) {
        // VIDEO MODE (Image + Text)
        final imageFile = File(imagePath);
        final imageBytes = await imageFile.readAsBytes();
        response = await model.generateContent([
          Content.multi([TextPart(systemInstruction), DataPart('image/jpeg', imageBytes)])
        ]);
      } else {
        // CHAT MODE (Text Only)
        response = await model.generateContent([Content.text(systemInstruction)]);
      }

      return _formatResponse(response.text ?? "");
    } catch (e) {
      print("AI Error: $e");
      return {"answer": "Connection Error. Please check internet.", "hasProduct": false};
    }
  }

  // --- PUBLIC METHODS CALLING THE BRAIN ---

  // 1. Called by Live Video Camera
  Future<Map<String, dynamic>> analyzeImage(String imagePath, String userQuestion, bool isMalayalam) async {
    return _generateResponse(
      imagePath: imagePath, 
      userQuestion: userQuestion, 
      isMalayalam: isMalayalam
    );
  }

  // 2. Called by Text Chat
  Future<Map<String, dynamic>> chatWithGemini(String userQuestion, bool isMalayalam) async {
    return _generateResponse(
      imagePath: null, // No image for text chat
      userQuestion: userQuestion, 
      isMalayalam: isMalayalam
    );
  }
  

  // --- HELPER TO FORMAT DATA ---
  Map<String, dynamic> _formatResponse(String fullText) {
    if (fullText.contains("###")) {
      var parts = fullText.split("###");
      var productParts = parts[1].split("|");
      
      // Get the keyword for the image
      String keyword = productParts.last.trim();
      
      return {
        "answer": parts[0].trim(),
        "hasProduct": true,
        "productName": productParts[0].trim(),
        "productPrice": productParts.length > 1 ? productParts[1].trim() : "Check Price",
        
        // NEW IMAGE GENERATOR (Pollinations AI) - Works perfectly!
        // We add 'nologo' to keep it clean and 'seed' to make it random every time.
        "productImage": "https://image.pollinations.ai/prompt/$keyword product realistic high quality?width=400&height=400&nologo=true&seed=${DateTime.now().millisecondsSinceEpoch}"
      };
    } else {
      return {"answer": fullText, "hasProduct": false};
    }
  }
}