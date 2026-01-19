// import 'dart:convert';
// import 'package:home_ops_agent/config/secrets.dart';
// import 'package:http/http.dart' as http;

// void main() async {
//   //  PASTE YOUR API KEY HERE
//   String apiKey = blockchainApiKey; 
  
//   //  NEW ENDPOINT: Mock Wire (Simulates a bank deposit)
//   var url = Uri.parse("https://api-sandbox.circle.com/v1/mocks/payments/wire");

//   print("⏳ Sending Fake Bank Transfer...");

//   try {
//     var response = await http.post(
//       url,
//       headers: {
//         "Authorization": "Bearer $apiKey",
//         "Content-Type": "application/json",
//         "Accept": "application/json",
//       },
//       body: jsonEncode({
//         "trackingRef": "REF_${DateTime.now().millisecondsSinceEpoch}", // Unique Ref ID
//         "amount": {
//           "amount": "100.00", //  Adding $100
//           "currency": "USD"
//         },
//         "beneficiaryBank": {
//           "accountNumber": "1234567890" // Mock Bank Account Number
//         }
//       }),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("================================================");
//       print(" SUCCESS! Money sent to your Dashboard.");
//       print(" Go check your Circle Dashboard now!");
//       print("================================================");
//     } else {
//       print("❌ FAILED. Status: ${response.statusCode}");
//       print("Response: ${response.body}");
//     }
//   } catch (e) {
//     print("❌ Error: $e");
//   }
// }