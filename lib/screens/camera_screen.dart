import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/ai_service.dart';
import '../services/chat_service.dart'; 
import '../services/shopping_list_service.dart'; // <--- IMPORT THIS
import 'chat_screen.dart'; 
import 'purchase_screen.dart'; 

class FixItCamera extends StatefulWidget {
  final CameraDescription camera;
  const FixItCamera({super.key, required this.camera});

  @override
  State<FixItCamera> createState() => _FixItCameraState();
}

class _FixItCameraState extends State<FixItCamera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  // --- STATE VARIABLES ---
  bool _isListening = false;
  bool _isVideoOn = false; 
  bool _isPaused = false;  
  bool _isMalayalam = false;
  
  String _aiResponse = "Hi! I'm listening.";
  String _currentWords = ""; 
  Map<String, dynamic>? _currentProduct; 

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    _initVoice();
  }

  void _initVoice() async {
    await _flutterTts.setLanguage("en-US");
  }

  @override
  void dispose() {
    _controller.dispose();
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  // --- 1. TOGGLE MIC ---
  void _toggleMic() async {
    if (_isListening) {
      _stopListeningAndSend();
    } else {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _currentWords = ""; 
        });
        
        _speech.listen(
          localeId: _isMalayalam ? "ml_IN" : "en_US",
          onResult: (val) {
            setState(() {
              _currentWords = val.recognizedWords;
            });
          }
        );
      }
    }
  }

  // --- 2. SEND TO AI (UPDATED FOR LISTS) ---
  void _stopListeningAndSend() async {
    setState(() => _isListening = false);
    await _speech.stop();

    if (_currentWords.isEmpty) return;

    // Save User Message
    ChatService.addMessage("user", _currentWords);

    try {
      final aiService = AiService();
      Map<String, dynamic> result;

      // Logic: Use Camera if ON and NOT PAUSED
      if (_isVideoOn && !_isPaused) {
        final image = await _controller.takePicture();
        result = await aiService.analyzeImage(image.path, _currentWords, _isMalayalam);
      } else {
        result = await aiService.chatWithGemini(_currentWords, _isMalayalam);
      }

      setState(() {
        _aiResponse = result['answer'];
        
        // CHECK 1: IS IT A SINGLE PRODUCT?
        if (result['hasProduct'] == true) {
          _currentProduct = result;
        } else {
          _currentProduct = null; // Clear if not a product
        }
      });

      // CHECK 2: IS IT A LIST? (Comma separated)
      if (_aiResponse.contains(',')) {
         // Auto-add to Smart List
         ShoppingListService().addFromAI(_aiResponse);
         
         // Show Visual Feedback
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               backgroundColor: Colors.green,
               content: Row(
                 children: [
                   const Icon(Icons.check_circle, color: Colors.white),
                   const SizedBox(width: 10),
                   Expanded(child: Text("Added to List: $_aiResponse")),
                 ],
               )
             )
           );
         }
      }
      
      ChatService.addMessage("ai", _aiResponse, result['hasProduct'] ? result : null);
      _flutterTts.speak(_aiResponse);

    } catch (e) {
      print("Error: $e");
    }
  }

  // --- 3. PAUSE VIDEO LOGIC ---
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    if (_isPaused) {
      _controller.pausePreview(); 
    } else {
      _controller.resumePreview(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // 1. BACKGROUND LAYER
                if (_isVideoOn)
                  SizedBox.expand(child: CameraPreview(_controller))
                else
                  Container(
                    color: const Color(0xFF1E1E1E), 
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.graphic_eq, size: 80, color: Colors.white24),
                          const SizedBox(height: 20),
                          const Text("Voice Mode", style: TextStyle(color: Colors.white54))
                        ],
                      ),
                    ),
                  ),

                // 2. GRADIENT OVERLAY
                if (_isVideoOn)
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),

                // 3. TOP BAR
                Positioned(
                  top: 50, left: 20, right: 20,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_downward, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      
                      IconButton(
                        icon: const Icon(Icons.message_rounded, color: Colors.white),
                        onPressed: () {
                           Navigator.push(
                             context, 
                             MaterialPageRoute(builder: (_) => const ChatScreen())
                           );
                        },
                      ),
                      
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() => _isMalayalam = !_isMalayalam);
                          _flutterTts.setLanguage(_isMalayalam ? "ml-IN" : "en-US");
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isMalayalam ? "MAL 🇮🇳" : "ENG 🇺🇸",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. FLOATING PRODUCT BUBBLE (Single Item)
                if (_currentProduct != null)
                  Positioned(
                    top: 150, left: 20, 
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PurchaseScreen(product: _currentProduct!)
                          )
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 8)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             ClipRRect(
                               borderRadius: BorderRadius.circular(10),
                               child: CachedNetworkImage(
                                imageUrl: _currentProduct!['productImage'],
                                 width: 80, height: 80, fit: BoxFit.cover,
                                 errorWidget: (c,e,s) => const Icon(Icons.shopping_bag, size: 40), 
                               ),
                             ),
                             const SizedBox(height: 5),
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                               decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                               child: const Row(
                                 children: [
                                   Icon(Icons.shopping_cart, color: Colors.white, size: 10),
                                   SizedBox(width: 4),
                                   Text("Tap to Buy", style: TextStyle(color: Colors.white, fontSize: 10)),
                                 ],
                               ),
                             )
                          ],
                        ),
                      ),
                    ),
                  ),

                // 5. CHAT BUBBLES
                Positioned(
                  bottom: 180, left: 20, right: 20,
                  child: Column(
                    children: [
                      if (_currentWords.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _currentWords,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          _aiResponse,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                // 6. BOTTOM CONTROL BAR
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 40, top: 20),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // A. VIDEO TOGGLE
                        GestureDetector(
                          onTap: () {
                              setState(() {
                                _isVideoOn = !_isVideoOn;
                                if(!_isVideoOn) _isPaused = false; 
                              });
                           },
                           child: CircleAvatar(
                             radius: 25,
                             backgroundColor: _isVideoOn ? Colors.white : Colors.white24,
                             child: Icon(
                               _isVideoOn ? Icons.videocam : Icons.videocam_off,
                               color: _isVideoOn ? Colors.black : Colors.white,
                             ),
                           ),
                         ),

                        // B. PAUSE BUTTON
                        if (_isVideoOn) 
                          GestureDetector(
                            onTap: _togglePause,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: _isPaused ? Colors.amber : Colors.white24,
                              child: Icon(
                                _isPaused ? Icons.play_arrow : Icons.pause,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        
                        // C. MIC BUTTON (Main)
                        GestureDetector(
                          onTap: _toggleMic,
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: _isListening ? Colors.white : Colors.redAccent,
                            child: Icon(
                              _isListening ? Icons.stop : Icons.mic, 
                              color: _isListening ? Colors.black : Colors.white, 
                              size: 30
                            ),
                          ),
                        ),
                        
                        // D. END CALL
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.call_end, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}