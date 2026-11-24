import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:terco_app/app.dart';
import 'package:terco_app/data/settings_repository.dart';
import 'package:terco_app/domain/rosary_session.dart';
import 'package:terco_app/player/rosary_audio_handler.dart';
import 'package:terco_app/player/rosary_player_controller.dart';
import 'package:terco_app/ui/terco_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SettingsRepository settings = SettingsRepository();
  final SavedRosarySession? saved = await settings.load();
  final RosaryPlayerState initialState = stateFromSession(
    now: DateTime.now(),
    saved: saved,
  );
  final RosaryAudioHandler handler = await AudioService.init(
    builder: () => RosaryAudioHandler(
      settings: settings,
      initialState: initialState,
    ),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.afd.rezarterco.terco_app.audio',
      androidNotificationChannelName: 'Rezar o Terço',
      androidNotificationChannelDescription: 'Reprodução do terço',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: false,
      androidNotificationIcon: 'drawable/ic_notification',
      notificationColor: tercoSeedColor,
    ),
  );
  await handler.configureAudioSession();
  runApp(TercoApp(controller: RosaryPlayerController(handler)));
}
