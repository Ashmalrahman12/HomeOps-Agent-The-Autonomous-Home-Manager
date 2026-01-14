import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Import for CameraDescription
import '../screens/camera_screen.dart'; // Import Camera Screen
import '../screens/chat_screen.dart';   // Import Chat Screen

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // 1. BACKGROUND IMAGE 🖼️
        image: DecorationImage(
          image: AssetImage("assets/robot.png"), 
          fit: BoxFit.cover, 
          alignment: Alignment.centerRight, 
        ),
      ),
      child: Row(
        children: [
          // 2. TEXT & BUTTONS SECTION (Takes 65% of width)
          Expanded(
            flex: 65, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your AI Marketplace\nfor Home Essentials", 
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Fix, Manage, Shop\nsmarter with AI", 
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 20),
                
                // 3. THE TWO BUTTONS ROW 🔘🔘
                Row(
                  children: [
                    // A. LIVE VIDEO BUTTON
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Get available cameras
                        final cameras = await availableCameras();
                        if (cameras.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FixItCamera(camera: cameras.first)
                            )
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5CFF), // Brand Blue
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: Size.zero, // Compact fit
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.videocam, size: 18),
                      label: const Text("Live Fix", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),

                    const SizedBox(width: 10),

                    // B. CHAT BOT BUTTON
                    ElevatedButton.icon(
                      onPressed: () {
                         Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChatScreen())
                         );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, 
                        foregroundColor: Colors.black, // Black Text
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.chat_bubble, size: 18),
                      label: const Text("AI Chat", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          // 3. EMPTY SPACE (Keeps robot face clear)
          const Spacer(flex: 35),
        ],
      ),
    );
  }
}