import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';
import 'package:habitatgn/screens/adversting/adversting.dart';
import 'package:habitatgn/screens/home/dashbord/widgets/sniper_loading.dart';
import 'package:habitatgn/utils/appcolors.dart';

class DashbordScreen extends ConsumerWidget {
  const DashbordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(dashbordViewModelProvider);

    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: _buildAppBar(context, viewModel),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.isAdverstingLoading)
            const ShimmerLoading()
          else
            AdvertisementCarousel(
              imageUrls: viewModel.imageUrls,
              subtitles: viewModel.subtitles,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionTitle('Nos Catégories de Logements'),
                  const SizedBox(height: 10),
                  _buildCategoryGrid(context, viewModel),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, DashbordViewModel viewModel) {
    return AppBar(
      title: const Text(
        'HABITATGN',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: primary,
      actions: [
        _buildAppBarIcon(
          icon: Icons.search,
          onTap: () => viewModel.navigateToSearchPage(context),
        ),
        _buildAppBarIcon(
          icon: Icons.notifications,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAppBarIcon(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: Icon(icon, color: primary),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, DashbordViewModel viewModel) {
    final categories = viewModel.getHousingCategories();

    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          children: categories.map((category) {
            return CategoryCard(
              icon: category.icon,
              label: category.label,
              onTap: () async {
                await viewModel.navigateToHouseList(context, category);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black87,
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: primary),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
