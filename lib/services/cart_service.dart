

class CartItem {
  final String name;
  final String price;
  final String imageUrl;
  final String details;
  bool isSelected;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.details = "In Stock",
    this.isSelected = true,
    this.quantity = 1,
  });
}

class CartService {
 
  static final List<CartItem> _items = [];
  
  
  static List<CartItem> get items => _items;

  static void addItem(Map<String, dynamic> product) {
    _items.add(CartItem(
      name: product['productName'] ?? "Unknown",
      price: product['productPrice'] ?? "₹0",
      imageUrl: product['productImage'] ?? "",
      details: product['category'] ?? "General Item",
    ));
  }

  
  static void removeItem(int index) {
    _items.removeAt(index);
  }

  
  static double getTotal() {
    double total = 0;
    for (var item in _items) {
      if (item.isSelected) {
   
        String cleanPrice = item.price.replaceAll('₹', '').replaceAll(',', '').trim();
        total += (double.tryParse(cleanPrice) ?? 0) * item.quantity;
      }
    }
    return total;
  }
}