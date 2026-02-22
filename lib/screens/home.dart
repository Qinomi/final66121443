// Packages
import 'package:flutter/material.dart';

// Helpers
import '../helpers/database.dart';

// Screen
// import 'edit_incident_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = [];
  int? _count = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await DatabaseHelper.incidentReportsJoinedTopThree();
      int? count = await DatabaseHelper.getCount();
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _count = count;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));
    if (_rows.isEmpty) return const Center(child: Text('No reports yet'));

    return ListView.builder(
      itemCount: _rows.length,
      itemBuilder: (_, i) {
        final r = _rows[i];
        final id = int.parse(r['station_id'].toString()); // safer than "as int"
        final c = _count;

        return Dismissible(
          key: ValueKey('r_$id'),
          direction: DismissDirection.horizontal,

          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            color: Colors.white,
            child: const Row(
              children: [
              ],
            ),
          ),
          secondaryBackground: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerRight,
            color: Colors.white,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              ],
            ),
          ),

          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              return false;
            } else {
              return false;
            }
          },

          onDismissed: (direction) {
            if (direction != DismissDirection.endToStart) return;
          },

          child: ListTile(
            title: Text('ID: ${r['station_id']} (${r['station_name']})'),
            subtitle: Text(
              'Incident count = ${r['incident_count']}\n'
              'Total incident count = ${c}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}