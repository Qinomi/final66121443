import 'package:flutter/material.dart';
import '../helpers/database.dart';

class IncidentListScreen extends StatefulWidget {
  const IncidentListScreen({super.key});

  @override
  State<IncidentListScreen> createState() => IncidentListScreenState();
}

class IncidentListScreenState extends State<IncidentListScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = [];

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
      final rows = await DatabaseHelper.incidentReportsJoined();
      if (!mounted) return;
      setState(() {
        _rows = rows;
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

  Future<bool> _confirmDelete() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    return res ?? false;
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
        final id = int.parse(r['report_id'].toString());

        return Dismissible(
          key: ValueKey('r_$id'),
          direction: DismissDirection.horizontal,

          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            color: Colors.red,
            child: const Row(
              children: [
                Icon(Icons.delete, color: Colors.white),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          secondaryBackground: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Delete', style: TextStyle(color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),

          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              return await _confirmDelete();
            } else {
              return await _confirmDelete();
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
            title: Text('${r['type_name']} [${r['severity']}]'),
            subtitle: Text(
              '${r['station_name']} (${r['zone']}, ${r['province']})\n'
              '${r['timestamp']} • ${r['reporter_name']}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}