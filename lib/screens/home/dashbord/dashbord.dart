import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';
import 'package:habitatgn/screens/adversting/adversting.dart';
import 'package:habitatgn/screens/home/dashbord/widgets/sniper_loading.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:url_launcher/url_launcher.dart';

class DashbordScreen extends ConsumerStatefulWidget {
  const DashbordScreen({super.key});

  @override
  _DashbordScreenState createState() => _DashbordScreenState();
}

class _DashbordScreenState extends ConsumerState<DashbordScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(dashbordViewModelProvider);

    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: _buildAppBar(context, viewModel),
      body: viewModel.isAdverstingLoading
          ? SingleChildScrollView(
              child: Column(
                children: [
                  ShimmerLoading(
                      categorieLength: viewModel.getHousingCategories().length),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                viewModel.advertisementData.isEmpty
                    ? Container(
                        height: 250,
                        color: lightPrimary,
                        child: const Center(
                          child: Text(
                            "HABITATGN",
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : AdvertisementCarousel(
                        adverstingData: viewModel.advertisementData,
                      ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionTitle('Nos Catégories de Logements'),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: false,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCategoryGrid(context, viewModel),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactOptions(context),
        backgroundColor: primaryColor,
        child: const Icon(
          Icons.contact_phone,
          color: Colors.white,
        ),
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
      backgroundColor: primaryColor,
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
        child: Icon(icon, color: primaryColor),
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
        color: Colors.black,
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.phone,
                  color: primaryColor,
                ),
                title: const Text('Appeler l\'agent immobilier'),
                onTap: () {
                  _launchPhoneCall(
                      'tel:+1234567890'); // Remplacez par le numéro de téléphone réel
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.email,
                  color: primaryColor,
                ),
                title: const Text('Envoyer un email'),
                onTap: () {
                  _launchEmail(
                      'mailto:agent@example.com'); // Remplacez par l'email réel
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchPhoneCall(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  void _launchEmail(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
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
              Icon(icon, size: 30, color: primaryColor),
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
