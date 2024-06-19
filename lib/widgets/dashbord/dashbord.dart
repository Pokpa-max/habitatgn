import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

Widget buildSectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  // ignore: library_private_types_in_public_api
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: false,
            aspectRatio: 16 / 8,
            // enlargeFactor: 0.2,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.imageUrls.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                );
              },
            );
          }).toList(),
        ),
        // const SizedBox(height: 10),
        Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.imageUrls.map((imageUrl) {
                int index = widget.imageUrls.indexOf(imageUrl);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.cyan
                        : Colors.black.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "A vendre",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan),
                  )),
            )
          ],
        ),
      ],
    );
  }
}
