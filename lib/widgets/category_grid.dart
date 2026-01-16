import 'package:flutter/material.dart';
import 'package:home_ops_agent/main.dart';
import 'package:home_ops_agent/screens/camera_screen.dart';
import 'package:home_ops_agent/screens/smart_list_screen.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
   
    return // 2. QUICK ACTIONS ROW
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    _buildQuickAction(
      context, 
      Icons.build, "Repair", Colors.blue, 
      () => Navigator.push(context, MaterialPageRoute(builder: (_) => FixItCamera(camera: cameras.first))) // GO TO CAMERA
    ),
    _buildQuickAction(
      context, 
      Icons.receipt_long, "Billing", Colors.purple, 
      () => _showBillingDialog(context) // GO TO ORDER HISTORY
    ),
    _buildQuickAction(
      context, 
      Icons.monitor_heart, "Health", Colors.teal, 
      () => _showHealthChecklist(context) // GO TO CHECKLIST
    ),
    _buildQuickAction(
      context, 
      Icons.smart_toy, "Smart", Colors.grey, 
      () => _showSmartDevices(context) // GO TO DEVICES
    ),
    // Inside HomePage -> _buildQuickAction
_buildQuickAction(
  context, 
  Icons.list_alt, // Change Icon
  "My List",      // Change Label
  Colors.purple, 
  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartListScreen())) // Open List
),
  ],
);
  }

}
// 1. Helper to build the button
Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
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
  );
}
 bool _isBillPaid = false;
// 2. BILLING POPUP (Shows Past Orders)
void _showBillingDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows taller popup
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return StatefulBuilder( // Use StatefulBuilder to update UI inside Popup
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Billing & Payments", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // --- 1. ELECTRICITY BILL SECTION ---
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    // If Paid -> Green, If Due -> Red
                    color: _isBillPaid ? Colors.green.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
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
                      
                      // THE PAY BUTTON
                      _isBillPaid 
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            onPressed: () {
                              // FAKE PAYMENT LOGIC
                              setModalState(() {
                                _isBillPaid = true; // Change to Green
                              });
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bill Paid Successfully! ₹850")));
                            },
                            child: const Text("Pay ₹850", style: TextStyle(color: Colors.white)),
                          ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                const Text("Order History", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // --- 2. FAKE DELIVERY LIST ---
                // We just hardcode the status. "Delivered" means it's done. "Processing" means new.
                
                _buildOrderItem("Thermal Fuse (Pack of 3)", "₹400", "Processing..."), // The one they just bought
                _buildOrderItem("Screwdriver Set", "₹450", "Delivered"), // Old fake order
                _buildOrderItem("Insulation Tape", "₹20", "Delivered"), // Old fake order
              ],
            ),
          );
        }
      );
    }
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
// ---------------------------------------------------------
// 1. UPDATED HEALTH POPUP (Family & Medicine)
// ---------------------------------------------------------
void _showHealthChecklist(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 450,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Family Health Hub", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Manage prescriptions & checkups", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
        
              // ACTION: SCAN PRESCRIPTION
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.document_scanner, color: Colors.blueAccent, size: 30),
                    const SizedBox(width: 15),
                    SingleChildScrollView(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Upload Prescription", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text("AI will auto-order medicines", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.arrow_forward, color: Colors.white), onPressed: (){})
                  ],
                ),
              ),
              const SizedBox(height: 20),
        
              // FAMILY STATUS
              const Text("Family Vitals", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              _buildHealthItem("Father", "BP: 120/80 (Normal)", Icons.favorite, Colors.redAccent),
              _buildHealthItem("Grandma", "Sugar: 140 mg/dL (High)", Icons.water_drop, Colors.orange),
              _buildHealthItem("Baby", "Vaccination Due: Jan 20", Icons.child_care, Colors.blue),
            ],
          ),
        ),
      );
    }
  );
}

// Helper for Family Health
Widget _buildHealthItem(String name, String status, IconData icon, Color color) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color, size: 20)),
    title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    subtitle: Text(status, style: const TextStyle(color: Colors.grey)),
    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
  );
}

// ---------------------------------------------------------
// 2. UPDATED SMART POPUP (House Maintenance)
// ---------------------------------------------------------
void _showSmartDevices(BuildContext context) {
   showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Smart Home Monitor", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // This is where we moved the AC/Water stuff!
            _buildSmartItem("AC Air Filter", "Cleaning Required", Icons.ac_unit, Colors.orange),
            _buildSmartItem("Water Tank", "Level: 15% (Low)", Icons.water, Colors.redAccent),
            _buildSmartItem("Wi-Fi Router", "Signal: Excellent", Icons.wifi, Colors.green),
            _buildSmartItem("Solar Panels", "Output: 4.2kWh", Icons.solar_power, Colors.amber),
          ],
        ),
      );
    }
   );
}

// Helper for Smart Home
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
            child: const Text("Fix", style: TextStyle(color: Colors.white, fontSize: 10))
          )
      ],
    ),
  );
}