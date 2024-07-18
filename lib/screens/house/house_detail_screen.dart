import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/housings/house_list.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:habitatgn/widgets/dashbord/dashbord.dart';
// import 'package:share_plus/share_plus.dart';

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
    try {
      setState(() {
        isLoading = true;
      });
      final houseListViewModel = ref.read(houseListViewModelProvider);
      House? fetchedHouse =
          await houseListViewModel.fetchHouseById(widget.houseId);
      if (fetchedHouse != null) {
        setState(() {
          house = fetchedHouse;
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    final houseListViewModel = ref.read(houseListViewModelProvider);
    bool isFav = await houseListViewModel.isFavorite(widget.houseId);
    setState(() {
      isLiked = isFav;
    });
  }

  void _toggleLike() async {
    final houseListViewModel = ref.read(houseListViewModelProvider);
    await houseListViewModel.toggleFavorite(widget.houseId);
    setState(() {
      isLiked = !isLiked;
    });
  }

  void _shareHouseDetails() {
    if (house != null) {
      // Share.share(
      //   'Découvrez ce logement : ${house!.houseType!.label}, situé à ${house!.address?.town['label'] ?? 'localisation inconnue'}. Prix: ${house!.price} €. Description: ${house!.description}',
      //   subject: 'Détails du logement',
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: backgroundColor,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                // Ajouter la logique pour contacter le propriétaire
              },
              icon: const Icon(
                Icons.phone,
                color: Colors.white,
              ),
              label: const Text(
                'Appeler',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: primaryColor,
            ),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: primaryColor,
                  expandedHeight: 280.0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: house != null
                        ? ImageCarousel(
                            imageUrls: [
                              house!.imageUrl,
                              ...house!.houseInsides
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: 30,
                      ),
                      onPressed: _toggleLike,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: _shareHouseDetails,
                    ),
                  ],
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: house != null
                            ? _buildHouseDetails(house!)
                            : Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildHouseDetails(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleAndLocationRow(house),
        const SizedBox(height: 10),
        _buildPriceRow(house),
        const SizedBox(height: 10),
        _buildBedroomsRow(house),
        const SizedBox(height: 10),
        _buildLocationRow(house),
        const SizedBox(height: 10),
        _buildDescriptionSection(house),
        const SizedBox(height: 15),
        _buildAmenitiesSection(house),
        const SizedBox(height: 15),
        _buildAdditionalInfoSection(house),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPriceRow(House house) {
    return Row(
      children: [
        const Icon(
          Icons.attach_money_outlined,
          color: primaryColor,
          size: 30,
        ),
        FormattedPrice(
          color: Colors.black,
          price: house.price,
          suffix: house.offerType["label"] == "ALouer" ? '/mois' : '',
        ),
      ],
    );
  }

  Widget _buildBedroomsRow(House house) {
    return house.houseType!.label != "Terrains"
        ? Row(
            children: [
              const Icon(Icons.king_bed, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                '${house.bedrooms} chambres',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        : Container();
  }

  Widget _buildLocationRow(House house) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.location_city, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              '${house.address!.town['label']} ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              '${house.address!.commune['label']}/${house.address!.zone}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          house.description,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(House house) {
    return house.houseType!.label != "Terrains"
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Équipements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: house.commodites!
                    .map((amenity) => _buildAmenityCard(amenity['label']))
                    .toList(),
              )
            ],
          )
        : const Text("");
  }

  Widget _buildAdditionalInfoSection(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations supplémentaires',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        house.houseType!.label != "Terrains"
            ? _buildAdditionalInfo(house)
            : const Text('documents du terrain'),
      ],
    );
  }

  Widget _buildAmenityCard(String label) {
    return Card(
      color: lightPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
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
        _buildInfoRow(Icons.calendar_today,
            'Mois d\'avance: ${house.rentalDeposit} mois'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String info) {
    return Row(
      children: [
        Icon(icon, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          info,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTitleAndLocationRow(House house) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              '${house.houseType?.label ?? ''} - ',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            SeparatedText(
              text: house.offerType["label"],
              firstLetterStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              restOfTextStyle: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              spaceBetween: 6.0,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.location_on_rounded,
                size: 30,
                color: primaryColor,
              ),
            ),
            const Text(
              'Voir localisation',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
}
