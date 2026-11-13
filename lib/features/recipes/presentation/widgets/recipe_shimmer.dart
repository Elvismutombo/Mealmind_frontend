import 'package:flutter/material.dart';

import '/core/widgets/app_shimmer.dart';

class RecipeShimmer extends StatelessWidget {
  const RecipeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _line(width: 145, height: 14),
                    const SizedBox(height: 10),
                    _line(width: double.infinity, height: 10),
                    const SizedBox(height: 7),
                    _line(width: 110, height: 10),
                    const SizedBox(height: 12),
                    _line(width: 90, height: 9),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class RecipeShimmerList extends StatelessWidget {
  const RecipeShimmerList({this.itemCount = 4, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (_) => const RecipeShimmer()),
    );
  }
}
