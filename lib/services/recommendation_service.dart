import 'package:flutter/material.dart';

class RecommendationService {
  // Singleton Pattern
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  // 1. MAIN RECOMMENDATION NOTIFIER 📡
  final ValueNotifier<Map<String, dynamic>?> recommendationNotifier = ValueNotifier(null);

  // Getter for the main product
  Map<String, dynamic>? get lastAiRecommendation => recommendationNotifier.value;

  // 2. RELATED PRODUCTS LIST (This was missing! 🔧)
  List<Map<String, dynamic>> _relatedProducts = [];
  
  // Getter accessed by your screen
  List<Map<String, dynamic>> get relatedProducts => _relatedProducts;

  // 3. SETTER FUNCTION
  void setRecommendation(Map<String, dynamic> product) {
    print("✅ UPDATING RECOMMENDATION: ${product['productName']}");
    recommendationNotifier.value = product;
    
    // Note: If you want to clear/set related products dynamically later, 
    // you can add logic here. For now, it keeps the list empty so your 
    // UI falls back to the hardcoded 'Safety Gloves' list.
    _relatedProducts = []; 
  }
  
  // Helper to manually set related items if needed
  void setRelatedProducts(List<Map<String, dynamic>> items) {
    _relatedProducts = items;
  }
}