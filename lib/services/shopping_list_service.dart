class ShoppingListService {
  static final ShoppingListService _instance = ShoppingListService._internal();
  factory ShoppingListService() => _instance;
  ShoppingListService._internal();

  // The List of Items
  // Format: {"name": "Milk", "checked": false}
  List<Map<String, dynamic>> items = [
    {"name": "Check Inverter Battery", "checked": false}, // Default item
  ];

  // AI CALLS THIS FUNCTION to add multiple items
  void addFromAI(String text) {
    // Example Input: "Milk, Bread, 9V Battery"
    List<String> newItems = text.split(','); 
    for (var item in newItems) {
      items.add({"name": item.trim(), "checked": false});
    }
  }

  void toggleItem(int index) {
    items[index]['checked'] = !items[index]['checked'];
  }
}