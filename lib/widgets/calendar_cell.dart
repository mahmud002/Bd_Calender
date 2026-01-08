import 'package:flutter/material.dart';

class CalendarCell extends StatelessWidget {
  final int eng;
  final String bangla; // show as string so we can use bangla numerals if desired
  final String hijri;  // hijri day string
  final bool isHoliday;
  final bool isToday;

  const CalendarCell({
    Key? key,
    required this.eng,
    required this.bangla,
    required this.hijri,
    this.isHoliday = false,
    this.isToday = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainColor = isHoliday ? Colors.red : Colors.black87;
    final bg = isToday ? Colors.green.shade50 : Colors.white;

    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // english day big
          Text(
            '$eng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: mainColor,
            ),
          ),

          const SizedBox(height: 4),

          // bangla day (green)
          Text(
            bangla,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),

          // hijri day (blue)
          Text(
            hijri,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
