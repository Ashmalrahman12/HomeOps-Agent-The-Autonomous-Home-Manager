import 'dart:convert';
import 'package:http/http.dart' as http;

class CircleService {
  //  YOUR NEW PAYMENTS KEY (From the Payments Dashboard)
  static final String _apiKey = "SAND_API_KEY:027098540124e24932bdf6ac84047ad0:ab647a98f62c61a13bdd836690520a02";
  
  //  CORRECT URL FOR PAYMENTS
  static const String _baseUrl = "https://api-sandbox.circle.com/v1/payments";

  //  FUNCTION: Charge a Credit Card (No Wallet needed!)
  Future<String?> makePayment(String amount) async {
    final url = Uri.parse(_baseUrl);
    
    // Unique ID for this transaction
    String idempotencyKey = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "idempotencyKey": idempotencyKey,
          "amount": {
            "amount": amount,
            "currency": "USD" // Sandbox only supports USD
          },
          "source": {
            "id": "key_1", // This is the "Magic" Test Card ID
            "type": "card"
          },
          "description": "Payment for Home Ops Service",
          "metadata": {
            "email": "customer@example.com"
          }
        }),
      );

      print("🔍 Response Status: ${response.statusCode}");
      print("🔍 Response Body: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ Payment Success! ID: ${data['data']['id']}");
        return "Success";
      } else {
        print("❌ Payment Failed.");
        return null;
      }
    } catch (e) {
      print("❌ Error: $e");
      return null;
    }
  }
}