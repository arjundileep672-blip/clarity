import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../widgets/bionic_text.dart';
import '../widgets/primary_button.dart';

class SensoryOutputView extends StatelessWidget {
  final String text;

  const SensoryOutputView({super.key, required this.text});

  Color _getBackgroundColor(String backgroundColorName) {
    switch (backgroundColorName) {
      case 'cream':
        return AppColors.background;
      case 'mint':
        return const Color(0xFFF0F8F5);
      case 'softBlue':
        return const Color(0xFFF5F5FF);
      default:
        return AppColors.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    final settings = settingsViewModel.settings;

    // Fallback if text is empty
    final displayText = text.trim().isEmpty ? 'No text to read.' : text;

    final textStyle = TextStyle(
      fontSize: settings.fontSize.toPixels(),
      height: 1.8,
      color: AppColors.textPrimary,
    );

    return Scaffold(
      backgroundColor: _getBackgroundColor(settings.backgroundColor.name),
      appBar: AppBar(
        title: const Text('Reader Mode'),
        backgroundColor: _getBackgroundColor(settings.backgroundColor.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          iconSize: 28,
          tooltip: 'Go back',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: settings.useBionicReading
                    ? BionicText(displayText, style: textStyle)
                    : Text(displayText, style: textStyle),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: AppButton(
                text: 'Read Aloud',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Text-to-speech coming soon!',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      ),
                      backgroundColor: AppColors.secondary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMedium,
                        ),
                      ),
                    ),
                  );
                },
                icon: Icons.volume_up_rounded,
                variant: AppButtonVariant.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
