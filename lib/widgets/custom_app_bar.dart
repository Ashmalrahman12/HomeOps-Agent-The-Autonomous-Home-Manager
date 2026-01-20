import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_ops_agent/screens/chat_screen.dart';
import 'package:home_ops_agent/services/ai_service.dart';
import 'package:home_ops_agent/services/chat_service.dart';
import 'package:home_ops_agent/services/recommendation_service.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _onSearch(String query) async {
    if (query.trim().isEmpty) return;

    // 1. Dismiss Keyboard & Show Loading
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      // 2. Call AI Service
      final result = await AiService().chatWithGemini(query, false);

      // 3. Save USER message to Global History
      ChatService.addMessage("user", query);

      // 4. Save AI message to Global History
      ChatService.addMessage(
        "ai", 
        result['answer'], 
        result['hasProduct'] ? result : null
      );
      
      // (Optional) Update Home Recommendations if a product was found
      if (result['hasProduct']) {
         RecommendationService().setRecommendation(result);
      }

      if (!mounted) return;

      // 5. Navigate to ChatScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ChatScreen(),
        ),
      );
      
      // Clear the search bar
      _searchController.clear();

    } catch (e) {
      print("Search error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.bar_chart, color: Colors.blueAccent),
              const SizedBox(width: 8),
              const Text("HomeOps Agent", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ]),
            const Icon(Icons.notifications_none, color: Colors.white),
          ],
        ),
        const SizedBox(height: 20),

        // Search Bar with Google Loader
        TextField(
          controller: _searchController, 
          onSubmitted: _onSearch,
          style: const TextStyle(color: Colors.white), 
          decoration: InputDecoration(
            hintText: _loading ? "Analyzing..." : "Search HomeOps...",
            hintStyle: const TextStyle(color: Colors.grey),
            
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
              
          
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12.0), // Padding to make loader look nice
              child: _loading
                  ? const GoogleColorLoader() // Show Animation when loading
                  : InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _onSearch(_searchController.text),
                      child: const Icon(Icons.send, color: Colors.blueAccent),
                    ),
            ),
          
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
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

// --- GOOGLE STYLE LOADER WIDGET ---
class GoogleColorLoader extends StatefulWidget {
  const GoogleColorLoader({super.key});

  @override
  State<GoogleColorLoader> createState() => _GoogleColorLoaderState();
}

class _GoogleColorLoaderState extends State<GoogleColorLoader> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  final List<Color> _colors = const [
    Color(0xFF4285F4), // Blue
    Color(0xFFDB4437), // Red
    Color(0xFFF4B400), // Yellow
    Color(0xFF0F9D58)  // Green
  ];
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Rotates the circle
    _controller = AnimationController(
      duration: const Duration(seconds: 2), vsync: this
    )..repeat();

    // Changes the color every 1 second
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) setState(() => _index = (_index + 1) % _colors.length);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20, 
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(_colors[_index]),
      ),
    );
  }
}