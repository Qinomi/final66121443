import 'package:flutter/material.dart';
import '../helpers/database.dart';

class EditPollingScreen extends StatefulWidget {
  final Map<String, dynamic> reportRow;
  const EditPollingScreen({super.key, required this.reportRow});

  @override
  State<EditPollingScreen> createState() => _EditPollingScreenState();
}

class _EditPollingScreenState extends State<EditPollingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stationCtrl = TextEditingController();

  int? _stationId;
  int? _typeId;

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _stationCtrl.text = (widget.reportRow['station_name'] ?? '').toString();

    _stationId = widget.reportRow['station_id'] as int?;
    _typeId = widget.reportRow['type_id'] as int?;

    _loadDropdowns();
  }

  @override
  void dispose() {
    _stationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDropdowns() async {
    final stations = await DatabaseHelper.stations();
    final types = await DatabaseHelper.types();

    setState(() {
      if (_stationId == null && stations.isNotEmpty) {
        _stationId = stations.first['station_id'] as int;
      }
      if (_typeId == null && types.isNotEmpty) {
        _typeId = types.first['type_id'] as int;
      }
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_stationId == null || _typeId == null) return;

    final typeId = widget.reportRow['type_id'] as int;

    await DatabaseHelper.updateIncidentReport(typeId, {
      'station_name': _stationCtrl.text.trim(),
    });

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Station Name')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _stationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Station name',
                  border: OutlineInputBorder(),
                ),
                // validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Required';
                  }
                  var re = RegExp(r"โรงเรียน*");
                  if (re.hasMatch(v)) {
                    return null;
                  }
                  re = RegExp(r"วัด*");
                  if (re.hasMatch(v)) {
                    return null;
                  }
                  re = RegExp(r"เต็นท์*");
                  if (re.hasMatch(v)) {
                    return null;
                  }
                  re = RegExp(r"ศาลา*");
                  if (re.hasMatch(v)) {
                    return null;
                  }
                  re = RegExp(r"หอประชุม*");
                  if (re.hasMatch(v)) {
                    return null;
                  }
                  return 'Incorrect Prefixes';
                },
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}