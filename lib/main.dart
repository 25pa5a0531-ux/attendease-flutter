import 'package:flutter/material.dart';

void main() {
  runApp(const AttendanceApp());
}

const purple = Color(0xFF6558D3);
const background = Color(0xFFF6F7FB);

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AttendEase',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: purple),
        scaffoldBackgroundColor: background,
      ),
      home: const AttendanceDashboard(),
    );
  }
}

class AttendanceEntry {
  final DateTime date;
  bool? present;

  AttendanceEntry(this.date, this.present);
}

class AttendanceSubject {
  final String name;
  final IconData icon;
  final List<AttendanceEntry> entries;

  AttendanceSubject({
    required this.name,
    required this.icon,
    required this.entries,
  });

  int get totalClasses =>
      entries.where((e) => e.present != null).length;

  int get classesAttended =>
      entries.where((e) => e.present == true).length;

  double get percentage =>
      totalClasses == 0 ? 0 : classesAttended / totalClasses * 100;

  AttendanceEntry? entryFor(DateTime date) {
    for (final entry in entries) {
      if (sameDay(entry.date, date)) return entry;
    }
    return null;
  }

  void updateAttendance(DateTime date, bool? present) {
    final existing = entryFor(date);

    if (existing != null) {
      existing.present = present;
    } else {
      entries.add(AttendanceEntry(date, present));
      entries.sort((a, b) => a.date.compareTo(b.date));
    }
  }
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime dateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

String formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String weekdayName(DateTime date) {
  const days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];
  return days[date.weekday - 1];
}

// DEMO DATA: generates example attendance from semester day one.
// Replace this with your real college attendance records.
List<AttendanceSubject> createDemoSubjects() {
  final today = dateOnly(DateTime.now());
  final semesterStart = DateTime(today.year, today.month - 1, 1);

  final subjects = <AttendanceSubject>[
    AttendanceSubject(
      name: 'Mathematics',
      icon: Icons.calculate_outlined,
      entries: [],
    ),
    AttendanceSubject(
      name: 'Computer Science',
      icon: Icons.computer_outlined,
      entries: [],
    ),
    AttendanceSubject(
      name: 'English',
      icon: Icons.menu_book_outlined,
      entries: [],
    ),
    AttendanceSubject(
      name: 'Database Management',
      icon: Icons.storage_outlined,
      entries: [],
    ),
    AttendanceSubject(
      name: 'Operating Systems',
      icon: Icons.memory_outlined,
      entries: [],
    ),
    AttendanceSubject(
      name: 'Web Development',
      icon: Icons.web_outlined,
      entries: [],
    ),
    AttendanceSubject(
      name: 'Computer Networks',
      icon: Icons.lan_outlined,
      entries: [],
    ),
    AttendanceSubject(
      name: 'Software Engineering',
      icon: Icons.engineering_outlined,
      entries: [],
    ),
    AttendanceSubject(
      name: 'Data Structures',
      icon: Icons.account_tree_outlined,
      entries: [],
    ),
    AttendanceSubject(
      name: 'Mobile App Development',
      icon: Icons.phone_android_outlined,
      entries: [],
    ),
  ];

  for (int i = 0; i < subjects.length; i++) {
    var classNumber = 0;

    for (
      DateTime date = semesterStart;
      !date.isAfter(today);
      date = date.add(const Duration(days: 1))
    ) {
      // Example timetable: weekdays only, with different
      // subjects scheduled on different days.
      if (date.weekday > 5) continue;
      if ((date.day + i) % 3 == 0) continue;

      // Today remains unmarked until the student updates it.
      if (sameDay(date, today)) {
        subjects[i].entries.add(AttendanceEntry(date, null));
        continue;
      }

      // Example historical data, for demonstration only.
      final present = (classNumber + i) % 5 != 0;
      subjects[i].entries.add(AttendanceEntry(date, present));
      classNumber++;
    }
  }

  return subjects;
}

class AttendanceDashboard extends StatefulWidget {
  const AttendanceDashboard({super.key});

  @override
  State<AttendanceDashboard> createState() =>
      _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  late final List<AttendanceSubject> subjects;
  late final DateTime today;

  @override
  void initState() {
    super.initState();
    today = dateOnly(DateTime.now());
    subjects = createDemoSubjects();
  }

  int get totalClasses =>
      subjects.fold(0, (sum, subject) => sum + subject.totalClasses);

  int get classesAttended =>
      subjects.fold(0, (sum, subject) => sum + subject.classesAttended);

  int get unmarkedToday => subjects.where((subject) {
        final entry = subject.entryFor(today);
        return entry == null || entry.present == null;
      }).length;

  double get attendancePercentage =>
      totalClasses == 0 ? 0 : classesAttended / totalClasses * 100;

  void updateAttendance(
    AttendanceSubject subject,
    DateTime date,
    bool? present,
  ) {
    setState(() {
      subject.updateAttendance(date, present);
    });
  }

  void addSubject() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Subject name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();

              if (name.isEmpty) return;

              setState(() {
                subjects.add(
                  AttendanceSubject(
                    name: name,
                    icon: Icons.book_outlined,
                    entries: [
                      AttendanceEntry(today, null),
                    ],
                  ),
                );
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Add Subject'),
          ),
        ],
      ),
    );
  }

  void editSubject(AttendanceSubject subject) {
    final controller = TextEditingController(text: subject.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Subject'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Subject name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();

              if (name.isEmpty) return;

              setState(() {
                final index = subjects.indexOf(subject);
                subjects[index] = AttendanceSubject(
                  name: name,
                  icon: subject.icon,
                  entries: subject.entries,
                );
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentage = attendancePercentage;
    final isEligible = percentage >= 75;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.school, color: purple),
            SizedBox(width: 10),
            Text(
              'AttendEase',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addSubject,
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Attendance Dashboard',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your subject-wise attendance from day one to today.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              'Today: ${formatDate(today)}',
              style: const TextStyle(
                color: purple,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 22),

            // Overall attendance
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [purple, Color(0xFF9185F2)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Attendance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: CircularProgressIndicator(
                          value: percentage / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.white30,
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isEligible
                        ? 'You meet the 75% attendance target.'
                        : 'You are below the 75% attendance target.',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$unmarkedToday subjects not marked for today',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Classes',
                    value: '$totalClasses',
                    icon: Icons.calendar_month,
                    color: purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Classes Attended',
                    value: '$classesAttended',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),
            const Text(
              "Today's Attendance",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Mark or correct today’s attendance for each subject.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            ...subjects.map(
              (subject) => _TodaySubjectCard(
                subject: subject,
                today: today,
                onChanged: (value) =>
                    updateAttendance(subject, today, value),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Subject-wise Attendance History',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Expand any subject to see daily records from semester day one.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            ...subjects.map(
              (subject) => _SubjectHistoryCard(
                subject: subject,
                today: today,
                onChanged: (date, value) =>
                    updateAttendance(subject, date, value),
                onEdit: () => editSubject(subject),
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

class _TodaySubjectCard extends StatelessWidget {
  final AttendanceSubject subject;
  final DateTime today;
  final ValueChanged<bool?> onChanged;

  const _TodaySubjectCard({
    required this.subject,
    required this.today,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final entry = subject.entryFor(today);
    final status = entry?.present;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.book_outlined, color: purple),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    subject.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: status == true ? null : () => onChanged(true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                    child: const Text('Present'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: status == false ? null : () => onChanged(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Absent'),
                  ),
                ),
                IconButton(
                  tooltip: 'Clear today’s attendance',
                  onPressed: status == null ? null : () => onChanged(null),
                  icon: const Icon(Icons.undo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectHistoryCard extends StatelessWidget {
  final AttendanceSubject subject;
  final DateTime today;
  final void Function(DateTime date, bool? value) onChanged;
  final VoidCallback onEdit;

  const _SubjectHistoryCard({
    required this.subject,
    required this.today,
    required this.onChanged,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final entries = subject.entries.reversed.toList();

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: purple.withValues(alpha: 0.10),
          child: Icon(subject.icon, color: purple),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${subject.classesAttended}/${subject.totalClasses} classes attended'
          ' • ${subject.percentage.toStringAsFixed(1)}%',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: subject.percentage / 100,
                    minHeight: 7,
                    backgroundColor: Colors.grey.shade200,
                    color: subject.percentage >= 75
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${subject.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                tooltip: 'Rename subject',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const Divider(),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No attendance records available.'),
            )
          else
            ...entries.map((entry) {
              return _HistoryRow(
                entry: entry,
                today: today,
                onChanged: (value) => onChanged(entry.date, value),
              );
            }),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final AttendanceEntry entry;
  final DateTime today;
  final ValueChanged<bool?> onChanged;

  const _HistoryRow({
    required this.entry,
    required this.today,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status = entry.present;
    final isToday = sameDay(entry.date, today);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(entry.date),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      weekdayName(entry.date) + (isToday ? ' • Today' : ''),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: status),
              const SizedBox(width: 8),
              PopupMenuButton<bool?>(
                tooltip: 'Correct attendance',
                onSelected: onChanged,
                itemBuilder: (context) => const [
                  PopupMenuItem<bool?>(
                    value: true,
                    child: Text('Mark Present'),
                  ),
                  PopupMenuItem<bool?>(
                    value: false,
                    child: Text('Mark Absent'),
                  ),
                  PopupMenuItem<bool?>(
                    value: null,
                    child: Text('Clear record'),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.edit_calendar_outlined, color: purple),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool? status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = status == true
        ? 'Present'
        : status == false
            ? 'Absent'
            : 'Not marked';

    final color = status == true
        ? Colors.green
        : status == false
            ? Colors.red
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
