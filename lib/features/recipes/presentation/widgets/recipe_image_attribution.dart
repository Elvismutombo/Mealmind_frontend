import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class RecipeImageAttribution extends StatelessWidget {
  const RecipeImageAttribution({
    required this.photographer,
    required this.sourceUrl,
    super.key,
  });

  final String? photographer;
  final String? sourceUrl;

  @override
  Widget build(BuildContext context) {
    final name = photographer?.trim();
    final uri = Uri.tryParse(sourceUrl ?? '');
    if (name == null ||
        name.isEmpty ||
        uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'www.pexels.com') {
      return const SizedBox.shrink();
    }

    return Link(
      uri: uri,
      builder: (context, followLink) => TextButton(
        onPressed: followLink,
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          minimumSize: const Size(0, 30),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Photo par $name sur Pexels',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
