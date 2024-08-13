import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        color: Colors.grey[300],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // width: 150,
                // height: 200,
                width: screenWidth * 0.40,
                height: screenHeight * 0.15,
                color: Colors.grey[300],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16.0,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 100.0,
                      height: 16.0,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 80.0,
                      height: 16.0,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 16.0,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
