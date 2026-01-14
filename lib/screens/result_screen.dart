import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, String> productData;

  const ResultScreen({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("Diagnosis Complete"), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(productData['image']!, height: 250, fit: BoxFit.cover),
            ),
            const SizedBox(height: 30),
            
            // Product Name
            Text(productData['name']!, 
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            
            // Price
            Text(productData['price']!, 
              style: const TextStyle(fontSize: 22, color: Colors.greenAccent, fontWeight: FontWeight.bold)
            ),
            const Spacer(),
            
            // Buy Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5CFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                   // Add payment logic later
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ordering...")));
                },
                child: const Text("Order Now (USDC)", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}