import 'package:flutter/material.dart';
import 'package:home_ops_agent/main.dart';
import 'package:home_ops_agent/screens/camera_screen.dart';
import 'package:home_ops_agent/screens/cart_screen.dart';
import 'package:home_ops_agent/screens/home_page.dart';
import 'package:home_ops_agent/screens/profile_page.dart';
import 'package:home_ops_agent/screens/shop_screen.dart';

final GlobalKey<_NavigationBarState> navBarKey = GlobalKey<_NavigationBarState>();

class NavigationBarPage extends StatefulWidget {
  NavigationBarPage({Key? key}) : super(key: navBarKey);

  @override
  State<NavigationBarPage> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBarPage> {
  int _selectedIndex = 0;

 
  final List<Widget> _pages = [
    const HomePage(),          
    const ShopScreen(),        
    const SizedBox(),          
    const CartScreen(),      
    const ProfilePage(), 
  ];

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      resizeToAvoidBottomInset: false, 
      
      body: _pages[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:  Colors.black,
        selectedItemColor: const Color(0xFF2E5CFF),
        unselectedItemColor: Colors.grey,
        
      
        type: BottomNavigationBarType.fixed, 
        currentIndex: _selectedIndex,
        
        onTap: (index) {
   
          if (index == 2) return; 
          setState(() => _selectedIndex = index);
        },
        
        items: const [
      
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Shop"), 
          
        
          BottomNavigationBarItem(
            icon: Icon(Icons.circle, color: Colors.transparent), 
            label: "", 
          ),

         
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"), 
          
       
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E5CFF),
        shape: const CircleBorder(), 
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