import 'dart:math';
import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../l10n/app_l10n.dart';
import '../widgets/tag_chip.dart';
import '../widgets/photo_placeholder.dart';
import '../widgets/snap_app_bar.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage>
    with SingleTickerProviderStateMixin {
  List<_WheelEntry> _entries = [];
  bool _loaded = false;
  String? _loadedLang;
  Color _chasingColor = const Color(0xFFFF6B9D);

  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _spinning = false;
  bool _hasSpun = false;
  int _result = 0;
  double _baseAngle = 0;

  static Color _randomVibrantColor(Random rng) {
    final hue = rng.nextDouble() * 360;
    return HSLColor.fromAHSL(1.0, hue, 0.85, 0.52).toColor();
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _anim = const AlwaysStoppedAnimation(0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Localizations.localeOf(context).languageCode;
    if (_loadedLang != lang) {
      _loadedLang = lang;
      final l = AppL10n.of(context);
      Lesson.loadAll(lang).then((list) {
        if (!mounted) return;
        setState(() {
          _entries = [
            ...list.map(_WheelEntry.fromLesson),
            _WheelEntry.colorChasing(
              name: l.colorChasingName,
              tag: l.colorChasingTag,
              description: l.colorChasingDescription,
            ),
          ];
          _loaded = true;
          _hasSpun = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning || _entries.isEmpty) return;
    SettingsService.recordSpinToday();
    final rng = Random();
    final next = rng.nextInt(_entries.length);
    if (_entries[next].isColorChasing) {
      _chasingColor = _randomVibrantColor(rng);
    }
    _result = next;
    final delta = (6 + rng.nextDouble() * 4) * 2 * pi;
    final from = _baseAngle;
    final to = _baseAngle + delta;
    _anim = Tween<double>(
      begin: from,
      end: to,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    setState(() {
      _spinning = true;
      _hasSpun = true;
    });
    _ctrl
      ..reset()
      ..forward().then((_) {
        _baseAngle = to;
        setState(() => _spinning = false);
      });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: SnapAppBar(title: l.generateTitle, subtitle: l.generateSubtitle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Wheel always centered in expanded area
          Expanded(
            child: Center(
              child: !_loaded
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _Pointer(),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: _spin,
                          child: AnimatedBuilder(
                            animation: _ctrl,
                            builder: (ctx, child) => _Wheel(
                              entries: _entries,
                              angle: _anim.value,
                              spinning: _spinning,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          // Fixed-height area: card appears here, wheel never shifts
          SizedBox(
            height: 190,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _hasSpun && !_spinning && _entries.isNotEmpty
                  ? Padding(
                      key: ValueKey('$_result-$_chasingColor'),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: _ChallengeCard(
                        entry: _entries[_result],
                        chasingColor: _chasingColor,
                      ),
                    )
                  : const SizedBox.expand(key: ValueKey('empty')),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Pointer ──────────────────────────────────────────────────────────────────

class _Pointer extends StatelessWidget {
  const _Pointer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(22, 14), painter: _PointerPainter());
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_PointerPainter old) => false;
}

// ── Wheel ─────────────────────────────────────────────────────────────────────

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.entries,
    required this.angle,
    required this.spinning,
  });

  final List<_WheelEntry> entries;
  final double angle;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: spinning ? 0.35 : 0.15),
            blurRadius: spinning ? 40 : 20,
            spreadRadius: spinning ? 8 : 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _WheelPainter(
          entries: entries,
          angle: angle,
          hubColor: context.colors.background,
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter({
    required this.entries,
    required this.angle,
    required this.hubColor,
  });

  final List<_WheelEntry> entries;
  final double angle;
  final Color hubColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final n = entries.length;
    final sweep = 2 * pi / n;

    for (int i = 0; i < n; i++) {
      final start = angle + i * sweep - pi / 2;
      final color = entries[i].tagColor;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        Paint()..color = color.withValues(alpha: 0.8),
      );

      if (i.isOdd) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          start,
          sweep,
          true,
          Paint()..color = Colors.black.withValues(alpha: 0.12),
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Center hub
    canvas.drawCircle(center, 22, Paint()..color = hubColor);
    canvas.drawCircle(
      center,
      22,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.angle != angle ||
      old.hubColor != hubColor ||
      old.entries.length != entries.length;
}

// ── Challenge card ────────────────────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.entry, required this.chasingColor});
  final _WheelEntry entry;
  final Color chasingColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(
        //   color: entry.tagColor.withValues(alpha: 0.3),
        //   width: 1.5,
        // ),
      ),
      height: 150,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: SizedBox(
                width: 130,
                child: entry.isColorChasing
                    ? _ColorSwatch(color: chasingColor)
                    : Image.asset(
                        entry.lesson!.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => PhotoPlaceholder(
                          width: 130,
                          height: double.infinity,
                          color1: entry.lesson!.photoColor1,
                          color2: entry.lesson!.photoColor2,
                          borderRadius: 0,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TagChip(label: entry.tag, color: entry.tagColor),
                    const SizedBox(height: 6),
                    Text(
                      entry.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.4,
                        color: colors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color});
  final Color color;

  static String _name(Color c, BuildContext ctx) {
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

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final dark = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, dark],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.palette_rounded, color: Colors.white70, size: 24),
          const SizedBox(height: 6),
          Text(
            _name(color, context),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wheel entry (Lesson OR Color Chasing) ─────────────────────────────────────

class _WheelEntry {
  const _WheelEntry._({
    required this.tagColor,
    required this.name,
    required this.tag,
    required this.description,
    required this.isColorChasing,
    this.lesson,
  });

  factory _WheelEntry.fromLesson(Lesson l) => _WheelEntry._(
    tagColor: l.tagColor,
    name: l.name,
    tag: l.tag,
    description: l.shortDescription,
    isColorChasing: false,
    lesson: l,
  );

  factory _WheelEntry.colorChasing({
    required String name,
    required String tag,
    required String description,
  }) => _WheelEntry._(
    tagColor: const Color(0xFFFF6B9D),
    name: name,
    tag: tag,
    description: description,
    isColorChasing: true,
  );

  final Color tagColor;
  final String name;
  final String tag;
  final String description;
  final bool isColorChasing;
  final Lesson? lesson;
}
