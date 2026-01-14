import 'package:flutter/material.dart';

class ChatProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ChatProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220, // Compact width like the screenshot
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. PRODUCT IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              product['productImage'],
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 120, 
                color: Colors.grey[200], 
                child: const Icon(Icons.broken_image, color: Colors.grey)
              ),
            ),
          ),
          
          // 2. DETAILS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['productName'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 5),
                Text(
                  product['productPrice'],
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 10),
                
                // 3. ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 35),
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text("Details", style: TextStyle(fontSize: 12, color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(0, 35),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text("Buy", style: TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}