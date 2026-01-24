import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../viewmodels/sensory_reader_viewmodel.dart';
import '../viewmodels/audio_input_viewmodel.dart';
import '../viewmodels/photo_input_viewmodel.dart';
import 'sensory_output_view.dart';

class SensoryReaderView extends StatelessWidget {
  const SensoryReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SensoryReaderViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Read Safely'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
            iconSize: 28,
            tooltip: 'Go back',
          ),
        ),
        body: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.m),
            child: _SensoryReaderContent(),
          ),
        ),
      ),
    );
  }
}

class _SensoryReaderContent extends StatelessWidget {
  const _SensoryReaderContent();

  @override
  Widget build(BuildContext context) {
    // Only listening to text changes here
    final viewModel = context.watch<SensoryReaderViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Paste text below to enter Reader Mode',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.l),

        TextField(
          maxLines: 12,
          minLines: 8,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Paste your text here…',
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: viewModel.updateText,
        ),

        const SizedBox(height: AppSpacing.xl),

        AppButton(
          text: 'Open Reader Mode',
          onPressed: () {
            if (viewModel.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please enter some text first',
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SensoryOutputView(text: viewModel.text),
              ),
            );
          },
          icon: Icons.auto_stories_rounded,
          variant: AppButtonVariant.primary,
        ),

        const SizedBox(height: AppSpacing.l),
        const Divider(),
        const SizedBox(height: AppSpacing.l),

        Text('Alternate Inputs', style: AppTextStyles.title),

        const SizedBox(height: AppSpacing.m),

        ChangeNotifierProvider.value(
          value: viewModel.audioViewModel,
          child: Builder(
            builder: (context) {
              final audioVM = context.watch<AudioInputViewModel>();
              return AppButton(
                text: audioVM.isRecording
                    ? 'Stop Recording'
                    : 'Record Audio Note',
                onPressed: audioVM.isRecording
                    ? audioVM.stopRecording
                    : audioVM.startRecording,
                variant: audioVM.isRecording
                    ? AppButtonVariant.secondary
                    : AppButtonVariant.secondary,
                icon: audioVM.isRecording
                    ? Icons.stop_rounded
                    : Icons.mic_rounded,
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.m),

        ChangeNotifierProvider.value(
          value: viewModel.photoViewModel,
          child: Builder(
            builder: (context) {
              final photoVM = context.watch<PhotoInputViewModel>();
              return AppButton(
                text: photoVM.imageFilePath != null
                    ? 'Retake Photo'
                    : 'Capture Text',
                onPressed: photoVM.takePhoto,
                variant: AppButtonVariant.secondary,
                icon: Icons.camera_alt_rounded,
              );
            },
          ),
        ),
      ],
    );
  }
}
