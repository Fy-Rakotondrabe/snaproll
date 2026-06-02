import 'package:flutter/material.dart';

import '../l10n/app_l10n.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/snap_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.themeNotifier,
    required this.localeNotifier,
  });
  final ValueNotifier<ThemeMode> themeNotifier;
  final ValueNotifier<Locale> localeNotifier;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifEnabled = false;
  TimeOfDay _notifTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await SettingsService.getNotifEnabled();
    final time = await SettingsService.getNotifTime();
    setState(() {
      _notifEnabled = enabled;
      _notifTime = time;
    });
  }

  Future<void> _toggleNotif(bool v) async {
    setState(() => _notifEnabled = v);
    await SettingsService.setNotifEnabled(v);
    if (v) {
      final granted = await NotificationService.instance.requestPermission();
      if (!mounted) return;
      if (!granted) {
        setState(() => _notifEnabled = false);
        await SettingsService.setNotifEnabled(false);
        return;
      }
      final l = AppL10n.of(context);
      await NotificationService.instance.scheduleDailyAt(
        _notifTime,
        title: 'Snaproll',
        body: l.settingsNotifBody,
      );
    } else {
      await NotificationService.instance.cancel();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notifTime,
    );
    if (!mounted || picked == null) return;
    final notifBody = AppL10n.of(context).settingsNotifBody;
    setState(() => _notifTime = picked);
    await SettingsService.setNotifTime(picked);
    if (_notifEnabled) {
      await NotificationService.instance.scheduleDailyAt(
        picked,
        title: 'Snaproll',
        body: notifBody,
      );
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour}h${t.minute.toString().padLeft(2, '0')}';

  void _setLanguage(String code) {
    widget.localeNotifier.value = Locale(code);
    SettingsService.setLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    final isDark = widget.themeNotifier.value == ThemeMode.dark;
    final currentLang = widget.localeNotifier.value.languageCode;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: SnapAppBar(title: l.settingsTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language
            _SectionLabel(l.settingsLanguage, colors),
            _Card(
              colors: colors,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _LangChip(
                      flag: '🇫🇷',
                      label: 'Français',
                      selected: currentLang == 'fr',
                      colors: colors,
                      onTap: () => _setLanguage('fr'),
                    ),
                    const SizedBox(width: 10),
                    _LangChip(
                      flag: '🇬🇧',
                      label: 'English',
                      selected: currentLang == 'en',
                      colors: colors,
                      onTap: () => _setLanguage('en'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Appearance
            _SectionLabel(l.settingsAppearance, colors),
            _Card(
              colors: colors,
              child: _ToggleRow(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF9B59B6),
                label: l.settingsDarkMode,
                value: isDark,
                colors: colors,
                onChanged: (v) => setState(
                  () => widget.themeNotifier.value =
                      v ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Notifications
            _SectionLabel(l.settingsNotifications, colors),
            _Card(
              colors: colors,
              child: Column(
                children: [
                  _ToggleRow(
                    icon: Icons.notifications_rounded,
                    iconColor: AppColors.primary,
                    label: l.settingsNotifDaily,
                    value: _notifEnabled,
                    colors: colors,
                    onChanged: _toggleNotif,
                  ),
                  if (_notifEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 66),
                      child: Divider(height: 1, color: colors.surfaceElevated),
                    ),
                    _TapRow(
                      icon: Icons.access_time_rounded,
                      iconColor: AppColors.primary,
                      label: l.settingsNotifTime,
                      value: _formatTime(_notifTime),
                      colors: colors,
                      onTap: _pickTime,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // App info
            _SectionLabel(l.settingsApp, colors),
            _Card(
              colors: colors,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.info_outline_rounded,
                    iconColor: colors.textSecondary,
                    label: l.settingsVersion,
                    value: '1.0.0',
                    colors: colors,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 66),
                    child: Divider(height: 1, color: colors.surfaceElevated),
                  ),
                  _TapRow(
                    icon: Icons.star_outline_rounded,
                    iconColor: AppColors.premium,
                    label: l.settingsRate,
                    value: '',
                    colors: colors,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.colors);
  final String text;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: colors.textSecondary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.colors, required this.child});
  final AppColorsExtension colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.surfaceElevated),
      ),
      child: child,
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.flag,
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });
  final String flag;
  final String label;
  final bool selected;
  final AppColorsExtension colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
                color:
                    selected ? AppColors.primary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.colors,
    required this.onChanged,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final AppColorsExtension colors;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconBox(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: colors.textPrimary,
                )),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _TapRow extends StatelessWidget {
  const _TapRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final AppColorsExtension colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _IconBox(icon: icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: colors.textPrimary,
                  )),
            ),
            if (value.isNotEmpty)
              Text(value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: colors.textSecondary,
                  )),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: colors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.colors,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconBox(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: colors.textPrimary,
                )),
          ),
          Text(value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: colors.textSecondary,
              )),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
