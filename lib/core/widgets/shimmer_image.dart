import 'package:flutter/material.dart';

import 'app_shimmer.dart';

class ShimmerImage extends StatelessWidget {
  const ShimmerImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    Widget placeholder() {
      return AppShimmer(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: radius),
        ),
      );
    }

    Widget fallback() {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: radius,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.restaurant_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (imageUrl == null || imageUrl!.isEmpty) {
      return ClipRRect(borderRadius: radius, child: fallback());
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, synchronous) {
          if (synchronous || frame != null) return child;

          return placeholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return fallback();
        },
      ),
    );
  }
}
