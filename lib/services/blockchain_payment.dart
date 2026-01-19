// import 'dart:convert';
// import 'package:home_ops_agent/config/secrets.dart';
// import 'package:http/http.dart' as http;

// class BlockchainService {
//   //  YOUR PAYMENTS KEY
//   static final String _apiKey = "SAND_API_KEY:027098540124e24932bdf6ac84047ad0:ab647a98f62c61a13bdd836690520a02";
  
//   //  BASE URL (Already includes /payments)
//   static const String _baseUrl = "https://api-sandbox.circle.com/v1/payments";

//   Future<bool> makeCryptoPayment(double amount) async {
//     print("--------------------------------------------------");
//     print(" DEBUG: Sending Payment...");
//     print("--------------------------------------------------");

//     //  FIX 1: Use _baseUrl directly. Do NOT add "/payments" again.
//     final url = Uri.parse(_baseUrl);
    
//     String idempotencyKey = DateTime.now().millisecondsSinceEpoch.toString();

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Authorization": "Bearer $_apiKey",
//           "Content-Type": "application/json",
//           "Accept": "application/json", // Good practice to add this
//         },
//         body: jsonEncode({
//           "idempotencyKey": idempotencyKey,
//           "amount": {
//             "amount": amount.toString(),
//             "currency": "USD" 
//           },
//           "source": {
//             "id": "key_1", // 🔴 FIX 2: Use "key_1" (The Magic Test Card)
//             "type": "card"
//           },
//           "description": "Payment for HomeOps Items",
//           "metadata": {
//             "email": "test@example.com",
//             "sessionId": "hackathon_demo"
//           }
//         }),
//       );

//       print("🔍 Status Code: ${response.statusCode}");
//       print("🔍 Response Body: ${response.body}");

//       if (response.statusCode == 201) {
//         print("✅ Blockchain Payment Successful!");
//         return true;
//       } else {
//         print("❌ Payment Failed: ${response.body}");
//         return false;
//       }
//     } catch (e) {
//       print("❌ Error: $e");
//       return false;
//     }
//   }
// }