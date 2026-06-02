import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../theme/app_colors.dart';
import '../l10n/app_l10n.dart';
import '../widgets/tag_chip.dart';
import '../widgets/snap_app_bar.dart';
import 'lesson_detail_page.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  int _selectedCategory = 0;
  List<Lesson> _lessons = [];
  String? _loadedLang;
  final _searchCtrl = TextEditingController();

  // Derived from loaded lessons — locale-aware
  List<String> get _uniqueTags {
    final tags = _lessons.map((l) => l.tag).toSet().toList()..sort();
    return tags;
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Localizations.localeOf(context).languageCode;
    if (_loadedLang != lang) {
      _loadedLang = lang;
      _selectedCategory = 0;
      Lesson.loadAll(lang).then((list) {
        if (!mounted) return;
        setState(() => _lessons = list);
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Lesson> get _filtered {
    final query = _searchCtrl.text.toLowerCase();
    final tags = _uniqueTags;
    return _lessons.where((l) {
      final matchesCategory =
          _selectedCategory == 0 ||
          (_selectedCategory - 1 < tags.length &&
              l.tag == tags[_selectedCategory - 1]);
      final matchesSearch =
          query.isEmpty ||
          l.name.toLowerCase().contains(query) ||
          l.tag.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    // "All" + unique tags derived from loaded lessons
    final categoryLabels = [l.learnCatAll, ..._uniqueTags];

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: SnapAppBar(title: l.learnTitle),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Real search bar
                  TextField(
                    controller: _searchCtrl,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: l.learnSearch,
                      hintStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: context.colors.textSecondary),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: context.colors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: context.colors.textSecondary,
                                size: 18,
                              ),
                              onPressed: () => _searchCtrl.clear(),
                            )
                          : null,
                      filled: true,
                      fillColor: context.colors.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryLabels.length,
                      separatorBuilder: (_, i) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => setState(() => _selectedCategory = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedCategory == i
                                ? AppColors.primary
                                : context.colors.surface,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            categoryLabels[i],
                            style: TextStyle(
                              color: _selectedCategory == i
                                  ? Colors.white
                                  : context.colors.textSecondary,
                              fontWeight: _selectedCategory == i
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 13,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_lessons.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      color: context.colors.textSecondary,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.learnNoResults,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.learnNoResultsHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final filtered = _filtered;
                  if (i >= filtered.length) return null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LessonCard(
                      lesson: filtered[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonDetailPage(lesson: filtered[i]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, required this.onTap});
  final Lesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        height: 120,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
                child: SizedBox(
                  width: 90,
                  child: Image.asset(
                    lesson.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [lesson.photoColor1, lesson.photoColor2],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_rounded,
                          color: Colors.white24,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TagChip(label: lesson.tag, color: lesson.tagColor),
                      const SizedBox(height: 6),
                      Text(
                        lesson.name,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lesson.level,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: context.colors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
