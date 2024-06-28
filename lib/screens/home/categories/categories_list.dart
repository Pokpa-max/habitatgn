import 'package:flutter/material.dart';
import 'package:habitatgn/utils/appcolors.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryTitle;
  final List<RecommendedHousingData> housingList;

  const CategoryDetailScreen({
    super.key,
    required this.categoryTitle,
    required this.housingList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryTitle,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
      ),
      body: ListView.builder(
        itemCount: housingList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: RecommendedHousingCard(
              imageUrl: housingList[index].imageUrl,
              title: housingList[index].title,
              location: housingList[index].location,
              price: housingList[index].price,
            ),
          );
        },
      ),
    );
  }
}

class RecommendedHousingData {
  final String imageUrl;
  final String title;
  final String location;
  final String price;

  RecommendedHousingData({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
  });
}

class RecommendedHousingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String price;

  // ignore: use_super_parameters
  const RecommendedHousingCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
            child: Image.asset(
              imageUrl,
              height: 150,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
