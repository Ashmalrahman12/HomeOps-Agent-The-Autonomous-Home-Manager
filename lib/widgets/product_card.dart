import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String oldPrice;
  final double rating;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // 1. Product Image
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 15),
          
          // 2. Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: const Text("AI Recommended", style: TextStyle(fontSize: 10, color: Colors.blueAccent)),
                ),
                const SizedBox(height: 5),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                    const SizedBox(width: 8),
                    Text(oldPrice, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(" $rating", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}