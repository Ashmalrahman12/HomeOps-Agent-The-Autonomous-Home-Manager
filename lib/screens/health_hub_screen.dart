import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:home_ops_agent/services/ai_service.dart'; 

class HealthHubScreen extends StatefulWidget {
  const HealthHubScreen({super.key});

  @override
  State<HealthHubScreen> createState() => _HealthHubScreenState();
}

class _HealthHubScreenState extends State<HealthHubScreen> {
  // --- STATE VARIABLES ---
  File? _prescriptionImage;
  String _scanStatus = "AI will auto-order medicines";
  String _selectedSchedule = "Monthly"; 
  
  List<dynamic> _detectedMedicines = [];
  final AiService _aiService = AiService();
  bool _isAnalyzing = false;

  // --- FUNCTION: Pick Image (Camera vs Gallery) ---
  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Scan Prescription",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blueAccent),
              title: const Text("Take Photo (Camera)", style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                if (photo != null) _processImage(File(photo.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.purpleAccent),
              title: const Text("Upload File (Gallery)", style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) _processImage(File(image.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNCTION: Process Image with AI ---
  Future<void> _processImage(File image) async {
    setState(() {
      _prescriptionImage = image;
      _scanStatus = "Analyzing with Gemini 2.5...";
      _isAnalyzing = true;
      _detectedMedicines = [];
    });

    try {
      final result = await _aiService.analyzeImage(
        image.path, 
        "Extract medicines and find prices in Rupees", 
        false 
      );

      setState(() {
        _isAnalyzing = false;
        
        if (result['products'] != null && (result['products'] as List).isNotEmpty) {
          _detectedMedicines = result['products'];
          var list = _detectedMedicines;
          String name1 = list[0]['productName'];
          String name2 = list.length > 1 ? ", ${list[1]['productName']}" : "";
          _scanStatus = "✅ Found: $name1$name2";
        } else {
          _scanStatus = "❌ No medicines detected";
        }
      });

    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _scanStatus = "❌ Error analyzing image";
      });
    }
  }

  String _calculatePrice(String rawPrice) {
    try {
      String numbersOnly = rawPrice.replaceAll(RegExp(r'[^0-9]'), '');
      if (numbersOnly.isEmpty) return rawPrice; 
      
      int basePrice = int.parse(numbersOnly);
      int multiplier = _selectedSchedule == "Monthly" ? 4 : 1;
      int finalPrice = basePrice * multiplier;

      return "₹$finalPrice";
    } catch (e) {
      return rawPrice;
    }
  }

  // --- MAIN BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("HomeOps Health"), backgroundColor: Colors.black),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Family Health Hub",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Manage prescriptions & checkups",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // --- PRESCRIPTION CARD ---
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: Colors.blueAccent.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _isAnalyzing 
                          ? const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(
                              _prescriptionImage == null
                                  ? Icons.document_scanner
                                  : Icons.check_circle,
                              color: _prescriptionImage == null
                                  ? Colors.blueAccent
                                  : Colors.greenAccent,
                              size: 30),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Upload Prescription",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  _prescriptionImage == null
                                      ? "AI will auto-order medicines"
                                      : _scanStatus, 
                                  style: TextStyle(
                                      color: _scanStatus.startsWith("❌") ? Colors.redAccent : Colors.white70,
                                      fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.camera_enhance,
                                color: Colors.blueAccent),
                            onPressed: () => _pickImage(context))
                      ],
                    ),
                    const SizedBox(height: 15),
                    Divider(color: Colors.blueAccent.withOpacity(0.3)),
                    const SizedBox(height: 10),

                    // Schedule Toggle
                    Row(
                      children: [
                        _buildScheduleOption("Weekly", Icons.calendar_view_week,
                            _selectedSchedule == "Weekly", () {
                          setState(() => _selectedSchedule = "Weekly");
                        }),
                        const SizedBox(width: 10),
                        _buildScheduleOption("Monthly", Icons.calendar_month,
                            _selectedSchedule == "Monthly", () {
                          setState(() => _selectedSchedule = "Monthly");
                        }),
                      ],
                    ),
                  ],
                ),
              ),

              // --- DETECTED MEDICINES ---
              if (_detectedMedicines.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Prescribed Medicines", 
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(_selectedSchedule, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Important inside SingleChildScrollView
                  itemCount: _detectedMedicines.length,
                  itemBuilder: (context, index) {
                    var item = _detectedMedicines[index];
                    String displayPrice = _calculatePrice(item['productPrice'] ?? "0");

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['productImage'] ?? "",
                              width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => Container(width: 50, height: 50, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['productName'] ?? "Medicine",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text(_selectedSchedule == "Monthly" ? "30 Days Supply" : "7 Days Supply", 
                                    style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(displayPrice, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("Order Now (Pay via Arc)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Processing Payment on Arc..."))
                        );
                    },
                  ),
                ),
              ],

              // --- FALLBACK VITALS ---
              if (_detectedMedicines.isEmpty) ...[
                const SizedBox(height: 20),
                const Text("Family Vitals",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildHealthItem("Father", "BP: 120/80 (Normal)",
                    Icons.favorite, Colors.redAccent),
                _buildHealthItem("Grandma", "Sugar: 140 mg/dL (High)",
                    Icons.water_drop, Colors.orange),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildScheduleOption(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.grey.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthItem(String name, String status, IconData icon, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20)),
      title: Text(name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(status, style: const TextStyle(color: Colors.grey)),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
    );
  }
}