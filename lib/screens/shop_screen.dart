import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:home_ops_agent/screens/navigation_bar_page.dart';
import 'package:home_ops_agent/services/cart_service.dart'; 

import 'purchase_screen.dart';
import '../services/product_generator.dart'; 

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  
  @override
  void initState() {
    super.initState();
    _checkAndFillStore();
  }

  void _checkAndFillStore() async {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final snapshot = await FirebaseFirestore.instance.collection('shop_inventory').get();
      
      // If store is empty, auto-generate products
      if (snapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("🚀 Initializing Store... generating products!"))
          );
        }
        await ProductGenerator.generateNewBatch();
      }
    });
  }

  
  Future<void> _handleRefresh() async {
    int count = await ProductGenerator.generateNewBatch();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✨ Added $count new unique items!"), backgroundColor: Colors.green)
      );
    }
  }

  Widget _buildGoogleCard(Map<String, dynamic> item) {
    bool isAiPick = item['isAi'] == true;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => PurchaseScreen(product: {
            "productName": item['name'],
            "productPrice": item['price'],
            "productImage": item['image'],
          })
        ));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SECTION
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    item['image'],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Loading Animation
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 120, 
                        color: Colors.grey[200], 
                        child: const Center(child: Icon(Icons.image, color: Colors.grey))
                      );
                    },
                    // Error Fallback
                    errorBuilder: (c,e,s) => Container(
                      height: 120, 
                      color: Colors.grey[300], 
                      child: const Icon(Icons.broken_image, color: Colors.grey)
                    ),
                  ),
                ),
                if (isAiPick)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(5)),
                      child: const Text("AI Pick", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            
        
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item['price'],
                    style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(" ${item['rating']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // ADD TO CART BUTTON
            Container(
              width: double.infinity,
             
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0), 
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child:  IconButton(icon: Icon(Icons.add_shopping_cart), color: Colors.black,
               onPressed: () {
                 navBarKey.currentState?.changeTab(3);
                 CartService.addItem(item);
                 },),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String title, List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const Icon(Icons.arrow_forward, color: Colors.white54, size: 18),
            ],
          ),
        ),
        
        SizedBox(
          height: 270, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildGoogleCard(items[index]);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Shop", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: Colors.blue,
                backgroundColor: Colors.white,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('shop_inventory').orderBy('timestamp', descending: true).limit(100).snapshots(),
                  builder: (context, snapshot) {
                    
                    // LOADING
                    if (!snapshot.hasData) {
                       return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                    }

                    // Categorize Items
                    List<Map<String, dynamic>> electronics = [];
                    List<Map<String, dynamic>> fashion = [];
                    List<Map<String, dynamic>> food = [];
                    List<Map<String, dynamic>> tools = [];
                    List<Map<String, dynamic>> furniture = [];
                    List<Map<String, dynamic>> medicine = [];
                    List<Map<String, dynamic>> others = [];

                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      String cat = (data['category'] ?? "").toString().toLowerCase();
                      
                   
                      String imgUrl = data['image_url'] ?? "";
                      if (imgUrl.isEmpty) {
                        imgUrl = "https://via.placeholder.com/150?text=No+Image"; 
                      }

                      Map<String, dynamic> product = {
                        "name": data['name'] ?? "Item",
                        "price": data['price'] ?? "₹100",
                        "rating": (data['rating'] is int) ? (data['rating'] as int).toDouble() : (data['rating'] ?? 4.5),
                        "image": imgUrl,
                      };

                      // Sort into lists
                      if (cat.contains("phone") || cat.contains("laptop") || cat.contains("watch") || cat.contains("tech")) {
                        electronics.add(product);
                      } else if (cat.contains("shirt") || cat.contains("shoe") || cat.contains("jeans")) {
                        fashion.add(product);
                      } else if (cat.contains("food") || cat.contains("fruit") || cat.contains("milk") || cat.contains("burger")) {
                        food.add(product);
                      } else if (cat.contains("tool") || cat.contains("drill") || cat.contains("hammer")) {
                        tools.add(product);
                      } else if (cat.contains("chair") || cat.contains("sofa") || cat.contains("table")) {
                        furniture.add(product);
                      } else if (cat.contains("medicine") || cat.contains("pill") || cat.contains("vitamin")) {
                        medicine.add(product);
                      } else {
                        others.add(product);
                      }
                    }

                    // EMPTY STATE
                    if (snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.blueAccent),
                              SizedBox(height: 20),
                              Text("AI is stocking the shelves...", style: TextStyle(color: Colors.white54)),
                            ],
                          )
                        );
                    }

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 50),
                      children: [
                        _buildCategoryRow("📱 Electronics", electronics),
                        _buildCategoryRow("👕 Fashion & Clothes", fashion),
                        _buildCategoryRow("🍔 Food & Groceries", food),
                        _buildCategoryRow("🛋️ Furniture", furniture),
                        _buildCategoryRow("🛠️ Tools & Hardware", tools),
                        _buildCategoryRow("💊 Health & Medicine", medicine),
                        _buildCategoryRow("✨ More Deals", others),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}