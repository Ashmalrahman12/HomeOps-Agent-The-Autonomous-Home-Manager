import 'package:flutter/material.dart';
import 'package:home_ops_agent/services/blockchain_service.dart';


class PurchaseScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const PurchaseScreen({super.key, required this.product});

 
  double _parsePrice(String priceString) {
    try {
      String clean = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(clean);
    } catch (e) {
      return 10.0; // Default fallback amount
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    _parsePrice(product['productPrice']);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2. HERO IMAGE
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

            // 3. PRODUCT DETAILS
            Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -30, 0),
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -5))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  
                  // PRICE
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
                        child: const Text("USDC ACCEPTED", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
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
                    "This is a premium item recommended by your AI Assistant.\n\n"
                    "• Verified Quality\n"
                    "• Instant Delivery\n"
                    "• Blockchain Warranty Included",
                    style: TextStyle(color: Colors.grey[400], height: 1.6, fontSize: 15),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  //  4. BLOCKCHAIN BUY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5CFF), // Circle Blue
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      onPressed: () async {
                        // A. Show Loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Processing Transaction on Circle Blockchain... 🔗"),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.blueAccent,
                          ),
                        );

                        // B. Call Blockchain API
                        bool success = await BlockchainService().verifyPayment(0.01);

                        // C. Handle Result
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();

                        if (success) {
                           if(context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text("✅ Payment Confirmed! Shipment Initiated.")
                              )
                            );
                            Navigator.pop(context); // Go back after success
                           }
                        } else {
                           if(context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("❌ Payment Failed. Check connection.")
                              )
                            );
                           }
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.currency_bitcoin, color: Colors.white),
                          SizedBox(width: 10),
                          Text("BUY WITH USDC", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
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