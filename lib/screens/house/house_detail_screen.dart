import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/notification/map/map_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/widgets/dashbord/dashbord.dart';
import 'package:habitatgn/viewmodels/housings/house_list.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HousingDetailPage extends ConsumerStatefulWidget {
  final String houseId;

  const HousingDetailPage({
    required this.houseId,
    super.key,
  });

  @override
  ConsumerState<HousingDetailPage> createState() => _HousingDetailPageState();
}

class _HousingDetailPageState extends ConsumerState<HousingDetailPage> {
  House? house;
  bool isLoading = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _fetchHouseDetails();
    _checkIfFavorite();
  }

  Future<void> _fetchHouseDetails() async {
    setState(() => isLoading = true);
    try {
      final houseListViewModel = ref.read(houseListViewModelProvider);
      house = await houseListViewModel.fetchHouseById(widget.houseId);
    } catch (e) {
      print('Error fetching house details: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkIfFavorite() async {
    final houseListViewModel = ref.read(houseListViewModelProvider);
    isLiked = await houseListViewModel.isFavorite(widget.houseId);
    setState(() {});
  }

  Future<void> _toggleLike() async {
    final houseListViewModel = ref.read(houseListViewModelProvider);

    if (!await houseListViewModel.checkConnectivity()) {
      _showSnackBar(
          'Pas de connexion Internet. Veuillez vérifier votre réseau.',
          Colors.black87);
      return;
    }

    final successMessage = isLiked
        ? '${house?.houseType?.label} retiré des coups de cœur!'
        : '${house?.houseType?.label} ajouté aux coups de cœur!';

    try {
      setState(() => isLiked = !isLiked);
      await houseListViewModel.toggleFavorite(widget.houseId);
      _showSnackBar(successMessage, isLiked ? primaryColor : Colors.black87);
    } catch (e) {
      _showSnackBar('Erreur: Veuillez réessayer plus tard.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
            child: Text(
          message,
          style: const TextStyle(fontSize: 16),
        )),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: _buildFloatingActionButton(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: house != null
                        ? _buildHouseDetails(house!)
                        : Container())
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ElevatedButton.icon(
      icon: const Icon(
        Icons.phone,
      ),
      style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
          backgroundColor: WidgetStateProperty.all(primaryColor),
          foregroundColor: WidgetStateProperty.all(Colors.white)),
      onPressed: () async {
        if (house?.phoneNumber != null) {
          final houseListViewModel = ref.read(houseListViewModelProvider);
          await houseListViewModel.launchPhoneCall("tel:${house!.phoneNumber}");
        }
      },
      label: const Text("Appeler l'Agence ", style: TextStyle(fontSize: 18)),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    double screenHeight = MediaQuery.of(context).size.height * 0.40;
    double screenWidth = MediaQuery.of(context).size.width;

    return SliverAppBar(
      backgroundColor: primaryColor,
      expandedHeight: screenHeight,
      leading: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: house != null
            ? Stack(
                children: [
                  ImageCarousel(
                    imageUrls: [house!.imageUrl, ...house!.houseInsides],
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(300, 0, 0, 0),
                            Color.fromARGB(0, 0, 0, 0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.01, // 1% of screen height
                        horizontal: screenWidth * 0.03, // 3% of screen width
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: IconButton(
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.black87, size: 30),
            onPressed: _toggleLike,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.black87, size: 30),
            onPressed: () {}, // Add share functionality here
          ),
        ),
      ],
    );
  }

  Widget _buildHouseDetails(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleAndLocationRow(house),
        const SizedBox(height: 15),
        _buildPriceRow(house),
        const SizedBox(height: 15),
        if (house.houseType?.label != "Terrain") ...[
          _buildBedroomsRow(house),
        ],
        if (house.houseType?.label == "Terrain") ...[
          _buildAreaRow(house),
        ],
        const SizedBox(height: 15),
        _buildLocationRow(house),
        const SizedBox(height: 20),
        _buildDescriptionSection(house),
        const SizedBox(height: 20),
        if (house.houseType?.label != "Terrain") ...[
          _buildAmenitiesSection(house),
        ],
        const SizedBox(height: 20),
        _buildAdditionalInfoSection(house),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTitleAndLocationRow(House house) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('${house.houseType?.label ?? ''} - ',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text(house.offerType["label"],
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(
                Icons.location_on,
              ),
              style: ButtonStyle(
                  padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
                  backgroundColor: WidgetStateProperty.all(primaryColor),
                  foregroundColor: WidgetStateProperty.all(Colors.white)),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationMapScreen(
                      latitude: house.address!.lat,
                      longitude: house.address!.long,
                      address:
                          '${house.address?.commune['label']}/${house.address?.zone}',
                      houseType: house.houseType!,
                    ),
                  ),
                );
              },
              label: const Text('Voir la localisation',
                  style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(House house) {
    return Row(
      children: [
        Icon(Icons.attach_money_outlined, color: Colors.grey[700]),
        FormattedPrice(
          color: Colors.black,
          price: house.price,
          size: 20,
          suffix: house.offerType["value"] == "ALouer" ? '/mois' : '',
        ),
      ],
    );
  }

  Widget _buildAreaRow(House house) {
    return Row(
      children: [
        const Icon(Icons.area_chart_sharp, color: Colors.grey),
        const SizedBox(width: 8),
        Text('${house.area} mm',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBedroomsRow(House house) {
    return Row(
      children: [
        const Icon(Icons.king_bed, color: Colors.grey),
        const SizedBox(width: 8),
        Text('${house.bedrooms} chambres',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLocationRow(House house) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.location_city, color: Colors.grey),
            const SizedBox(width: 8),
            Text('${house.address?.town['label']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey),
            const SizedBox(width: 8),
            Text('${house.address?.commune['label']}/${house.address?.zone}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        Divider(
          color: Colors.grey[200],
        ),
        const SizedBox(height: 8),
        Text(house.description, style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget _buildAmenitiesSection(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Équipements:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        Divider(
          color: Colors.grey[200],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: house.commodites
                  ?.map((amenity) => _buildAmenityCard(amenity['label']))
                  .toList() ??
              [],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informations supplémentaires:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        Divider(
          color: Colors.grey[200],
        ),
        const SizedBox(height: 8),
        if (house.houseType?.label != "Terrain") ...[
          _buildAdditionalInfo(house),
        ] else ...[
          const Text(
            'Documents du terrain',
          ),
          //  _buildAdditionalInfo(house),
        ],
      ],
    );
  }

  Widget _buildAmenityCard(String label) {
    return Card(
      color: lightPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: inputBackground)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
            Icons.attach_money, 'Caution: ${house.housingDeposit} mois'),
        const SizedBox(height: 10),
        _buildInfoRow(Icons.calendar_today,
            'Mois d\'avance: ${house.rentalDeposit} mois'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String info) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(
          height: 15,
          width: 8,
        ),
        Text(info, style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}
