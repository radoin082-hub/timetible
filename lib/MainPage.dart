import 'package:flutter/material.dart';
 
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      _showSearchSheet();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SearchModalSheet(),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Add your page or content here based on the selected index
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class SearchModalSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Add a TextField or any other widget to input search query
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                ),
                onChanged: (query) {
                  // Perform search using your CustomSpecialtySearchDelegate
                },
              ),
              Expanded(
                child: Container(
                  // Display search results or suggestions here
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
