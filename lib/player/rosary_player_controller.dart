import 'package:flutter/foundation.dart';
import 'package:terco_app/domain/mystery_catalog.dart';
import 'package:terco_app/domain/rosary_session.dart';
import 'package:terco_app/player/rosary_audio_handler.dart';

class RosaryPlayerController extends ChangeNotifier {
  RosaryPlayerController(this._handler) {
    _handler.playerState.addListener(notifyListeners);
  }

  final RosaryAudioHandler _handler;

  RosaryPlayerState get state => _handler.playerState.value;

  Future<void> togglePlay() {
    if (state.isPlaying) {
      return _handler.pause();
    }
    return _handler.play();
  }

  Future<void> next() => _handler.skipToNext();

  Future<void> previous() => _handler.skipToPrevious();

  Future<void> cycleSpeed() {
    final int index = playbackSpeeds.indexOf(state.speed);
    final int nextIndex = index < 0 ? 0 : (index + 1) % playbackSpeeds.length;
    return _handler.updateSpeed(playbackSpeeds[nextIndex]);
  }

  Future<void> setMeditationSeconds(int seconds) {
    return _handler.updateMeditationSeconds(seconds);
  }

  Future<void> selectSet(MysterySetId setId) => _handler.selectSet(setId);

  @override
  void dispose() {
    _handler.playerState.removeListener(notifyListeners);
    super.dispose();
  }
}
