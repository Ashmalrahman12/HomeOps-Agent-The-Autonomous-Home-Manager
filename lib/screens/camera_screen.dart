import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


import 'package:home_ops_agent/screens/navigation_bar_page.dart'; 
import 'package:home_ops_agent/services/cart_service.dart';
import 'package:home_ops_agent/services/recommendation_service.dart'; 
import '../services/ai_service.dart';
import '../services/chat_service.dart'; 
import '../services/shopping_list_service.dart'; 
import 'chat_screen.dart'; 


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
  
 
  bool _isListening = false;
  bool _isVideoOn = false; 
  bool _isPaused = false;  
  bool _isMalayalam = false;
  
  String _aiResponse = "Hi! I'm listening.";
  String _currentWords = ""; 
  
  List<Map<String, dynamic>> _products = []; 

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

 
  void _stopListeningAndSend() async {
    setState(() => _isListening = false);
    await _speech.stop();

    if (_currentWords.isEmpty && !_isVideoOn) return; 

    if (_currentWords.isNotEmpty) ChatService.addMessage("user", _currentWords);

    try {
      final aiService = AiService();
      Map<String, dynamic> result;

      if (_isVideoOn && !_isPaused) {
        final image = await _controller.takePicture();
        result = await aiService.analyzeImage(image.path, _currentWords, _isMalayalam);
      } else {
        result = await aiService.chatWithGemini(_currentWords, _isMalayalam);
      }

      setState(() {
        _aiResponse = result['answer'];
        
      
        if (result['products'] != null) {
          _products = List<Map<String, dynamic>>.from(result['products']);
          
       
          if (_products.isNotEmpty) {
             RecommendationService().setRecommendation(_products.first);
             print("✅ Home Page Updated with: ${_products.first['productName']}");
          }

        } else {
          _products = [];
        }
      });

      if (_products.isNotEmpty) {
         for(var p in _products) {
            ShoppingListService().addFromAI(p['productName']);
         }
         
     
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Added ${_products.length} items to Shopping List"), backgroundColor: Colors.green, duration: const Duration(seconds: 1))
         );
      }
      
   
      _flutterTts.speak(_aiResponse);

    } catch (e) {
      print("Error: $e");
    }
  }

  
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

             
                if (_products.isNotEmpty)
                  Positioned(
                    top: 110, 
                    left: 0, 
                    right: 0,
                    height: 190, 
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: GestureDetector(
                            onTap: () {
                              // A. Add to Cart Service
                              CartService.addItem(product);
                              
                              // B. Show Feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${product['productName']} added to Cart!"),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: Colors.green,
                                )
                              );

                              // C. Navigate to Cart (Index 3)
                              Navigator.pop(context); // Close Camera
                              navBarKey.currentState?.changeTab(3); // Go to Cart Tab
                            },
                            child: Container(
                              width: 130, 
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 8)],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: product['productImage'],
                                        width: double.infinity, 
                                        fit: BoxFit.cover,
                                        placeholder: (c,u) => Container(color: Colors.grey[200]),
                                        errorWidget: (c,e,s) => const Icon(Icons.shopping_bag, size: 40), 
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product['productName'], 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  Text(
                                    product['productPrice'], 
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(5)),
                                    child: const Center(
                                      child: Text("BUY NOW", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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