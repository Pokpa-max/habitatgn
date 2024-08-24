import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:shimmer/shimmer.dart';
import 'package:habitatgn/models/adversting.dart';

class AdvertisementCarousel extends StatefulWidget {
  final List<AdvertisementData> adverstingData;

  const AdvertisementCarousel({
    super.key,
    required this.adverstingData,
  });

  @override
  State<AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return CarouselSlider.builder(
      itemCount: widget.adverstingData.length,
      itemBuilder: (BuildContext context, int index, int realIndex) {
        return _buildCarouselItem(
          context,
          widget.adverstingData[index].imageUrl,
          widget.adverstingData[index].title,
        );
      },
      options: CarouselOptions(
        height: screenHeight * 0.25, // 25% of screen height
        autoPlay: true,
        aspectRatio: 16 / 9,
        viewportFraction: 1.0,
        enlargeFactor: 0.15,
        enlargeCenterPage: true,
      ),
    );
  }

  Widget _buildCarouselItem(
      BuildContext context, String imageUrl, String subtitle) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: const EdgeInsets.all(0.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(0.0)),
        child: Stack(
          children: <Widget>[
            CustomCachedNetworkImage(
              imageUrl: imageUrl,
              width: screenWidth,
              height: screenHeight * 0.25,
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
        ),
      ),
    );
  }
}
