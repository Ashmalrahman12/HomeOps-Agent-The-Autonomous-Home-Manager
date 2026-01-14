import 'package:flutter/material.dart';
import 'package:home_ops_agent/widgets/category_grid.dart';
import 'package:home_ops_agent/widgets/custom_app_bar.dart';
import 'package:home_ops_agent/widgets/home_recommendation_card.dart';

import 'package:home_ops_agent/widgets/promo_banner.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
 Widget build(BuildContext context) {
    return 
    SafeArea(
      child: Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomAppBar(),
            const SizedBox(height: 20),
            
            const PromoBanner(),
            const SizedBox(height: 20),
            
            const CategoryGrid(),
            const SizedBox(height: 25),
            
        
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recommended for You", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("See All >", style: TextStyle(color: Colors.white.withOpacity(0.7))),
              ],
            ),
            const SizedBox(height: 15),

         const HomeRecommendationCard(),
       
          ],
        ),
      ),)
    );
  }
}