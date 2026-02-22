// Packages
import 'package:final66121443/screens/search.dart';
import 'package:flutter/material.dart';

// Helpers
import '../helpers/database.dart';

// Screens
import 'edit.dart';
import 'home.dart';
import 'list.dart';
import 'report.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
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
  
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(),

      AddReportScreen(),

      // const _SimplePage('Edit Screen'),
      EditScreen(),

      IncidentListScreen(),

      // const _SimplePage('Search Screen'),
      SearchScreen(),
    ];

    // int? n = DatabaseHelper().getCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Watch')
      ),
      body: IndexedStack(
        index: _index,
        children: pages
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Menu'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Report'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Edit'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search'
          ),
        ],
      ),
    );
  }
}

class _SimplePage extends StatelessWidget {
  final String text;
  const _SimplePage(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text)
    );
  }
}