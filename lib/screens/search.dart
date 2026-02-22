import 'package:flutter/material.dart';

import '../helpers/database.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  const SearchScreen({super.key, this.onSaved});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reporterCtrl = TextEditingController();

  List<Map<String, dynamic>> _types = [];

  int? _typeId;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDropdowns();
  }

  @override
  void dispose() {
    _reporterCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDropdowns() async {
    final types = await DatabaseHelper.types();

    setState(() {
      _types = types;
      _typeId = types.isNotEmpty ? types.first['type_id'] as int : null;
      _loading = false;
    });
  }

  Future<void> _save() async {
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
            TextFormField(
              controller: _reporterCtrl,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              isExpanded: true,
              value: _typeId,
              items: _types.map((t) {
                final id = t['type_id'] as int;
                final severity = t['severity'] as String;
                return DropdownMenuItem(
                  value: id,
                  child: Text('$severity'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _typeId = v),
              decoration: const InputDecoration(
                labelText: 'Severity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Search'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}