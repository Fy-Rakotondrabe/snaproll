import 'package:flutter/material.dart';
import '../l10n/app_l10n.dart';
import '../theme/app_colors.dart';
import '../widgets/tag_chip.dart';

class ColorChasingDetailPage extends StatelessWidget {
  const ColorChasingDetailPage({
    super.key,
    required this.name,
    required this.tag,
    required this.tagColor,
    required this.description,
    required this.chasingColor,
  });

  final String name;
  final String tag;
  final Color tagColor;
  final String description;
  final Color chasingColor;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    final hsl = HSLColor.fromColor(chasingColor);
    final darkShade = hsl
        .withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0))
        .toColor();
    final colorName = _colorName(chasingColor, context);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: colors.background,
            surfaceTintColor: Colors.transparent,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [chasingColor, darkShade],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    const Icon(
                      Icons.palette_rounded,
                      color: Colors.white70,
                      size: 48,
                    ),
                    // const SizedBox(height: 12),
                    // Text(
                    //   colorName,
                    //   style: const TextStyle(
                    //     color: Colors.white,
                    //     fontFamily: 'SpaceGrotesk',
                    //     fontWeight: FontWeight.w700,
                    //     fontSize: 32,
                    //     shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TagChip(label: tag, color: tagColor),
                  const SizedBox(height: 14),
                  Text(name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: colors.surfaceElevated,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l.lessonDescription,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  _TipRow(color: tagColor, text: l.colorChasingTip1),
                  const SizedBox(height: 10),
                  _TipRow(color: tagColor, text: l.colorChasingTip2),
                  const SizedBox(height: 10),
                  _TipRow(color: tagColor, text: l.colorChasingTip3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _colorName(Color c, BuildContext ctx) {
    final hue = HSLColor.fromColor(c).hue;
    final en = Localizations.localeOf(ctx).languageCode == 'en';
    if (hue < 15 || hue >= 345) return en ? 'Red' : 'Rouge';
    if (hue < 45) return 'Orange';
    if (hue < 75) return en ? 'Yellow' : 'Jaune';
    if (hue < 150) return en ? 'Green' : 'Vert';
    if (hue < 195) return 'Cyan';
    if (hue < 255) return en ? 'Blue' : 'Bleu';
    if (hue < 285) return 'Violet';
    return en ? 'Pink' : 'Rose';
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
