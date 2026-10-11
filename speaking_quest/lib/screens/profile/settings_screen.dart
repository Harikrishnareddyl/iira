import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Settings: appearance (light/dark), voice and accent (all free), speaking
/// speed, quiet mode, captions, daily goal, reminders, translation language.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _accent = 'American';
  double _speed = 1;
  bool _quiet = false, _captions = true, _reminder = true;
  int _minutes = 10;
  String _lang = 'Spanish';

  @override
  Widget build(BuildContext context) {
    final c = context.sq;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SqTopBar(title: 'Settings'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  const SectionLabel('Appearance'),
                  ValueListenableBuilder(
                    valueListenable: themeMode,
                    builder: (context, mode, _) => SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.surfaceGreen : c.surface),
                        side: WidgetStateProperty.all(BorderSide(color: c.border)),
                      ),
                      segments: const [
                        ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_rounded)),
                        ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_rounded)),
                        ButtonSegment(value: ThemeMode.system, label: Text('System')),
                      ],
                      selected: {mode},
                      onSelectionChanged: (s) => themeMode.value = s.first,
                    ),
                  ),
                  const SectionLabel('Voices'),
                  SqCard(
                    color: c.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Accent', style: context.text.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final a in ['American', 'British', 'Australian', 'Indian', 'Irish', 'Mixed'])
                              ChoiceChip(
                                label: Text(a),
                                selected: _accent == a,
                                selectedColor: c.surfaceGreen,
                                backgroundColor: c.surfaceWarm,
                                side: BorderSide(color: c.border),
                                showCheckmark: false,
                                onSelected: (_) => setState(() => _accent = a),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Every accent and voice is free.', style: context.text.bodySmall),
                        const SizedBox(height: 14),
                        Text('Speaking speed', style: context.text.titleMedium),
                        Slider(
                          value: _speed,
                          min: 0.75,
                          max: 1.25,
                          divisions: 2,
                          activeColor: c.green,
                          label: _speed == 1 ? 'Natural' : (_speed < 1 ? 'Slower' : 'Faster'),
                          onChanged: (v) => setState(() => _speed = v),
                        ),
                      ],
                    ),
                  ),
                  const SectionLabel('Practice'),
                  SqCard(
                    color: c.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _quiet,
                          onChanged: (v) => setState(() => _quiet = v),
                          title: Text('Quiet mode', style: context.text.titleMedium),
                          subtitle: Text('Fewer speaking-only levels when you can\'t talk out loud', style: context.text.bodySmall),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _captions,
                          onChanged: (v) => setState(() => _captions = v),
                          title: Text('Live captions', style: context.text.titleMedium),
                          subtitle: Text('See how you were heard', style: context.text.bodySmall),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Daily goal', style: context.text.titleMedium),
                          trailing: DropdownButton<int>(
                            value: _minutes,
                            underline: const SizedBox.shrink(),
                            items: [5, 10, 15, 20].map((m) => DropdownMenuItem(value: m, child: Text('$m min'))).toList(),
                            onChanged: (v) => setState(() => _minutes = v!),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Translate into', style: context.text.titleMedium),
                          trailing: DropdownButton<String>(
                            value: _lang,
                            underline: const SizedBox.shrink(),
                            items: ['Spanish', 'Portuguese', 'Hindi', 'Arabic', 'Japanese', 'Turkish']
                                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                .toList(),
                            onChanged: (v) => setState(() => _lang = v!),
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _reminder,
                          onChanged: (v) => setState(() => _reminder = v),
                          title: Text('Daily reminder', style: context.text.titleMedium),
                          subtitle: Text('8:30 pm', style: context.text.bodySmall),
                        ),
                      ],
                    ),
                  ),
                  const SectionLabel('Account'),
                  RowCard(title: 'Redo placement', subtitle: 'Measure your skills again', leading: IconBlob(icon: Icons.route_rounded, color: c.surfaceGreen), onTap: () => demoNav(context, 'Onboarding')),
                  const SizedBox(height: 8),
                  RowCard(title: 'Privacy & recordings', subtitle: 'Manage saved audio', leading: IconBlob(icon: Icons.lock_outline_rounded, color: c.surfaceGreen), onTap: () => demoNav(context, 'Privacy')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
