import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AdvertisementCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final List<String> subtitles;

  const AdvertisementCarousel({
    super.key,
    required this.imageUrls,
    required this.subtitles,
  });

  @override
  State<AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: widget.imageUrls.length,
      itemBuilder: (BuildContext context, int index, int realIndex) {
        return _buildCarouselItem(
          context,
          widget.imageUrls[index],
          widget.subtitles[index],
        );
      },
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        aspectRatio: 16 / 8,
        viewportFraction: 1.0,
        enlargeFactor: 0.15,
        enlargeCenterPage: true,
      ),
    );
  }

  Widget _buildCarouselItem(
      BuildContext context, String imageUrl, String subtitle) {
    return Container(
      margin: const EdgeInsets.all(0.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(0.0)),
        child: Stack(
          children: <Widget>[
            Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              width: 1000.0,
              // height: 150.0,
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(200, 0, 0, 0),
                      Color.fromARGB(0, 0, 0, 0)
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
