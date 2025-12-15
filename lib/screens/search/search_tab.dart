import 'package:flutter/material.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy data list
  final List<String> _items = [
    "Apple",
    "Banana",
    "Cat",
    "Dog",
    "Elephant",
    "Fan",
    "Grapes",
    "House",
    "Ice Cream",
    "Jaguar",
    "Kite",
  ];

  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _items; // show full list initially
  }

  void _performSearch(String query) {
    final result = _items
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _filteredItems = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch("");
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _performSearch,
          ),
        ),

        // Results
        Expanded(
          child: _filteredItems.isEmpty
              ? const Center(
                  child: Text(
                    "No results found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.search),
                      title: Text(_filteredItems[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
