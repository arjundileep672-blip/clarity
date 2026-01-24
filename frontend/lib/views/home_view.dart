import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/panic_button.dart';
import 'task_deconstructor_view.dart';
import 'panic_view.dart';
import 'sensory_reader_view.dart';
import 'socratic_buddy_view.dart';
import 'settings_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clarity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
            iconSize: 28,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Text(
                'What do you want help with today?',
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
            ),

            // Scrollable content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingHorizontal,
                ),
                children: [
                  const SizedBox(height: AppSpacing.m),

                  // Break Down a Task
                  AppCard(
                    icon: Icons.checklist_rounded,
                    title: 'Break Down a Task',
                    description:
                        'Turn big assignments into small, manageable steps',
                    iconColor: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TaskDeconstructorView(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.m),

                  // Read Safely
                  AppCard(
                    icon: Icons.auto_stories_rounded,
                    title: 'Read Safely',
                    description:
                        'Sensory-friendly reading with customizable settings',
                    iconColor: AppColors.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SensoryReaderView(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.m),

                  // Ask a Tutor
                  AppCard(
                    icon: Icons.chat_rounded,
                    title: 'Socratic Buddy',
                    description:
                        'Get step-by-step help through guided questions',
                    iconColor: AppColors.accent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SocraticBuddyView(),
                        ),
                      );
                    },
                  ),

                  // Bottom spacing to prevent overlap with panic button
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),

            // Panic button (fixed at bottom)
            PanicButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PanicView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
