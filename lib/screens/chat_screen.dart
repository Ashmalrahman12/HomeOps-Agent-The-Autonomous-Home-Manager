import 'package:flutter/material.dart';
import 'package:home_ops_agent/services/shopping_list_service.dart'; // <--- IMPORT THIS
import '../services/chat_service.dart';
import '../services/ai_service.dart';
import '../widgets/chat_product_card.dart'; 

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Function to Send Text Message
  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // 1. Add User Message
    setState(() {
      ChatService.addMessage("user", text);
      _textController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    // 2. Call AI (Text Only Mode)
    final aiService = AiService();
    final result = await aiService.chatWithGemini(text, false); 
    
    String aiResponseText = result['answer'];

    // ---------------------------------------------------------
    // 3. SMART LIST LOGIC (Moved Inside the Function!) ✅
    // ---------------------------------------------------------
    if (aiResponseText.contains(',')) {
       // It's a list! Add to our new service
       ShoppingListService().addFromAI(aiResponseText);
       
       // Show a snackbar (Green for Success)
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             backgroundColor: Colors.green,
             content: Row(
               children: [
                 const Icon(Icons.check_circle, color: Colors.white),
                 const SizedBox(width: 10),
                 Expanded(child: Text("Added to List: $aiResponseText")),
               ],
             )
           )
         );
       }
    }

    // 4. Add AI Response to Chat UI
    setState(() {
      ChatService.addMessage(
        "ai", 
        aiResponseText, 
        result['hasProduct'] ? result : null // Store product if found
      );
      _isLoading = false;
    });
    _scrollToBottom();
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
  Widget build(BuildContext context) {
    // Get messages from history
    final messages = ChatService.history;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Light clean background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("AI Assistant", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                final hasProduct = msg['product'] != null;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // TEXT BUBBLE
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blueAccent : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                          ),
                          boxShadow: isUser ? [] : [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                          ],
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      // PRODUCT CARD (If available)
                      if (hasProduct) 
                        ChatProductCard(product: msg['product']),
                    ],
                  ),
                );
              },
            ),
          ),

          // --- TYPING LOADING INDICATOR ---
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: Colors.blueAccent, backgroundColor: Colors.transparent),
            ),

          // --- INPUT BAR ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
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
                        hintText: "Type list (e.g., Milk, Eggs)...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.arrow_upward, color: Colors.white),
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