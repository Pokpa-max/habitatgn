// import 'package:flutter/material.dart';

// class CategoryListPage extends StatefulWidget {
//   final String category;
//   final IconData icon;

//   const CategoryListPage({
//     super.key,
//     required this.category,
//     required this.icon,
//   });

//   @override
//   _CategoryListPageState createState() => _CategoryListPageState();
// }

// class _CategoryListPageState extends State<CategoryListPage> {
//   List<String> items = []; // La liste d'éléments pour cette catégorie
//   List<String> filteredItems = [];
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Remplissez la liste d'éléments en fonction de la catégorie
//     items =
//         List.generate(20, (index) => '${widget.category} Item ${index + 1}');
//     filteredItems = List.from(items);

//     searchController.addListener(_filterItems);
//   }

//   void _filterItems() {
//     setState(() {
//       filteredItems = items
//           .where((item) =>
//               item.toLowerCase().contains(searchController.text.toLowerCase()))
//           .toList();
//     });
//   }

//   @override
//   void dispose() {
//     searchController.removeListener(_filterItems);
//     searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.category,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.cyan,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextFormField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Rechercher...',
//                 prefixIcon: const Icon(Icons.search, color: Colors.cyan),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Colors.cyan),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Colors.cyan),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredItems.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(filteredItems[index]),
//                   leading: Icon(widget.icon, color: Colors.cyan),
//                   onTap: () {
//                     // Action à effectuer lors du clic sur un élément
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class HousingItem {
  final String imageUrl;
  final String title;
  final String location;
  final String price;
  final String description;

  HousingItem({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    required this.description,
  });
}

class CategoryListPage extends StatefulWidget {
  final String category;
  final IconData icon;

  const CategoryListPage({
    super.key,
    required this.category,
    required this.icon,
  });

  @override
  _CategoryListPageState createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<HousingItem> items = [];
  List<HousingItem> filteredItems = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Simulate a list of housing items for this category
    items = List.generate(
      20,
      (index) => HousingItem(
        imageUrl: 'assets/images/maison.png${index % 5 + 1}.jpg',
        title: '${widget.category} Item ${index + 1}',
        location: 'Location ${index + 1}',
        price: '\$${(index + 1) * 1000}',
        description: 'Description de ${widget.category} Item ${index + 1}',
      ),
    );
    filteredItems = List.from(items);

    searchController.addListener(_filterItems);
  }

  void _filterItems() {
    setState(() {
      filteredItems = items.where((item) {
        final query = searchController.text.toLowerCase();
        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.location.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_filterItems);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search, color: Colors.cyan),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.cyan),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.cyan),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: Image.asset(
                      item.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.location),
                        Text(
                          item.price,
                          style: const TextStyle(
                              color: Colors.cyan, fontWeight: FontWeight.bold),
                        ),
                        Text(item.description,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    onTap: () {
                      // Action to be taken when an item is tapped
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
