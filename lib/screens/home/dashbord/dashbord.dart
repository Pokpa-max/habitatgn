import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';
import 'package:habitatgn/screens/adversting/adversting.dart';
import 'package:habitatgn/screens/home/dashbord/widgets/sniper_loading.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class DashbordScreen extends ConsumerStatefulWidget {
  const DashbordScreen({super.key});

  @override
  _DashbordScreenState createState() => _DashbordScreenState();
}

class _DashbordScreenState extends ConsumerState<DashbordScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late final WebViewController _controller;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialisation du WebView en fonction de la plateforme
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(
          Uri.parse('https://flutter.dev')); // Charge une URL par défaut

    // Met à jour le ViewModel avec le WebViewController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(dashbordViewModelProvider);
      viewModel.setWebViewController(_controller);
    });
  }

  Future<void> navigateToUrl(String url) async {
    if (_controller != null) {
      if (await _controller.canGoBack()) {
        await _controller.goBack();
      } else {
        await _controller.loadRequest(Uri.parse(url));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(dashbordViewModelProvider);

    // Filtered list based on search query
    final filteredHouses = viewModel.recentHouses.where((house) {
      final lowerCaseQuery = _searchQuery.toLowerCase();
      return house.houseType!.label.toLowerCase().contains(lowerCaseQuery) ||
          house.description.toLowerCase().contains(lowerCaseQuery) ||
          house.address!.town["label"].toLowerCase().contains(lowerCaseQuery);
    }).toList();
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        title: _buildSearchBar(),
        backgroundColor: primaryColor,
        elevation: 4,
      ),
      body: viewModel.isAdverstingLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenHeight * 0.20,
                    child: viewModel.advertisementData.isEmpty
                        ? Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [lightPrimary, primaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Text("HABITATGN",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                            ),
                          )
                        : AdvertisementCarousel(
                            adverstingData: viewModel.advertisementData),
                  ),
                  const SizedBox(height: 20),
                  // Services Section
                  _buildSectionTitle('Nos Services'),
                  const SizedBox(height: 10),
                  _buildServicesSection(ref, context),
                  const SizedBox(height: 20),
                  // Logements Récents
                  _buildSectionTitle('Logements Récents'),
                  const SizedBox(height: 10),
                  // Affichage des logements filtrés
                  _buildRecentListings(viewModel, filteredHouses),
                  const SizedBox(height: 20),
                  // Voir toutes les annonces Button
                  _buildViewAllButton(viewModel),
                  const SizedBox(height: 20),
                  // Autres Informations
                  _buildOtherInformation(viewModel),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        const Center(
          child: Text(
            "Bienvenue sur HABITATGN",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: _searchController,
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
            _performSearch();
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Rechercher ici une maison, un appartement, terrain ...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _performSearch() {
    // Refresh the UI by setting the search query
    setState(() {
      // No additional logic needed if search is handled in the build method
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
    );
  }

  Widget _buildServicesSection(WidgetRef ref, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildServiceCard(
            icon: Icons.build,
            title: 'Réparations',
            onTap: () => ref
                .read(dashbordViewModelProvider.notifier)
                .navigateToRepairPage(context)),
        _buildServiceCard(
            icon: Icons.local_shipping,
            title: 'Déménagement',
            onTap: () => ref
                .read(dashbordViewModelProvider.notifier)
                .navigateToMovingPage(context)),
      ],
    );
  }

  Widget _buildServiceCard(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Expanded(
      child: Card(
        elevation: 0.5,
        color: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: primaryColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              gradient: LinearGradient(
                colors: [lightPrimary, primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 30, color: Colors.white),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentListings(DashbordViewModel viewModel, List<House> houses) {
    double screenHeight = MediaQuery.of(context).size.height;
    return houses.isEmpty
        ? const Center(child: Text('Aucun résultat trouvé'))
        : viewModel.isRecentLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor))
            : SizedBox(
                height: screenHeight * 0.25,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: houses.length,
                  itemBuilder: (context, index) {
                    final house = houses[index];
                    return InkWell(
                      onTap: () {
                        viewModel.navigateToHousingDetailPage(
                            context, house.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0.5,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: lightPrimary2)),
                          child: Container(
                            width: 300,
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: CustomCachedNetworkImage(
                                        imageUrl: house.imageUrl,
                                        width: double.infinity,
                                        height: 150,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      house.houseType!.label,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    FormattedPrice(
                                      color: Colors.black,
                                      price: house.price,
                                      suffix:
                                          house.offerType["value"] == "ALouer"
                                              ? '/mois'
                                              : '',
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      ' ${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                Text(
                                  house.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                                // Ajoutez d'autres détails ici si nécessaire
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
  }

  Widget _buildViewAllButton(DashbordViewModel viewModel) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          viewModel.navigateToHouseListPage(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Background color
          foregroundColor: Colors.white, // Text color
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Voir Toutes les Annonces',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOtherInformation(DashbordViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Autres Informations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              // Ajoutez ici votre logique pour ouvrir le lien
              try {
                await navigateToUrl('https://www.example.com');
              } catch (e) {
                print('Failed to open URL😡😡😡😡: $e');
                print(e);
              }
            },
            child: _buildInfoItem(
              Icons.trending_up,
              'Maximisez vos chances',
              'Découvrez comment améliorer votre annonce pour attirer plus de potentiels locataires.',
            ),
          ),
          Divider(thickness: 1, color: Colors.grey[300]),
          InkWell(
            onTap: () {
              viewModel.navigateToSupportPage(context);
            },
            child: _buildInfoItem(Icons.help, 'Conseils et astuces',
                'Consultez nos conseils pour tirer le meilleur parti de notre service.'),
          ),
          Divider(thickness: 1, color: Colors.grey[300]),
          _buildInfoItem(Icons.phone, 'Appelez-nous',
              'Contactez notre service client par téléphone pour toute assistance.'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
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
