import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:home_ops_agent/screens/purchase_screen.dart';
import 'package:home_ops_agent/services/blockchain_service.dart';
import '../services/cart_service.dart'; 


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  

  void _updateCart() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double totalAmt = CartService.getTotal();
    int selectedCount = CartService.items.where((i) => i.isSelected).length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: const Color(0xFF232f3e), 
        foregroundColor: Colors.white,
      ),
      body: CartService.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // --- 1. SUB-TOTAL SECTION (Top) ---
                Container(
                  padding: const EdgeInsets.all(15),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("Subtotal: ", style: TextStyle(fontSize: 18)),
                          Text(
                            "₹${totalAmt.toStringAsFixed(0)}",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700], // Amazon Yellow
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: selectedCount == 0 ? null : () {
                            _showBillingDialog(totalAmt);
                          },
                          child: Text("Proceed to Buy ($selectedCount items)"),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),

                Expanded(
                  child: ListView.builder(
                    itemCount: CartService.items.length,
                    itemBuilder: (context, index) {
                      final item = CartService.items[index];
                 
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        color: Colors.white,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // A. CHECKBOX
                            Checkbox(
                              activeColor: Colors.teal,
                              value: item.isSelected,
                              onChanged: (val) {
                                item.isSelected = val ?? false;
                                _updateCart();
                              },
                            ),

                     
                            GestureDetector(
                              onTap: () => _goToPurchase(item),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (c, e, s) => const Icon(Icons.error),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 10),

                       
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _goToPurchase(item), 
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.details,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.price,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    const Text(
                                      "In stock",
                                      style: TextStyle(color: Colors.green, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // D. DELETE BUTTON
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () {
                                CartService.removeItem(index);
                                _updateCart();
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }


  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Your Amazon Cart is empty", style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  
  void _goToPurchase(CartItem item) {
  
    Map<String, dynamic> productMap = {
      'productName': item.name,
      'productPrice': item.price,
      'productImage': item.imageUrl,
      'rating': "4.5", 
      'category': item.details,
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PurchaseScreen(product: productMap)),
    );
  }

  
  void _showBillingDialog(double total) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Billing Summary"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Total Items"),
              trailing: Text("${CartService.items.where((i)=>i.isSelected).length}"),
            ),
            ListTile(
              title: const Text("Grand Total"),
              trailing: Text(
                "₹${total.toStringAsFixed(0)}", // Displaying in Rupees for user
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Pay securely using Circle Blockchain (USDC)", 
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Cancel")
          ),
          
       
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5CFF), // Circle Blue color
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.currency_bitcoin, size: 18), // Crypto Icon
            label: const Text("PAY WITH USDC"),
            onPressed: () async {
              // 1. Close the dialog immediately
              Navigator.pop(ctx); 

              // 2. Show "Processing" message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Connecting to Blockchain... 🔗"),
                  duration: Duration(seconds: 10), // Stay open while loading
                  backgroundColor: Colors.blueAccent,
                ),
              );

              // 3. CALL THE BLOCKCHAIN SERVICE
              // Note: We convert Rupees to USD roughly for the demo (e.g. /85)
              // or just send the raw number as USDC cents.
              bool success = await BlockchainService().verifyPayment(0.01);

              // 4. Handle Result
              ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide loading

              if (success) {
                // SUCCESS: Green Snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green,
                    content: Row(children: const [
                       Icon(Icons.check_circle, color: Colors.white),
                       SizedBox(width: 10),
                       Expanded(child: Text("Payment Confirmed on Blockchain! 🚀")),
                    ]),
                  ),
                );
                
                // Clear the cart
                setState(() {
                   CartService.items.removeWhere((i) => i.isSelected);
                });

              } else {
                // FAILURE: Red Snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text("❌ Insufficient USDC Funds. Use Faucet!"),
                  ),
                );
              }
            }, 
          ),
        ],
      ),
    );
  }
}