import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as dev;

import '../helpers/database.dart';

class AddReportScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  const AddReportScreen({super.key, this.onSaved});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reporterCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();

  List<Map<String, dynamic>> _stations = [];
  List<Map<String, dynamic>> _types = [];

  int? _stationId;
  int? _typeId;

  bool _loading = true;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadDropdowns();
  }

  @override
  void dispose() {
    _reporterCtrl.dispose();
    _descCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _loading = true;
      });

    } catch (e) {
      dev.log("Error picking image: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadDropdowns() async {
    final stations = await DatabaseHelper.stations();
    final types = await DatabaseHelper.types();

    setState(() {
      _stations = stations;
      _types = types;
      _stationId = stations.isNotEmpty ? stations.first['station_id'] as int : null;
      _typeId = types.isNotEmpty ? types.first['type_id'] as int : null;
      _loading = false;
    });
  }

  String _nowTimestamp() {
    final dt = DateTime.now();
    String two(int x) => x.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_stationId == null || _typeId == null) return;

    final ts = _nowTimestamp();
    final photo = _photoCtrl.text.trim();

    await DatabaseHelper.insertIncidentReport({
      'station_id': _stationId,
      'type_id': _typeId,
      'reporter_name': _reporterCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'evidence_photo': photo.isEmpty ? null : photo,
      'timestamp': ts,
      'ai_result': null,
      'ai_confidence': 0.0,
    });

    widget.onSaved?.call();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved incident report')),
    );

    _reporterCtrl.clear();
    _descCtrl.clear();
    _photoCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              isExpanded: true,
              value: _stationId,
              items: _stations.map((s) {
                final id = s['station_id'] as int;
                final name = s['station_name'] as String;
                final zone = s['zone'] as String;
                return DropdownMenuItem(
                  value: id,
                  child: Text('$id - $name ($zone)'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _stationId = v),
              decoration: const InputDecoration(
                labelText: 'Polling station',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              isExpanded: true,
              value: _typeId,
              items: _types.map((t) {
                final id = t['type_id'] as int;
                final name = t['type_name'] as String;
                final sev = t['severity'] as String;
                return DropdownMenuItem(
                  value: id,
                  child: Text('$id - $name [$sev]'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _typeId = v),
              decoration: const InputDecoration(
                labelText: 'Violation type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _reporterCtrl,
              decoration: const InputDecoration(
                labelText: 'Reporter name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "btn1",
                  onPressed: () => pickImage(ImageSource.camera),
                  tooltip: 'Camera',
                  child: const Icon(Icons.camera_alt),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "btn2",
                  onPressed: () => pickImage(ImageSource.gallery),
                  tooltip: 'Gallery',
                  child: const Icon(Icons.photo_library),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _photoCtrl,
              decoration: const InputDecoration(
                labelText: 'Evidence photo path',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}