import 'package:flutter/material.dart';
import 'package:terco_app/l10n/app_localizations.dart';
import 'package:terco_app/player/rosary_player_controller.dart';
import 'package:terco_app/ui/home_page.dart';
import 'package:terco_app/ui/terco_theme.dart';

class TercoApp extends StatelessWidget {
  const TercoApp({required this.controller, super.key});

  final RosaryPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) {
        return AppLocalizations.of(context).appTitle;
      },
      theme: tercoLightTheme(),
      darkTheme: tercoDarkTheme(),
      themeMode: ThemeMode.system,
      locale: const Locale('pt'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: RosaryHome(controller: controller),
    );
  }
}

class RosaryHome extends StatelessWidget {
  const RosaryHome({required this.controller, super.key});

  final RosaryPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        return HomePage(
          state: controller.state,
          onPlayPause: controller.togglePlay,
          onNext: controller.next,
          onPrevious: controller.previous,
          onCycleSpeed: controller.cycleSpeed,
          onMeditationSeconds: controller.setMeditationSeconds,
          onSelectSet: controller.selectSet,
        );
      },
    );
  }
}
