import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount = 5;
  final double size;
  final Color color;

  StarRating({
    required this.rating,
    this.size = 24.0,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        starCount,
            (index) {
          if (index > rating) {
            // Full star
            return Icon(
              Icons.star_border,
              size: size,
              color: color,
            );
          } else if (index == rating ~/ 1 && rating - index != 0) {
            // Half star
            return Icon(
              Icons.star_half,
              size: size,
              color: color,
            );
          } else {
            // Empty star
            return Icon(
              Icons.star,
              size: size,
              color: color,
            );
          }
        },
      ),
    );
  }
}