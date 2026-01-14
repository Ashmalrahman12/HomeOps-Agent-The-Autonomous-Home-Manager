import 'dart:convert';
import 'package:flutter/services.dart';

late String geminiApiKey;

Future<void> loadSecrets() async {
  final String jsonString =
      await rootBundle.loadString('assets/secrets.json');
  final Map<String, dynamic> jsonData = json.decode(jsonString);

  geminiApiKey = jsonData['geminiAPiKey'];
 print('Secrets loaded successfully.'); 

}