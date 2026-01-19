import 'dart:convert';
import 'package:flutter/services.dart';

late String geminiApiKey;
late String blockchainApiKey;

Future<void> loadSecrets() async {
  try {
    final String jsonString =
        await rootBundle.loadString('assets/secrets.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    geminiApiKey = jsonData['geminiAPiKey'] ?? 'default_key';
    blockchainApiKey = jsonData['blockchainApiKey'] ?? 'default_key';
    print('Secrets loaded successfully.');
  } catch (e) {
    print('Error loading secrets: $e');
    geminiApiKey = 'default_key';
  }
}