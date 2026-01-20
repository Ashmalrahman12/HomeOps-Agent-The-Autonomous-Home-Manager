import 'package:flutter/material.dart';
import 'package:home_ops_agent/screens/navigation_bar_page.dart';
import 'package:home_ops_agent/services/shopping_list_service.dart';
import 'shop_screen.dart'; // To navigate to cart/shop

class SmartListScreen extends StatefulWidget {
  const SmartListScreen({super.key});

  @override
  State<SmartListScreen> createState() => _SmartListScreenState();
}

class _SmartListScreenState extends State<SmartListScreen> {
  final _service = ShoppingListService();
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _service.items.add({"name": _controller.text, "checked": false});
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Smart Shopping List", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _service.items.clear();
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. INPUT BOX (Manual Add)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Add item (e.g., Tomatoes)...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.black,
                  onPressed: _addItem,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              ],
            ),
          ),

          // 2. THE LIST
          Expanded(
            child: ListView.builder(
              itemCount: _service.items.length,
              itemBuilder: (context, index) {
                final item = _service.items[index];
                return CheckboxListTile(
                  title: Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 18,
                      decoration: item['checked'] ? TextDecoration.lineThrough : null,
                      color: item['checked'] ? Colors.grey : Colors.black,
                    ),
                  ),
                  value: item['checked'],
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      _service.toggleItem(index);
                    });
                  },
                  secondary: IconButton(
                    icon: const Icon(Icons.search, color: Colors.blueAccent),
                    onPressed: () {
                    navBarKey.currentState?.changeTab(2); 
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                    },
                  ),
                );
              },
            ),
          ),

          // 3. "BUY ALL" BUTTON
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5CFF),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI is searching best prices for all items...")));
                 // Navigate to Shop
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
              },
              child: const Text("Find Deals for Selected Items", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}