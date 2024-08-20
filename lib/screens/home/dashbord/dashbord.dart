import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';
import 'package:habitatgn/screens/adversting/adversting.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
      ..loadRequest(Uri.parse('https://flutter.dev'));

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

    final filteredHouses = viewModel.recentHouses.where((house) {
      final lowerCaseQuery = _searchQuery.toLowerCase();

      return house.houseType!.label.toLowerCase().contains(lowerCaseQuery) ||
          house.description.toLowerCase().contains(lowerCaseQuery) ||
          house.address?.commune["label"]
              .toLowerCase()
              .contains(lowerCaseQuery) ||
          house.address?.town["label"].toLowerCase().contains(lowerCaseQuery) ||
          house.address!.zone.toLowerCase().contains(lowerCaseQuery);
    }).toList();
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.12,
        title: _buildSearchBar(),
        backgroundColor: primaryColor,
      ),
      body: viewModel.isAdverstingLoading
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenHeight * 0.20,
                    child: viewModel.advertisementData.isEmpty
                        ? _buildSkeletonAdvertisement()
                        : AdvertisementCarousel(
                            adverstingData: viewModel.advertisementData),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Nos Services'),
                  const SizedBox(height: 8),
                  _buildServicesSection(ref, context),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Nos annonces récentes'),
                      TextButton(
                        onPressed: () {
                          viewModel.navigateToHouseListPage(context);
                        },
                        child: const Text(
                          'Voir Tout',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRecentListings(viewModel, filteredHouses),
                  const SizedBox(height: 20),
                  _buildViewAllButton(viewModel),
                  const SizedBox(height: 20),
                  _buildOtherInformation(viewModel),
                ],
              ),
            ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildSkeletonAdvertisement(),
        const SizedBox(height: 20),
        _buildSkeletonServices(),
        const SizedBox(height: 20),
        _buildSkeletonRecentListings(),
        const SizedBox(height: 20),
        _buildSkeletonViewAllButton(),
        const SizedBox(height: 20),
        _buildSkeletonOtherInformation(),
      ],
    );
  }

  Widget _buildSkeletonAdvertisement() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
      child: Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildSkeletonServices() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSkeletonCard(),
        _buildSkeletonCard(),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
      child: Container(
        height: 100,
        color: Colors.grey.shade300,
        margin: const EdgeInsets.all(8.0),
      ),
    );
  }

  Widget _buildSkeletonRecentListings() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3, // Display 3 skeleton items for demonstration
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade200,
            child: Container(
              width: 150,
              margin: const EdgeInsets.all(8.0),
              color: Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonViewAllButton() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade200,
        child: Container(
          width: 200,
          height: 40,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildSkeletonOtherInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade200,
          child: Container(
            width: double.infinity,
            height: 40,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < 3; i++)
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade200,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              height: 60,
              color: Colors.grey.shade300,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        const Center(
          child: Text(
            "Bienvenue sur HABITATGN",
            style: TextStyle(color: Colors.white, fontSize: 22, shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black26,
                offset: Offset(2, 2),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _searchController,
          autofocus: false,
          onChanged: (query) {
            setState(() {
              _searchQuery = query.trim();
            });
            _performSearch();
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Trouvez ici votre maison, appartement, ...',
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                      _performSearch(); // Optionnel : Réinitialisez les résultats de la recherche
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 10, horizontal: 10), // Augmenter la hauteur du champ
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _performSearch() {
    setState(() {});
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
          style: const TextStyle(
              fontSize: 20,
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
            padding: const EdgeInsets.all(14.0),
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
                Icon(icon, color: Colors.white),
                const SizedBox(height: 5),
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
        ? houseCategoryListEmpty(
            title: 'Aucun résultat trouvé',
          )
        : viewModel.isRecentLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor))
            : SizedBox(
                height: screenHeight * 0.35,
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
                            width: screenHeight * 0.35,
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
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                            '${house.houseType?.label ?? ''} - '
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 8),
                                        Text(
                                            house.offerType["label"]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ],
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
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.attach_money_outlined,
                                        color: Colors.grey),
                                    Expanded(
                                      child: FormattedPrice(
                                        color: Colors.black,
                                        price: house.price,
                                        size: 16,
                                        suffix:
                                            house.offerType["value"] == "ALouer"
                                                ? '/mois'
                                                : '',
                                      ),
                                    ),
                                  ],
                                ),
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
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              viewModel.navigateToSupportPage(context);
            },
            child: _buildInfoItem(Icons.help, 'Conseils et astuces',
                'Consultez nos conseils pour tirer le meilleur parti de notre service.'),
          ),
          Divider(thickness: 1, color: Colors.grey[300]),
          InkWell(
            onTap: () {
              viewModel.navigateToContactPage(context);
            },
            child: _buildInfoItem(Icons.phone, 'Appelez-nous',
                'Contactez notre service client par téléphone pour toute assistance.'),
          ),
          Divider(thickness: 1, color: Colors.grey[300]),
          InkWell(
            onTap: () async {
              try {
                await navigateToUrl('https://www.example.com');
              } catch (e) {
                print('Failed to open URL: $e');
              }
            },
            child: _buildInfoItem(
              Icons.trending_up,
              'Maximisez vos chances',
              'Découvrez comment améliorer votre annonce pour attirer plus de potentiels locataires.',
            ),
          ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 18,
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
