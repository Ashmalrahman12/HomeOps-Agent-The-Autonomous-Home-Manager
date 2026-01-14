import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:home_ops_agent/services/recommendation_service.dart';
import '../screens/purchase_screen.dart';

class HomeRecommendationCard extends StatelessWidget {
  const HomeRecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. LISTEN TO THE SERVICE LIVE 📡
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: RecommendationService().recommendationNotifier,
      builder: (context, topPick, child) {
        
        // A. IF EMPTY (Dark Placeholder) ⚫
        if (topPick == null) {
          return Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // DARK GREY (Not White)
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, color: Colors.white54),
                  SizedBox(height: 5),
                  Text("Chat with AI to see picks here!", style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          );
        }

        // B. IF PRODUCT EXISTS (Beautiful Dark Card) ✨
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => PurchaseScreen(product: topPick)
            ));
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1),
              boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                // IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: topPick['productImage'],
                    height: 80, width: 80, fit: BoxFit.cover,
                    errorWidget: (c,e,s) => Container(color: Colors.grey, child: const Icon(Icons.error)),
                  ),
                ),
                const SizedBox(width: 15),
                
                // TEXT INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(5)),
                        child: const Text("TOP PICK FOR YOU", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        topPick['productName'], 
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1, overflow: TextOverflow.ellipsis
                      ),
                      Text(
                        topPick['productPrice'], 
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 15, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}