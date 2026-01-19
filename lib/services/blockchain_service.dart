import 'dart:convert';
import 'package:home_ops_agent/config/secrets.dart';
import 'package:http/http.dart' as http;

class BlockchainService {

  static final String _apiKey = blockchainApiKey;
  
 
  static const String _baseUrl = "https://api-sandbox.circle.com/v1/businessAccount/balances";

  
  Future<bool> verifyPayment(double requiredAmount) async {
    print("--------------------------------------------------");
    print("🔍 DEBUG: Checking Wallet for \$${requiredAmount} USDC...");
    print("--------------------------------------------------");

    final url = Uri.parse(_baseUrl);

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      print("🔍 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final balances = data['data']['available'] as List;

        // 1. Find the USDC Balance
        var usdcBalance = 0.0;
        for (var b in balances) {
          if (b['currency'] == 'USD') {
            usdcBalance = double.parse(b['amount']);
          }
        }

        print("💰 Current Balance: \$$usdcBalance USD");

        // 2. The Logic: If we have enough money, the "Payment" counts as valid!
        if (usdcBalance >= requiredAmount) {
          print("✅ SUCCESS! Funds verified.");
          return true;
        } else {
          print("❌ FAILED. Insufficient funds (Need $requiredAmount, Have $usdcBalance)");
          return false;
        }
      } else {
        print("❌ API Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error: $e");
      return false;
    }
  }
}