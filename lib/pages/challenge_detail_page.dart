import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/tag_chip.dart';
import '../widgets/photo_placeholder.dart';

class ChallengeDetailPage extends StatelessWidget {
  const ChallengeDetailPage({
    super.key,
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tips,
    required this.color1,
    required this.color2,
  });

  final String tag;
  final Color tagColor;
  final String title;
  final String subtitle;
  final String description;
  final List<String> tips;
  final Color color1;
  final Color color2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: colors.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: colors.textPrimary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share_outlined, color: colors.textSecondary),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: PhotoPlaceholder(
                width: double.infinity,
                height: double.infinity,
                color1: color1,
                color2: color2,
                borderRadius: 0,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [color1, color2],
                        ),
                      ),
                    ),
                    const Center(
                      child:
                          Icon(Icons.image_rounded, color: Colors.white24, size: 56),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [colors.background, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                TagChip(label: tag, color: tagColor),
                const SizedBox(height: 12),
                Text(title, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  style:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 28),
                _Section(
                  title: 'Conseils',
                  colors: colors,
                  child: Column(
                    children: tips
                        .map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: tagColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: colors.textSecondary,
                                            height: 1.5,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Exemples',
                  colors: colors,
                  child: SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      separatorBuilder: (_, i) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => PhotoPlaceholder(
                        width: 100,
                        height: 100,
                        color1: Color.lerp(color1, color2, i * 0.25)!,
                        color2: color2,
                        borderRadius: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Marquer comme terminé'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    required this.colors,
  });

  final String title;
  final Widget child;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: colors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}
