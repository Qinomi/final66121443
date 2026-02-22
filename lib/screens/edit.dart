import 'package:flutter/material.dart';
import '../helpers/database.dart';
import 'edit_polling.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => EditScreenState();
}

class EditScreenState extends State<EditScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = [], _onlystation = [];

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
      final rows = await DatabaseHelper.incidentReportsJoinedOnlyStationName();
      final onlystation = await DatabaseHelper.pollingStation();
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _onlystation = onlystation;
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
        final o = _onlystation[i];
        final id = int.parse(r['report_id'].toString());

        return Dismissible(
          key: ValueKey('r_$id'),
          direction: DismissDirection.horizontal,

          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            color: Colors.green,
            child: const Row(
              children: [
                Icon(Icons.edit, color: Colors.white),
                SizedBox(width: 8),
                Text('Edit', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          secondaryBackground: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerRight,
            color: Colors.green,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Edit', style: TextStyle(color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.edit, color: Colors.white),
              ],
            ),
          ),

          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => EditPollingScreen(reportRow: o)),
              );
              if (updated == true) {
                await _load();
              }
              return false;
            } else {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => EditPollingScreen(reportRow: o)),
              );
              if (updated == true) {
                await _load();
              }
              return false;
            }
          },

          onDismissed: (direction) {
            if (direction != DismissDirection.endToStart) return;

            final idx = _rows.indexWhere((e) => int.parse(e['report_id'].toString()) == id);
            if (idx < 0) return;

            final removed = _rows[idx];

            setState(() {
              _rows.removeAt(idx);
            });

            DatabaseHelper.deleteIncidentReport(id).then((_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleted')),
              );
            }).catchError((e) {
              if (!mounted) return;
              setState(() {
                final insertAt = idx.clamp(0, _rows.length);
                _rows.insert(insertAt, removed);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Delete failed: $e')),
              );
            });
          },

          child: ListTile(
            title: Text('${r['station_name']}'),
          ),
        );
      },
    );
  }
}