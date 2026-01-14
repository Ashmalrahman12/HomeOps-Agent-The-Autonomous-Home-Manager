import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:home_ops_agent/config/secrets.dart';

class ProductGenerator {
  // ⚠️ YOUR API KEY
  static final String _apiKey = geminiApiKey; 

  static final List<String> _categories = [
    "Smartphone", "Laptop", "Headphones", "Smart Watch", "Drone",
    "Drill Machine", "Tool Kit", "Hammer", "Wrench",
    "Fresh Fruit", "Vegetables", "Milk", "Bread", "Eggs", "Ice Cream",
    "Medicine", "First Aid", "Vitamins", "Protein",
    "T-Shirt", "Shoes", "Jeans", "Watch", "Sofa", "Chair"
  ];

  static Future<int> generateNewBatch() async {
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
    int itemsAdded = 0;
    final random = Random();

    print("🤖 AI GENERATOR STARTED...");

    String cat1 = _categories[random.nextInt(_categories.length)];
    String cat2 = _categories[random.nextInt(_categories.length)];
    while (cat1 == cat2) {
      cat2 = _categories[random.nextInt(_categories.length)];
    }

    List<String> targetCategories = [cat1, cat2];

    for (String category in targetCategories) {
      print("🔍 ASKING GEMINI FOR: $category products...");

      try {
        final prompt = '''
          Generate 5 realistic e-commerce products for category: "$category".
          Return ONLY a JSON list.
          Fields: name, price (e.g. ₹500), rating (3.5-5.0), category (use lower case keyword).
        ''';

        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);

        if (response.text == null) continue;

        String jsonText = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        List<dynamic> items = jsonDecode(jsonText);

        WriteBatch batch = FirebaseFirestore.instance.batch();
        final collection = FirebaseFirestore.instance.collection('shop_inventory');

        for (var item in items) {
          DocumentReference doc = collection.doc();
          String prodName = item['name'];
          
          // ---------------------------------------------------------
          // 🚀 THE MAGIC TRICK: AI IMAGE URL GENERATOR
          // ---------------------------------------------------------
          // This creates a unique image based on the product name!
          String uniqueImage = "https://image.pollinations.ai/prompt/realistic%20product%20photo%20of%20$prodName%20isolated%20on%20white%20background?nologo=true";

          print("📦 NEW UPLOAD: $prodName"); 

          batch.set(doc, {
            "name": prodName,
            "price": item['price'],
            "rating": item['rating'],
            "category": item['category'],
            "image_url": uniqueImage, // <--- SAVING THE UNIQUE IMAGE
            "keywords": (prodName).toLowerCase().split(' '), 
            "timestamp": FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
        itemsAdded += items.length;
        print("✅ SUCCESS: Batch of ${items.length} $category items saved!"); 

      } catch (e) {
        print("❌ ERROR in $category: $e");
      }
    }
    
    return itemsAdded;
  }
}