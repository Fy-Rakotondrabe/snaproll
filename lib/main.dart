import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'l10n/app_l10n.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'pages/generate_page.dart';
import 'pages/progress_page.dart';
import 'pages/learn_page.dart';
import 'pages/settings_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final _themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);
final _localeNotifier = ValueNotifier<Locale>(const Locale('fr'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Timezone init
  tz_data.initializeTimeZones();
  try {
    final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
    final String tzName = tzResult is String ? tzResult : tzResult.toString();
    tz.setLocalLocation(tz.getLocation(tzName));
  } catch (_) {
    tz.setLocalLocation(tz.UTC);
  }

  // Notifications
  await NotificationService.instance.init();

  // Load persisted settings
  final savedLang = await SettingsService.getLanguage();
  _localeNotifier.value = Locale(savedLang);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SnaprollApp());
}

class SnaprollApp extends StatelessWidget {
  const SnaprollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (ctx, mode, child) => ValueListenableBuilder<Locale>(
        valueListenable: _localeNotifier,
        builder: (ctx2, locale, child2) => MaterialApp(
          title: 'Snaproll',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: locale,
          supportedLocales: AppL10n.supportedLocales,
          localizationsDelegates: const [
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: RootPage(
            themeNotifier: _themeNotifier,
            localeNotifier: _localeNotifier,
          ),
        ),
      ),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({
    super.key,
    required this.themeNotifier,
    required this.localeNotifier,
  });
  final ValueNotifier<ThemeMode> themeNotifier;
  final ValueNotifier<Locale> localeNotifier;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const GeneratePage(),
    const ProgressPage(),
    const LearnPage(),
    SettingsPage(
      themeNotifier: widget.themeNotifier,
      localeNotifier: widget.localeNotifier,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final navItems = [
      _NavItem(icon: Icons.casino_rounded, label: l.navGenerate),
      _NavItem(icon: Icons.bar_chart_rounded, label: l.navProgress),
      _NavItem(icon: Icons.menu_book_rounded, label: l.navLearn),
      _NavItem(icon: Icons.settings_rounded, label: l.navSettings),
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _BottomNav(
        items: navItems,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.surfaceElevated, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final isActive = e.key == currentIndex;
              return GestureDetector(
                onTap: () => onTap(e.key),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          e.value.icon,
                          color: isActive
                              ? AppColors.primary
                              : colors.textSecondary,
                          size: 20,
                        ),
                      ),
                      Text(
                        e.value.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive
                              ? AppColors.primary
                              : colors.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
