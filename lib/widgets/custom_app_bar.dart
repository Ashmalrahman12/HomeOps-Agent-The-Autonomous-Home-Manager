import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.bar_chart, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text("HomeOps Agent", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ]),
            Icon(Icons.search, color: Colors.white),
          ],
        ),
        const SizedBox(height: 20),
        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: "Search HomeOps",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            suffixIcon: Icon(Icons.mic, color: Colors.grey),
            filled: true,
            fillColor: Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}