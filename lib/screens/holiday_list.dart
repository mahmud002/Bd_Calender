import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../model/holiday_model.dart';

class HolidayListPage extends StatefulWidget {
  const HolidayListPage({super.key});

  @override
  State<HolidayListPage> createState() => _HolidayListPageState();
}

class _HolidayListPageState extends State<HolidayListPage> {
  int selectedYear = DateTime.now().year;
  List<HolidayModel> allHolidays = [];
  Map<int, List<HolidayModel>> groupedHolidays = {};

  @override
  void initState() {
    super.initState();
    loadHolidays();
  }

  Future<void> loadHolidays() async {
    // Open Hive box
    final box = Hive.box<HolidayModel>('holidayBox');

    // Get holidays for selected year where isGovt == true
    final holidays = box.values
        .where((h) => h.year == selectedYear && h.isGovt == true)
        .toList();

    // Group by month
    final Map<int, List<HolidayModel>> grouped = {};
    for (var h in holidays) {
      grouped.putIfAbsent(h.month, () => []).add(h);
    }

    // Sort each month's holidays by date
    for (var list in grouped.values) {
      list.sort((a, b) => a.date.compareTo(b.date));
    }

    setState(() {
      allHolidays = holidays;
      groupedHolidays = grouped;
    });
  }

  void _pickYear(BuildContext context) async {
    final int? year = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              selectedDate: DateTime(selectedYear),
              onChanged: (date) {
                Navigator.pop(context, date.year);
              },
            ),
          ),
        );
      },
    );

    if (year != null && year != selectedYear) {
      setState(() {
        selectedYear = year;
      });
      loadHolidays();
    }
  }

  Widget _buildHolidayItem(HolidayModel holiday) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date Box
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF8B0000)
                    : Color(0xFFDE3163)),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${holiday.date.day}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    DateFormat('MMM').format(holiday.date),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Title and Day
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    holiday.titleBn,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    holiday.titleEn,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      DateFormat('EEEE').format(holiday.date), // Saturday/Sunday
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color
                              ?.withOpacity(0.6)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: GestureDetector(
          onTap: () => _pickYear(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$selectedYear Holidays',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down,
                size: 28,
              ),
            ],
          ),
        ),
      ),

      body: groupedHolidays.isEmpty
          ? const Center(child: Text("No holidays found for this year"))
          : ListView(
        children: groupedHolidays.entries.map((entry) {
          final monthName =
          DateFormat('MMMM').format(DateTime(0, entry.key));
          final holidays = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Text(
                  monthName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              // Holiday List
              ...holidays.map(_buildHolidayItem),
            ],
          );
        }).toList(),
      ),
    );
  }
}
