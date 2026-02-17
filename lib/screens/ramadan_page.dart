import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ramadan_service.dart';

class RamadanPage extends StatefulWidget {
  final String district;
  const RamadanPage({super.key, required this.district});

  @override
  State<RamadanPage> createState() => _RamadanPageState();
}

class _RamadanPageState extends State<RamadanPage> {
  String? selectedDistrict;

  @override
  void initState() {
    super.initState();
    _loadSavedDistrict();
  }

  Future<void> _loadSavedDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString('selectedDistrict');

    setState(() {
      if (saved != null && RamadanService.districtAdjustment.containsKey(saved)) {
        selectedDistrict = saved;
      } else if (widget.district.isNotEmpty &&
          RamadanService.districtAdjustment.containsKey(widget.district)) {
        selectedDistrict = widget.district;
      } else {
        selectedDistrict = RamadanService.districtAdjustment.keys.first;
      }
    });
  }

  Future<void> _saveDistrict(String district) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDistrict', district);
  }

  @override
  Widget build(BuildContext context) {
    if (selectedDistrict == null) {
      // Show loading until district is loaded
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final adjustment = RamadanService.districtAdjustment[selectedDistrict!] ?? 0;
    final today = RamadanService.getToday();

    return Scaffold(
      appBar: AppBar(title: const Text("Ramadan Schedule")),
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// District selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDistrict,
                  isExpanded: true,
                  items: RamadanService.districtAdjustment.keys.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedDistrict = value;
                    });
                    _saveDistrict(value);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// Today's Ramadan card
          if (today != null) RamadanService.todayCard(today, adjustment),
          const SizedBox(height: 10),

          /// Full Ramadan list
          Expanded(
            child: ListView.builder(
              itemCount: RamadanService.ramadanTimes.length,
              itemBuilder: (_, index) {
                final item = RamadanService.ramadanTimes[index];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Ramadan ${item["ramadan"]}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const Text("Sehri",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text("Iftar",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item["date"]),
                            Text(RamadanService.adjustTime(
                                item["sehri"], adjustment)),
                            Text(RamadanService.adjustTime(
                                item["iftar"], adjustment)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}