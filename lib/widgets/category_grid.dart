import 'package:flutter/material.dart';
import 'package:home_ops_agent/main.dart';
import 'package:home_ops_agent/screens/camera_screen.dart';
import 'package:home_ops_agent/screens/health_hub_screen.dart';
import 'package:home_ops_agent/screens/smart_list_screen.dart';
import 'package:home_ops_agent/services/blockchain_service.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX 1: Wrap Row in SingleChildScrollView to prevent horizontal overflow
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildQuickAction(
              context,
              Icons.build,
              "Repair",
              Colors.blue,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => FixItCamera(camera: cameras.first)))),
          _buildQuickAction(
              context, 
              Icons.receipt_long, 
              "Billing", 
              Colors.purple, 
              () => _showBillingDialog(context)),
          _buildQuickAction(
              context, 
              Icons.monitor_heart, 
              "Health", 
              Colors.teal, 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthHubScreen()))),
          _buildQuickAction(
              context, 
              Icons.smart_toy, 
              "Smart", 
              Colors.grey, 
              () => _showSmartDevices(context)),
          _buildQuickAction(
              context,
              Icons.list_alt,
              "My List",
              Colors.purple,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartListScreen()))),
        ],
      ),
    );
  }
}

// 1. Helper to build the button
Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0), // Give buttons breathing room
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    ),
  );
}

bool _isBillPaid = false;

// 2. BILLING POPUP (FIXED: Vertical Scroll)
void _showBillingDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(20),
              // Use constraints instead of fixed height to prevent overflow
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Billing & Payments", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
              Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: _isBillPaid ? Colors.green.withValues(alpha: 0.2) : Colors.redAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: _isBillPaid ? Colors.green : Colors.redAccent),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Electricity Bill (KSEB)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text(_isBillPaid ? "PAID" : "DUE: Jan 25",
                                      style: TextStyle(color: _isBillPaid ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold)),
                                ],
                              ),
                         _isBillPaid
                                  ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
                                  : ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2E5CFF), // Circle Blue
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.currency_bitcoin, size: 16),
                                      label: const Text("Pay with USDC"),
                                      onPressed: () async {
                                        // A. Show Loading
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Verifying Wallet Balance... 🔗"),
                                            backgroundColor: Colors.blueAccent,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );

                                        // B. Call Blockchain Service (Check for 0.01 USDC)
                                        bool success = await BlockchainService().verifyPayment(0.01);

                                        if (success) {
                                          // C. Success Logic
                                          setModalState(() => _isBillPaid = true);
                                          
                                          if(context.mounted) {
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("✅ Bill Paid on Blockchain!"),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } else {
                                          // D. Failure Logic
                                          if(context.mounted) {
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("❌ Insufficient Funds. Use Faucet!"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },)
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text("Order History", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildOrderItem("Thermal Fuse (Pack of 3)", "₹400", "Processing..."),
                        _buildOrderItem("Screwdriver Set", "₹450", "Delivered"),
                        _buildOrderItem("Insulation Tape", "₹20", "Delivered"),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildOrderItem(String name, String price, String status) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(status, style: TextStyle(color: status == "Delivered" ? Colors.green : Colors.orange, fontSize: 12)),
        ]),
        Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}




// 4. SMART POPUP (FIXED: Vertical Scroll)
void _showSmartDevices(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView( // Prevents overflow on small screens
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Smart Home Monitor", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildSmartItem("AC Air Filter", "Cleaning Required", Icons.ac_unit, Colors.orange),
              _buildSmartItem("Water Tank", "Level: 15% (Low)", Icons.water, Colors.redAccent),
              _buildSmartItem("Wi-Fi Router", "Signal: Excellent", Icons.wifi, Colors.green),
              _buildSmartItem("Solar Panels", "Output: 4.2kWh", Icons.solar_power, Colors.amber),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildSmartItem(String title, String status, IconData icon, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15.0),
    child: Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const Spacer(),
        if (color == Colors.redAccent || color == Colors.orange)
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF333333), minimumSize: const Size(60, 30)),
              onPressed: () {},
              child: const Text("Fix", style: TextStyle(color: Colors.white, fontSize: 10)))
      ],
    ),
  );
}