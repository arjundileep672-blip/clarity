import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../viewmodels/task_deconstructor_viewmodel.dart';
import '../viewmodels/audio_input_viewmodel.dart';
import '../viewmodels/photo_input_viewmodel.dart';
import 'dart:io';

class TaskDeconstructorView extends StatelessWidget {
  const TaskDeconstructorView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskDeconstructorViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Break It Down'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
            iconSize: 28,
            tooltip: 'Go back',
          ),
        ),
        body: const SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TaskInputSelector(),
              Expanded(child: _TaskInputContent()),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskInputSelector extends StatelessWidget {
  const _TaskInputSelector();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TaskDeconstructorViewModel>();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _InputTab(
            icon: Icons.keyboard_rounded,
            label: 'Text',
            isSelected: viewModel.selectedInputMethod == InputMethod.text,
            onTap: () => viewModel.setInputMethod(InputMethod.text),
          ),
          const SizedBox(width: AppSpacing.s),
          _InputTab(
            icon: Icons.mic_rounded,
            label: 'Voice',
            isSelected: viewModel.selectedInputMethod == InputMethod.audio,
            onTap: () => viewModel.setInputMethod(InputMethod.audio),
          ),
          const SizedBox(width: AppSpacing.s),
          _InputTab(
            icon: Icons.camera_alt_rounded,
            label: 'Photo',
            isSelected: viewModel.selectedInputMethod == InputMethod.photo,
            onTap: () => viewModel.setInputMethod(InputMethod.photo),
          ),
        ],
      ),
    );
  }
}

class _InputTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InputTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.s),
                Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskInputContent extends StatelessWidget {
  const _TaskInputContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TaskDeconstructorViewModel>();

    switch (viewModel.selectedInputMethod) {
      case InputMethod.text:
        return const _TextInputView();
      case InputMethod.audio:
        return ChangeNotifierProvider.value(
          value: viewModel.audioViewModel,
          child: const _AudioInputView(),
        );
      case InputMethod.photo:
        return ChangeNotifierProvider.value(
          value: viewModel.photoViewModel,
          child: const _PhotoInputView(),
        );
    }
  }
}

class _TextInputView extends StatelessWidget {
  const _TextInputView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TaskDeconstructorViewModel>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              onChanged: viewModel.updateTaskText,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Describe your assignment here...',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton(
            text: 'Analyze Text',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing text...')),
              );
            },
            icon: Icons.auto_awesome_rounded,
          ),
        ],
      ),
    );
  }
}

class _AudioInputView extends StatelessWidget {
  const _AudioInputView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AudioInputViewModel>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: viewModel.isRecording
                    ? AppColors.error
                    : AppColors.primary,
                width: 4,
              ),
            ),
            child: Icon(
              viewModel.isRecording ? Icons.mic : Icons.mic_none_rounded,
              size: 64,
              color: viewModel.isRecording
                  ? AppColors.error
                  : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          if (viewModel.audioFilePath != null) ...[
            Text(
              'Recording Saved',
              style: AppTextStyles.title.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.s),
            TextButton.icon(
              onPressed: viewModel.deleteRecording,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
              label: Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: viewModel.isRecording
                      ? 'Stop Recording'
                      : 'Start Recording',
                  onPressed: viewModel.isRecording
                      ? viewModel.stopRecording
                      : viewModel.startRecording,
                  variant: viewModel.isRecording
                      ? AppButtonVariant.secondary
                      : AppButtonVariant.primary,
                  icon: viewModel.isRecording
                      ? Icons.stop_rounded
                      : Icons.fiber_manual_record_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoInputView extends StatelessWidget {
  const _PhotoInputView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PhotoInputViewModel>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              clipBehavior: Clip.hardEdge,
              child: viewModel.imageFilePath != null
                  ? Image.file(
                      File(viewModel.imageFilePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            'No image selected',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          if (viewModel.imageFilePath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: AppButton(
                text: 'Remove Photo',
                onPressed: viewModel.clearImage,
                variant: AppButtonVariant.text,
                icon: Icons.delete_outline_rounded,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Camera',
                  onPressed: viewModel.takePhoto,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.camera_alt_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: AppButton(
                  text: 'Gallery',
                  onPressed: viewModel.pickImageFromGallery,
                  variant: AppButtonVariant.primary,
                  icon: Icons.photo_library_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
