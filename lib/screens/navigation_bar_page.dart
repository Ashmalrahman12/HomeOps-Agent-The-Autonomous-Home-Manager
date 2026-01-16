import 'package:flutter/material.dart';
import 'package:home_ops_agent/main.dart';
import 'package:home_ops_agent/screens/camera_screen.dart';
import 'package:home_ops_agent/screens/cart_screen.dart';
import 'package:home_ops_agent/screens/home_page.dart';
import 'package:home_ops_agent/screens/profile_page.dart';
import 'package:home_ops_agent/screens/shop_screen.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  State<NavigationBarPage> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBarPage> {
  int _selectedIndex = 0;

  // 1. UPDATE PAGES: Add an empty "SizedBox" at Index 2
  final List<Widget> _pages = [
    const HomePage(),           // Index 0
    const ShopScreen(),         // Index 1
    const SizedBox(),           // Index 2 (THE GHOST 👻)
    const CartScreen(),         // Index 3
    const ProfilePage(), // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This ensures the FAB sits on top of the bar correctly
      resizeToAvoidBottomInset: false, 
      
      body: _pages[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:  Colors.black,
        selectedItemColor: const Color(0xFF2E5CFF),
        unselectedItemColor: Colors.grey,
        
        // 2. CRITICAL: Use 'fixed' type to keep icons from moving
        type: BottomNavigationBarType.fixed, 
        currentIndex: _selectedIndex,
        
        onTap: (index) {
          // 3. PREVENT CLICKING THE GHOST
          if (index == 2) return; 
          setState(() => _selectedIndex = index);
        },
        
        items: const [
          // Index 0
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          
          // Index 1
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Shop"), 
          
          // Index 2 (THE GHOST ITEM) - Creates space for the button
          BottomNavigationBarItem(
            icon: Icon(Icons.circle, color: Colors.transparent), // Invisible
            label: "", 
          ),

          // Index 3
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"), 
          
          // Index 4
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E5CFF),
        shape: const CircleBorder(), // Makes it perfectly round
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FixItCamera(camera: cameras.first)),
          );
        },
        child: const Icon(Icons.video_call_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}