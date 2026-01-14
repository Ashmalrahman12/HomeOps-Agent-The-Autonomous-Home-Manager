import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:home_ops_agent/services/recommendation_service.dart';
import 'purchase_screen.dart'; // Import your purchase screen

class RecommendScreen extends StatefulWidget {
  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  // 1. The Main "Hero" Product (AI Suggestion)
  Map<String, dynamic>? _topPick;
  
  // 2. Other Related Products
  List<Map<String, dynamic>> _relatedItems = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    final service = RecommendationService();
    
    setState(() {
      // Get the main product from AI (if any)
      _topPick = service.lastAiRecommendation;

      // If AI gave us related items (using the logic we added before), use them.
      // Otherwise, show generic popular items.
      if (service.relatedProducts.isNotEmpty) {
        _relatedItems = service.relatedProducts;
      } else {
        _relatedItems = [
          {
            "title": "Universal Tool Kit",
            "price": "45 USDC",
            "image": "https://images.unsplash.com/photo-1581235720704-06d3acfcb36f?auto=format&fit=crop&w=400&q=80",
            "rating": 4.5
          },
          {
            "title": "Safety Gloves",
            "price": "12 USDC",
            "image": "https://images.unsplash.com/photo-1615826932727-4f6c9133939a?auto=format&fit=crop&w=400&q=80",
            "rating": 4.8
          },
          {
             "title": "Digital Multimeter",
             "price": "35 USDC",
             "image": "https://images.unsplash.com/photo-1585338107529-13afc5f02586?auto=format&fit=crop&w=400&q=80",
             "rating": 4.7
          }
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Just For You", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // ------------------------------------------------
            // SECTION 1: THE REASON (Context)
            // ------------------------------------------------
            if (_topPick != null) ...[
              const Text(
                "Based on your recent repair chat", 
                style: TextStyle(color: Colors.grey, fontSize: 14)
              ),
              const SizedBox(height: 10),
            ],

            // ------------------------------------------------
            // SECTION 2: THE "TOP PICK" (Hero Card)
            // ------------------------------------------------
            if (_topPick != null) 
              GestureDetector(
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(
                     builder: (_) => PurchaseScreen(product: _topPick!)
                   ));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent.withOpacity(0.2), Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(8)),
                            child: const Text("AI MATCH 98%", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          const Icon(Icons.verified, color: Colors.blueAccent),
                        ],
                      ),
                      const SizedBox(height: 15),
                      CachedNetworkImage(
                        imageUrl: _topPick!['productImage'],
                        height: 150, fit: BoxFit.contain,
                        placeholder: (c, u) => Container(color: Colors.grey[900]),
                        errorWidget: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _topPick!['productName'], 
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _topPick!['productPrice'], 
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
              )
            else 
              // Fallback if no AI Chat happened yet
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
                child: const Column(
                  children: [
                     Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 40),
                     SizedBox(height: 10),
                     Text("Chat with AI to get personalized picks!", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // SECTION 3: RELATED ITEMS (Grid)
            // ------------------------------------------------
            const Text(
              "Similar Options", 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 15),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row
                childAspectRatio: 0.75, // Taller cards
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: _relatedItems.length,
              itemBuilder: (context, index) {
                final item = _relatedItems[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to Buy Page for these items too
                    Navigator.push(context, MaterialPageRoute(
                     builder: (_) => PurchaseScreen(product: {
                       "productName": item['title'],
                       "productPrice": item['price'],
                       "productImage": item['image']
                     })
                   ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: item['image'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorWidget: (c,e,s) => const Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Text(item['price'], style: const TextStyle(color: Colors.blueAccent)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            Text(" ${item['rating']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}