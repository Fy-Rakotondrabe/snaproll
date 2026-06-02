import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppL10n {
  const AppL10n(this.locale);
  final Locale locale;

  static AppL10n of(BuildContext context) =>
      Localizations.of<AppL10n>(context, AppL10n) ?? const AppL10n(Locale('fr'));

  static const delegate = _AppL10nDelegate();
  static const supportedLocales = [Locale('fr'), Locale('en')];

  String _t(String fr, String en) =>
      locale.languageCode == 'en' ? en : fr;

  // Navigation
  String get navGenerate => _t('Défi', 'Challenge');
  String get navProgress => _t('Progression', 'Progress');
  String get navLearn => _t('Leçons', 'Lessons');
  String get navSettings => _t('Paramètres', 'Settings');

  // Generate page
  String get generateTitle => _t('Défi', 'Challenge');
  String get generateSubtitle => _t('Appuie sur la roue pour découvrir ton défi', 'Press the wheel to discover your challenge');
  String get generateSpinning => _t('La roue tourne...', 'Spinning...');
  String get generateSpinAgain => _t('Appuie à nouveau pour un nouveau défi', 'Spin again for a new challenge');

  // Color Chasing challenge (wheel-only, not in lessons)
  String get colorChasingName => 'Color Chasing';
  String get colorChasingTag => _t('COULEUR', 'COLOR');
  String get colorChasingDescription => _t(
    'Pars à la chasse à la couleur ! Cherche un sujet ou un environnement dominé par une seule couleur vive. Laisse cette couleur guider toute ta composition.',
    'Hunt down a color! Find a subject or environment dominated by one vivid hue. Let that color drive your entire composition.',
  );

  // Progress page
  String get progressTitle => _t('Progression', 'Progress');
  String get progressSubtitle => _t('Ton parcours photographique', 'Your photography journey');
  String get progressStreakLabel => _t('Série quotidienne', 'Daily streak');
  String get progressStreakUnit => _t('jours', 'days');
  String get progressStreakMotivation => _t('Continue comme ça !', 'Keep it up!');
  String get progressRecord => _t('Record', 'Record');
  String get progressMostDone => _t('DÉFI LE PLUS FAIT', 'MOST DONE CHALLENGE');
  String get progressThisWeek => _t('CETTE SEMAINE', 'THIS WEEK');
  String get progressTimes => _t('fois', 'times');

  // Learn page
  String get learnTitle => _t('Leçons', 'Lessons');
  String get learnSearch => _t('Rechercher une leçon...', 'Search a lesson...');
  String get learnNoResults => _t('Aucun résultat', 'No results');
  String get learnNoResultsHint => _t('Essaie un autre mot-clé', 'Try another keyword');
  String get learnCatAll => _t('Toutes', 'All');
  String get learnCatColor => _t('Couleur', 'Color');
  String get learnCatLight => _t('Lumière', 'Light');
  String get learnCatFocal => _t('Focale', 'Focal');

  // Lesson detail
  String get lessonDescription => _t('Description', 'Description');
  String get lessonStart => _t('Commencer la leçon', 'Start lesson');

  // Settings page
  String get settingsTitle => _t('Paramètres', 'Settings');
  String get settingsAppearance => _t('APPARENCE', 'APPEARANCE');
  String get settingsDarkMode => _t('Mode sombre', 'Dark mode');
  String get settingsLanguage => _t('LANGUE', 'LANGUAGE');
  String get settingsNotifications => _t('NOTIFICATIONS', 'NOTIFICATIONS');
  String get settingsNotifDaily => _t('Rappel quotidien', 'Daily reminder');
  String get settingsNotifTime => _t('Heure du rappel', 'Reminder time');
  String get settingsApp => _t('APPLICATION', 'APPLICATION');
  String get settingsVersion => _t('Version', 'Version');
  String get settingsRate => _t("Noter l'app", 'Rate app');
  String get settingsNotifBody => _t('Lance la roue et relève ton défi photo !', 'Spin the wheel and take on your photo challenge!');
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppL10n.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppL10n> load(Locale locale) =>
      SynchronousFuture(AppL10n(locale));

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}
