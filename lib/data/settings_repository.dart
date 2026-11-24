import 'package:shared_preferences/shared_preferences.dart';
import 'package:terco_app/domain/mystery_catalog.dart';
import 'package:terco_app/domain/rosary_session.dart';

class SettingsRepository {
  static const String speedKey = 'playback_speed';
  static const String meditationKey = 'meditation_seconds';
  static const String setKey = 'set_id';
  static const String stepKey = 'step_index';
  static const String dateKey = 'session_date';

  Future<SavedRosarySession?> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final double speed = preferences.getDouble(speedKey) ?? defaultPlaybackSpeed;
    final int meditationSeconds =
        preferences.getInt(meditationKey) ?? defaultMeditationSeconds;
    final String? setName = preferences.getString(setKey);
    final int? stepIndex = preferences.getInt(stepKey);
    final String? sessionDate = preferences.getString(dateKey);
    if (setName == null || stepIndex == null || sessionDate == null) {
      if (!preferences.containsKey(speedKey) &&
          !preferences.containsKey(meditationKey)) {
        return null;
      }
      return SavedRosarySession(
        setId: MysterySetId.joyful,
        stepIndex: -1,
        speed: speed,
        meditationSeconds: meditationSeconds,
        sessionDate: '',
      );
    }
    final MysterySetId? setId = _setIdFromName(setName);
    if (setId == null) {
      return null;
    }
    return SavedRosarySession(
      setId: setId,
      stepIndex: stepIndex,
      speed: speed,
      meditationSeconds: meditationSeconds,
      sessionDate: sessionDate,
    );
  }

  Future<void> save(RosaryPlayerState state, DateTime now) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(speedKey, state.speed);
    await preferences.setInt(meditationKey, state.meditationSeconds);
    await preferences.setString(setKey, state.setId.name);
    await preferences.setInt(stepKey, state.stepIndex);
    await preferences.setString(dateKey, sessionDateKey(now));
  }

  MysterySetId? _setIdFromName(String name) {
    for (final MysterySetId id in MysterySetId.values) {
      if (id.name == name) {
        return id;
      }
    }
    return null;
  }
}
