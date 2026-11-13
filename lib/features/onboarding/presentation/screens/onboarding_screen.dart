import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onCompleted, super.key});

  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = [
    _OnboardingPageData(
      title: 'La cuisine commence avec une idée.',
      description: 'Découvrez de nouvelles inspirations et explorez un univers de recettes.',
      icon: Icons.restaurant_menu_rounded,
    ),
    _OnboardingPageData(
      title: 'Votre créativité, notre intelligence.',
      description: 'Décrivez vos envies ou vos ingrédients et laissez l’IA imaginer une recette.',
      icon: Icons.auto_awesome_rounded,
    ),
    _OnboardingPageData(
      title: 'Une cuisine qui vous ressemble.',
      description: 'Retrouvez vos recettes préférées et organisez vos inspirations culinaires.',
      icon: Icons.favorite_rounded,
    ),
  ];

  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_currentPage == _pages.length - 1) {
      widget.onCompleted();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onCompleted,
                  child: const Text('Passer'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.lg,
                      ),
                      child: Column(
                        children: [
                          if (index == 0)
                            Image.asset(
                              'assets/images/onboarding.png',
                              height: 240,
                              fit: BoxFit.contain,
                            )
                          else
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.extraLarge,
                                ),
                              ),
                              child: Icon(
                                page.icon,
                                size: 92,
                                color: colors.primary,
                              ),
                            ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final selected = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary
                          : colors.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _continue,
                  child: Text(isLastPage ? 'Commencer' : 'Continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}
