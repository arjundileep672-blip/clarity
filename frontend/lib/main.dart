import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'views/home_view.dart';
import 'viewmodels/settings_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsViewModel = SettingsViewModel();
  await settingsViewModel.loadSettings();

  runApp(ClarityApp(settingsViewModel: settingsViewModel));
}

class ClarityApp extends StatelessWidget {
  final SettingsViewModel settingsViewModel;

  const ClarityApp({super.key, required this.settingsViewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: settingsViewModel,
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Clarity',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(
              fontFamily: settings.useOpenDyslexic
                  ? 'OpenDyslexic'
                  : settings.useBionicReading
                      ? 'AtkinsonHyperlegible'
                      : null,
            ),
            home: const HomeView(),
          );
        },
      ),
    );
  }
}
