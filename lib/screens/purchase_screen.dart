import 'package:flutter/material.dart';

class PurchaseScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const PurchaseScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Get screen height to size image dynamically
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark Background
      extendBodyBehindAppBar: true, // Make image go behind the back button
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent for modern look
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 1. SCROLL VIEW (Prevents Overflow Errors) 📜
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2. HERO IMAGE (Takes 45% of screen height)
            SizedBox(
              height: screenHeight * 0.45, 
              width: double.infinity,
              child: Hero(
                tag: product['productName'], 
                child: Image.network(
                  product['productImage'],
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag, size: 100, color: Colors.white54),
                ),
              ),
            ),
      
            // 3. PRODUCT DETAILS (Scrollable Part)
            Container(
              width: double.infinity,
              // Negative margin pulls the card UP over the image (Modern Look)
              transform: Matrix4.translationValues(0, -30, 0), 
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E), // Dark Card
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -5))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CENTER GRAB BAR (Visual cue that it's a card)
                  Center(
                    child: Container(
                      width: 50, height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  // TITLE & RATING
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['productName'],
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 5),
                      const Text("4.8", style: TextStyle(color: Colors.white70, fontSize: 18)),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // PRICE & CRYPTO BADGE
                  Row(
                    children: [
                      Text(
                        product['productPrice'],
                        style: const TextStyle(fontSize: 26, color: Colors.greenAccent, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueAccent)
                        ),
                        child: const Text("OR 150 HOC", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // DESCRIPTION
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "This is a premium item recommended by your AI Assistant based on your specific needs.\n\n"
                    "• Verified Quality\n"
                    "• Best Price in Market\n"
                    "• Instant Delivery Available\n"
                    "• Blockchain Warranty Included\n\n"
                    "Upgrade your home setup with this reliable product.",
                    style: TextStyle(color: Colors.grey[400], height: 1.6, fontSize: 15),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // BUY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5CFF), // Brand Blue
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
                             backgroundColor: Colors.green,
                             content: Text("✅ Order Placed! 150 HOC deducted.")
                           )
                         );
                         Navigator.pop(context);
                      },
                      child: const Text("CONFIRM PURCHASE", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}