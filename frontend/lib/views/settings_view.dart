// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../models/reader_settings.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final settings = viewModel.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          iconSize: 28,
          tooltip: 'Go back',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            Text(
              'Customize your reading experience',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.l),

            Text(
              'Reading Preferences',
              style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: AppSpacing.m),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('OpenDyslexic Font', style: AppTextStyles.body),
                    subtitle: Text(
                      'Easier to read for dyslexia',
                      style: AppTextStyles.caption,
                    ),
                    value: settings.useOpenDyslexic,
                    onChanged: viewModel.toggleOpenDyslexic,
                    activeTrackColor: AppColors.primary,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text('Bionic Reading', style: AppTextStyles.body),
                    subtitle: Text(
                      'Bold first letters for faster reading',
                      style: AppTextStyles.caption,
                    ),
                    value: settings.useBionicReading,
                    onChanged: viewModel.toggleBionicReading,
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            Text(
              'Visual Comfort',
              style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: AppSpacing.m),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Font Size',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    _FontSizeSelector(
                      selected: settings.fontSize,
                      onChanged: viewModel.setFontSize,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.m),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Background Color',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    _BackgroundColorSelector(
                      selected: settings.backgroundColor,
                      onChanged: viewModel.setBackgroundColor,
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

class _FontSizeSelector extends StatelessWidget {
  final FontSize selected;
  final Function(FontSize) onChanged;

  const _FontSizeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: FontSize.values.map((size) {
        return RadioListTile<FontSize>(
          title: Text(_getFontSizeLabel(size), style: AppTextStyles.body),
          value: size,
          groupValue: selected,
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  String _getFontSizeLabel(FontSize size) {
    switch (size) {
      case FontSize.small:
        return 'Small (14px)';
      case FontSize.medium:
        return 'Medium (16px)';
      case FontSize.large:
        return 'Large (20px)';
    }
  }
}

class _BackgroundColorSelector extends StatelessWidget {
  final BackgroundColor selected;
  final Function(BackgroundColor) onChanged;

  const _BackgroundColorSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: BackgroundColor.values.map((color) {
        final isSelected = color == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: color != BackgroundColor.values.last ? AppSpacing.s : 0,
            ),
            child: InkWell(
              onTap: () => onChanged(color),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: _getColorFromEnum(color),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 3 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getColorLabel(color),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getColorFromEnum(BackgroundColor color) {
    switch (color) {
      case BackgroundColor.cream:
        return AppColors.background;
      case BackgroundColor.mint:
        return const Color(0xFFF0F8F5);
      case BackgroundColor.softBlue:
        return const Color(0xFFF5F5FF);
    }
  }

  String _getColorLabel(BackgroundColor color) {
    switch (color) {
      case BackgroundColor.cream:
        return 'Cream';
      case BackgroundColor.mint:
        return 'Mint';
      case BackgroundColor.softBlue:
        return 'Soft Blue';
    }
  }
}
