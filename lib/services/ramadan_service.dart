// ramadan_service.dart
import 'package:flutter/material.dart';

class RamadanService {
  // District adjustments
  static const Map<String, int> districtAdjustment = {
    "Dhaka": 0,
    "Faridpur": -1,
    "Gazipur": 0,
    "Gopalganj": -2,
    "Kishoreganj": -1,
    "Madaripur": -1,
    "Manikganj": -1,
    "Munshiganj": 0,
    "Narayanganj": 0,
    "Narsingdi": 0,
    "Rajbari": -2,
    "Shariatpur": -1,
    "Tangail": -2,

    "Chattogram": 5,
    "Cox's Bazar": 6,
    "Cumilla": 3,
    "Brahmanbaria": 2,
    "Chandpur": 2,
    "Feni": 4,
    "Khagrachhari": 4,
    "Lakshmipur": 3,
    "Noakhali": 4,
    "Rangamati": 5,
    "Bandarban": 6,

    "Sylhet": 6,
    "Moulvibazar": 6,
    "Habiganj": 5,
    "Sunamganj": 6,

    "Khulna": -3,
    "Bagerhat": -3,
    "Chuadanga": -5,
    "Jashore": -4,
    "Jhenaidah": -4,
    "Kushtia": -5,
    "Magura": -4,
    "Meherpur": -6,
    "Narail": -3,
    "Satkhira": -4,

    "Rajshahi": -6,
    "Bogura": -5,
    "Joypurhat": -6,
    "Naogaon": -6,
    "Natore": -6,
    "Chapainawabganj": -7,
    "Pabna": -5,
    "Sirajganj": -4,

    "Rangpur": -8,
    "Dinajpur": -8,
    "Gaibandha": -7,
    "Kurigram": -8,
    "Lalmonirhat": -8,
    "Nilphamari": -8,
    "Panchagarh": -9,
    "Thakurgaon": -9,

    "Barishal": -1,
    "Barguna": -2,
    "Bhola": 0,
    "Jhalokati": -1,
    "Patuakhali": -1,
    "Pirojpur": -2,

    "Mymensingh": -2,
    "Jamalpur": -3,
    "Netrokona": -3,
    "Sherpur": -3
  };

  // Ramadan times list
  static final List<Map<String, dynamic>> ramadanTimes = [
    {"ramadan": 1, "date": "2026-02-19", "sehri": "05:12", "iftar": "17:58"},
    {"ramadan": 2, "date": "2026-02-20", "sehri": "05:11", "iftar": "17:58"},
    {"ramadan": 3, "date": "2026-02-21", "sehri": "05:11", "iftar": "17:59"},
    {"ramadan": 4, "date": "2026-02-22", "sehri": "05:10", "iftar": "17:59"},
    {"ramadan": 5, "date": "2026-02-23", "sehri": "05:09", "iftar": "18:00"},
    {"ramadan": 6, "date": "2026-02-24", "sehri": "05:08", "iftar": "18:00"},
    {"ramadan": 7, "date": "2026-02-25", "sehri": "05:08", "iftar": "18:01"},
    {"ramadan": 8, "date": "2026-02-26", "sehri": "05:07", "iftar": "18:01"},
    {"ramadan": 9, "date": "2026-02-27", "sehri": "05:06", "iftar": "18:02"},
    {"ramadan": 10, "date": "2026-02-28", "sehri": "05:05", "iftar": "18:02"},
    {"ramadan": 11, "date": "2026-03-01", "sehri": "05:05", "iftar": "18:03"},
    {"ramadan": 12, "date": "2026-03-02", "sehri": "05:04", "iftar": "18:03"},
    {"ramadan": 13, "date": "2026-03-03", "sehri": "05:03", "iftar": "18:04"},
    {"ramadan": 14, "date": "2026-03-04", "sehri": "05:02", "iftar": "18:04"},
    {"ramadan": 15, "date": "2026-03-05", "sehri": "05:01", "iftar": "18:05"},
    {"ramadan": 16, "date": "2026-03-06", "sehri": "05:00", "iftar": "18:05"},
    {"ramadan": 17, "date": "2026-03-07", "sehri": "04:59", "iftar": "18:06"},
    {"ramadan": 18, "date": "2026-03-08", "sehri": "04:58", "iftar": "18:06"},
    {"ramadan": 19, "date": "2026-03-09", "sehri": "04:57", "iftar": "18:07"},
    {"ramadan": 20, "date": "2026-03-10", "sehri": "04:57", "iftar": "18:07"},
    {"ramadan": 21, "date": "2026-03-11", "sehri": "04:56", "iftar": "18:07"},
    {"ramadan": 22, "date": "2026-03-12", "sehri": "04:55", "iftar": "18:08"},
    {"ramadan": 23, "date": "2026-03-13", "sehri": "04:54", "iftar": "18:08"},
    {"ramadan": 24, "date": "2026-03-14", "sehri": "04:53", "iftar": "18:09"},
    {"ramadan": 25, "date": "2026-03-15", "sehri": "04:52", "iftar": "18:09"},
    {"ramadan": 26, "date": "2026-03-16", "sehri": "04:51", "iftar": "18:10"},
    {"ramadan": 27, "date": "2026-03-17", "sehri": "04:50", "iftar": "18:10"},
    {"ramadan": 28, "date": "2026-03-18", "sehri": "04:49", "iftar": "18:10"},
    {"ramadan": 29, "date": "2026-03-19", "sehri": "04:48", "iftar": "18:11"},
    {"ramadan": 30, "date": "2026-03-20", "sehri": "04:47", "iftar": "18:11"},
  ];

  // Adjust time based on district
  static String adjustTime(String time, int adjustment) {
    final parts = time.split(":");
    int hour = int.parse(parts[0]);
    int min = int.parse(parts[1]);

    DateTime dt = DateTime(2026, 1, 1, hour, min);
    dt = dt.add(Duration(minutes: adjustment));

    int h = dt.hour % 12;
    if (h == 0) h = 12;
    String ampm = dt.hour >= 12 ? "PM" : "AM";
    String m = dt.minute.toString().padLeft(2, '0');

    return "$h:$m $ampm";
  }

  // Today Ramadan
  static Map<String, dynamic>? getToday() {
    final today = DateTime.now().toString().substring(0, 10);
    try {
      return ramadanTimes.firstWhere((e) => e["date"] == today);
    } catch (e) {
      return null;
    }
  }

  // Today card widget
  static Widget todayCard(Map<String, dynamic> today, int adjustment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            "Ramadan ${today["ramadan"]}",
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _timeColumn("Sehri", today["sehri"], adjustment, Icons.dark_mode),
              _timeColumn("Iftar", today["iftar"], adjustment, Icons.wb_sunny),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _timeColumn(
      String title, String time, int adjustment, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        Text(
          adjustTime(time, adjustment),
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}