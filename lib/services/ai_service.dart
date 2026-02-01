import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:home_ops_agent/config/secrets.dart'; 

class AiService {
  final String apiKey = geminiApiKey;

  Future<Map<String, dynamic>> _generateResponse({
    String? imagePath, 
    required String userQuestion, 
    required bool isMalayalam
  }) async {
    
    // Use the stable Flash model
    final model = GenerativeModel(model: 'gemini-3-pro-preview', apiKey: apiKey);
    
    String lang = isMalayalam ? "Malayalam" : "English";
    String currency = "Indian Rupees (₹)";

    // --- PROMPT WITH YOUR EXAMPLES (CONVERTED TO JSON) ---
    String systemInstruction = """
    You are an Expert Home Technician & Shopping Assistant.
    User Question: "$userQuestion"
    Language: $lang
    Currency: $currency

    STRICT RULES:

    1. ANALYZE THE IMAGE FIRST.
    2. If it is a **Handwritten List**, read ALL items and suggest a product for EACH.
    3. If it is a **Photo of a Device/Appliance**, diagnose the issue and suggest relevant products.
    4. ALWAYS RESPOND IN $lang.
    5. ALWAYS SUGGEST PRODUCTS FROM THE INDIAN MARKET (₹).
    6. MEDICAL LOGIC (Highest Priority):
       - If the image is a Medical Bill, Prescription, or Medicine Strip:
       - Extract the Medicine Name.
       - Suggest the exact medicine with price in INR.
       - Set "category" to "health".
       - Suggest a generic image keyword like "medicine box" or "pills".
    7. REPAIR FIRST LOGIC: 
       - If user says "broken/fix", suggest a spare part (fuse, battery). 
       - Only suggest a new product if unfixable or requested.
    8. ALWAYS RETURN A VALID JSON with "answer", "isList", and "products" FIELDS ONLY.
      

    RETURN RESPONSE AS PURE JSON (No markdown):
    {
      "answer": "Spoken advice goes here...",
      "isList": true/false,
      "products": [
        { "name": "Product Name", "price": "₹Price", "keyword": "simple image keyword" }
      ]
    }

    EXAMPLES (LEARN FROM THESE):

    User: "My iron box is not working"
    AI: {
      "answer": "It sounds like a heating element issue. You might just need a new fuse.",
      "isList": false,
      "products": [
        { "name": "Thermal Fuse for Iron Box", "price": "₹150", "keyword": "electronic thermal fuse" }
      ]
    }

    User: "I want a new mouse"
    AI: {
      "answer": "This Logitech mouse is excellent for work.",
      "isList": false,
      "products": [
        { "name": "Logitech M331 Silent Mouse", "price": "₹899", "keyword": "black computer mouse" }
      ]
    }
    
    User: 
    AI: {
      "answer": "I found a shopping list. Here are the items.",
      "isList": true,
      "products": [
        { "name": "Smartphone", "price": "₹12000", "keyword": "smartphone" },
        { "name": "Cotton Shirt", "price": "₹800", "keyword": "blue shirt" },
        { "name": "Running Shoes", "price": "₹2500", "keyword": "running shoes" }
      ]
    }
    """;

    try {
      GenerateContentResponse response;
      
      if (imagePath != null) {
        final imageFile = File(imagePath);
        final imageBytes = await imageFile.readAsBytes();
        response = await model.generateContent([
          Content.multi([TextPart(systemInstruction), DataPart('image/jpeg', imageBytes)])
        ]);
      } else {
        response = await model.generateContent([Content.text(systemInstruction)]);
      }

      return _parseJsonResponse(response.text ?? "");
    } catch (e) {
      print("AI Error: $e");
      return {
        "answer": "I couldn't read that. Please try again.", 
        "hasProduct": false, 
        "products": []
      };
    }
  }

  // --- PUBLIC METHODS ---
  Future<Map<String, dynamic>> analyzeImage(String imagePath, String userQuestion, bool isMalayalam) async {
    return _generateResponse(imagePath: imagePath, userQuestion: userQuestion, isMalayalam: isMalayalam);
  }

  Future<Map<String, dynamic>> chatWithGemini(String userQuestion, bool isMalayalam) async {
    return _generateResponse(imagePath: null, userQuestion: userQuestion, isMalayalam: isMalayalam);
  }

  // --- JSON PARSER & IMAGE GENERATOR ---
  Map<String, dynamic> _parseJsonResponse(String text) {
    try {
      String cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      Map<String, dynamic> data = jsonDecode(cleanText);
      
      List<dynamic> rawProducts = data['products'] ?? [];
      List<Map<String, dynamic>> processedProducts = [];

      for (var item in rawProducts) {
        String keyword = item['keyword'] ?? "product";
        String seed = DateTime.now().millisecondsSinceEpoch.toString() + keyword; 
        
        processedProducts.add({
          "productName": item['name'],
          "productPrice": item['price'],
          // Generates a unique image for EVERY item in the list
          "productImage": "https://image.pollinations.ai/prompt/realistic $keyword photo isolated on white background?nologo=true&seed=$seed"
        });
      }

      return {
        "answer": data['answer'],
        "hasProduct": processedProducts.isNotEmpty,
        "isList": data['isList'] ?? false,
        "products": processedProducts, // The full list of items
        
        // Single item fallback (for old code support)
        "productName": processedProducts.isNotEmpty ? processedProducts[0]['productName'] : "",
        "productPrice": processedProducts.isNotEmpty ? processedProducts[0]['productPrice'] : "",
        "productImage": processedProducts.isNotEmpty ? processedProducts[0]['productImage'] : "",
      };

    } catch (e) {
      print("JSON Parse Error: $e");
      return { "answer": text, "hasProduct": false, "products": [] };
    }
  }
}