
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:home_ops_agent/screens/navigation_bar_page.dart';
import 'package:home_ops_agent/services/cart_service.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:home_ops_agent/services/shopping_list_service.dart';
import 'package:home_ops_agent/services/recommendation_service.dart'; 
import '../services/chat_service.dart';
import '../services/ai_service.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker(); 
  bool _isLoading = false;

  // --- HANDLE IMAGE SELECTION ---
  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      _sendMessage(imagePath: photo.path, prompt: "What items are in this image? Make a list.");
    }
  }

  // --- SEND MESSAGE FUNCTION ---
  void _sendMessage({String? imagePath, String? prompt}) async {
    final text = prompt ?? _textController.text.trim();
    if (text.isEmpty && imagePath == null) return;

    setState(() {
      ChatService.addMessage("user", imagePath != null ? "📸 [Image Uploaded]" : text);
      _textController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    final aiService = AiService();
    Map<String, dynamic> result;

    try {
      // 1. Get AI Response (Text or Image Analysis)
      if (imagePath != null) {
        result = await aiService.analyzeImage(imagePath, text, false);
      } else {
        result = await aiService.chatWithGemini(text, false);
      }

      String aiResponseText = result['answer'];

  
      // If AI found a specific product, tell the RecommendationService!
      if (result['hasProduct'] == true) {
         RecommendationService().setRecommendation(result);
         print("✅ Home Page Updated from Chat: ${result['productName']}");
      }

      // 3. HANDLE SHOPPING LISTS (Split by comma)
      if (aiResponseText.contains(',')) {
        List<String> items = aiResponseText.split(',');
        int addedCount = 0;
        for (String item in items) {
          String cleanItem = item.trim();
          if (cleanItem.isNotEmpty) {
            ShoppingListService().addFromAI(cleanItem);
            addedCount++;
          }
        }
        if (mounted && addedCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text("✅ Added $addedCount items to Shopping List!"),
              duration: const Duration(seconds: 2),
            )
          );
        }
      }

      // 4. Add AI Response to Chat UI
      setState(() {
        ChatService.addMessage(
          "ai", 
          aiResponseText, 
          result['hasProduct'] ? result : null 
        );
        _isLoading = false;
      });
      _scrollToBottom();
      
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  @override
void initState() {
  super.initState();
  // Scroll to bottom after the widget builds
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final messages = ChatService.history;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("AI Shopping Assistant", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- CHAT LIST ---
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
           itemBuilder: (context, index) {
  final msg = messages[index];
  final isUser = msg['role'] == 'user';
  
  // CHECK FOR PRODUCT LIST
  List<Map<String, dynamic>> productList = [];
  if (msg['products'] != null) {
     // If your service returns a 'products' list, use it
     productList = List<Map<String, dynamic>>.from(msg['products']);
  } else if (msg['product'] != null) {
     // Fallback for old single product messages
     productList.add(msg['product']);
  }
  
  final hasProducts = productList.isNotEmpty;

  return Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // A. TEXT BUBBLE
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isUser ? [] : [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Text(
            msg['text'],
            style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 16),
          ),
        ),

      
        if (hasProducts) 
          Container(
            height: 260, 
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: productList.length,
              itemBuilder: (context, pIndex) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
              
                  child: GestureDetector(
                            onTap: () {
                              // A. Add to Cart Service
                              CartService.addItem(  productList[pIndex]);
                              
                              // B. Show Feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${productList[pIndex]['productName']} added to Cart!"),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: Colors.green,
                                )
                              );

                              // C. Navigate to Cart (Index 3)
                              Navigator.pop(context); // Close Camera
                              navBarKey.currentState?.changeTab(3); 
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
                                        imageUrl: productList[pIndex]['productImage'],
                                        width: double.infinity, 
                                        fit: BoxFit.cover,
                                        placeholder: (c,u) => Container(color: Colors.grey[200]),
                                        errorWidget: (c,e,s) => const Icon(Icons.shopping_bag, size: 40), 
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    productList[pIndex]['productName'], 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  Text(
                                    productList[pIndex]['productPrice'], 
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
      ],
    ),
  );
},
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: Colors.blueAccent, backgroundColor: Colors.transparent),
            ),

          // --- INPUT BAR ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                // CAMERA
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.grey),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                // GALLERY
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.grey),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                // TEXT FIELD
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: "Type list or snap photo...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // SEND
                GestureDetector(
                  onTap: () => _sendMessage(),
                  child: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}