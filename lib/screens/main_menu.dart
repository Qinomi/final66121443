// Packages
import 'package:flutter/material.dart';

// Screens
// ...

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _SimplePage('Home Screen'),
      const _SimplePage('List Screen'),
      const _SimplePage('Add Screen'),
      const _SimplePage('About Screen'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('App')
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
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About'
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