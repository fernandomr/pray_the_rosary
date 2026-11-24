import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:terco_app/data/settings_repository.dart';
import 'package:terco_app/domain/mystery_catalog.dart';
import 'package:terco_app/domain/rosary_sequence.dart';
import 'package:terco_app/domain/rosary_session.dart';
import 'package:terco_app/domain/rosary_step.dart';
import 'package:terco_app/domain/step_label.dart';

class RosaryAudioHandler extends BaseAudioHandler {
  RosaryAudioHandler({
    required SettingsRepository settings,
    required RosaryPlayerState initialState,
    DateTime Function()? clock,
    AudioPlayer? player,
  }) : _settings = settings,
       _clock = clock ?? DateTime.now,
       _player = player ?? AudioPlayer(),
       _state = initialState,
       playerState = ValueNotifier<RosaryPlayerState>(initialState) {
    _playerStateSubscription = _player.playerStateStream.listen(
      _handlePlayerState,
    );
  }

  final SettingsRepository _settings;
  final DateTime Function() _clock;
  final AudioPlayer _player;
  final ValueNotifier<RosaryPlayerState> playerState;

  RosaryPlayerState _state;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  StreamSubscription<void>? _noisySubscription;
  Timer? _meditationTimer;
  DateTime? _meditationEndsAt;
  Duration? _meditationRemaining;
  int _playGeneration = 0;
  int? _loadedGeneration;
  int? _preparedIndex;
  bool _advancing = false;
  bool _hasActivatedService = false;

  Future<void> configureAudioSession() async {
    final AudioSession session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _interruptionSubscription = session.interruptionEventStream.listen((
      AudioInterruptionEvent event,
    ) {
      if (event.begin && event.type != AudioInterruptionType.duck) {
        pause();
      }
    });
    _noisySubscription = session.becomingNoisyEventStream.listen((_) {
      pause();
    });
  }

  @override
  Future<void> play() async {
    _hasActivatedService = true;
    if (_state.isCompleted) {
      _emit(
        _state.copyWith(stepIndex: 0, isCompleted: false, isPlaying: true),
      );
      await _startCurrentStep();
      return;
    }
    final RosaryStep? step = _state.currentStep;
    _emit(_state.copyWith(isPlaying: true, isCompleted: false));
    if (step?.kind == RosaryStepKind.meditation) {
      final Duration remaining =
          _meditationRemaining ?? Duration(seconds: _state.meditationSeconds);
      if (remaining <= Duration.zero) {
        await _advanceFrom(_playGeneration);
        return;
      }
      await _activateSession();
      _armMeditation(_playGeneration, remaining);
      _publishPlayback();
      return;
    }
    if (_preparedIndex == _state.stepIndex && _canResumeCurrentAudio()) {
      await _player.play();
      _publishPlayback();
      return;
    }
    await _startCurrentStep();
  }

  @override
  Future<void> pause() async {
    if (!_state.isPlaying) {
      return;
    }
    final RosaryStep? step = _state.currentStep;
    if (step?.kind == RosaryStepKind.meditation) {
      _freezeMeditation();
    } else {
      await _player.pause();
    }
    _emit(_state.copyWith(isPlaying: false));
  }

  @override
  Future<void> skipToNext() async {
    if (_state.isPlaying) {
      _hasActivatedService = true;
    }
    final int nextIndex = _state.stepIndex + 1;
    if (nextIndex >= _state.steps.length) {
      await _finish();
      return;
    }
    await _moveTo(nextIndex);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_state.isPlaying) {
      _hasActivatedService = true;
    }
    if (_state.isCompleted) {
      _emit(
        _state.copyWith(
          isCompleted: false,
          stepIndex: _state.steps.length - 1,
        ),
      );
      await _restartCurrent();
      return;
    }
    if (_state.stepIndex <= 0) {
      await _restartCurrent();
      return;
    }
    await _moveTo(_state.stepIndex - 1);
  }

  @override
  Future<void> seek(Duration position) async {
    if (_state.currentStep?.kind == RosaryStepKind.meditation) {
      return;
    }
    await _player.seek(position);
    _publishPlayback();
  }

  @override
  Future<void> stop() async {
    _cancelMeditationTimer();
    _playGeneration++;
    await _player.stop();
    _preparedIndex = null;
    _emit(_state.copyWith(isPlaying: false));
    await super.stop();
  }

  Future<void> selectSet(MysterySetId setId) async {
    if (setId == _state.setId && !_state.isCompleted) {
      return;
    }
    final bool wasPlaying = _state.isPlaying;
    if (wasPlaying) {
      _hasActivatedService = true;
    }
    _cancelMeditationTimer();
    _meditationRemaining = null;
    _playGeneration++;
    await _player.stop();
    _preparedIndex = null;
    _emit(
      RosaryPlayerState(
        setId: setId,
        steps: buildRosarySteps(setId),
        stepIndex: 0,
        isPlaying: wasPlaying,
        isCompleted: false,
        speed: _state.speed,
        meditationSeconds: _state.meditationSeconds,
      ),
    );
    if (wasPlaying) {
      await _startCurrentStep();
    }
  }

  Future<void> updateSpeed(double speed) async {
    if (!playbackSpeeds.contains(speed)) {
      return;
    }
    _emit(_state.copyWith(speed: speed));
    if (_preparedIndex == _state.stepIndex &&
        _state.currentStep?.kind != RosaryStepKind.meditation) {
      await _player.setSpeed(speed);
    }
  }

  Future<void> updateMeditationSeconds(int seconds) async {
    if (!meditationSecondOptions.contains(seconds)) {
      return;
    }
    _emit(_state.copyWith(meditationSeconds: seconds));
    if (_state.currentStep?.kind != RosaryStepKind.meditation) {
      return;
    }
    _cancelMeditationTimer();
    _meditationRemaining = Duration(seconds: seconds);
    if (!_state.isPlaying) {
      _publishPlayback();
      return;
    }
    if (seconds == 0) {
      await _advanceFrom(_playGeneration);
      return;
    }
    _armMeditation(_playGeneration, _meditationRemaining!);
    _publishPlayback();
  }

  Future<void> disposeHandler() async {
    _cancelMeditationTimer();
    await _playerStateSubscription?.cancel();
    await _interruptionSubscription?.cancel();
    await _noisySubscription?.cancel();
    playerState.dispose();
    await _player.dispose();
  }

  Future<void> _startCurrentStep() async {
    final int generation = ++_playGeneration;
    _cancelMeditationTimer();
    _meditationRemaining = null;
    _loadedGeneration = null;
    while (generation == _playGeneration) {
      final RosaryStep step = _state.steps[_state.stepIndex];
      if (step.kind == RosaryStepKind.meditation &&
          _state.meditationSeconds == 0 &&
          _state.isPlaying) {
        final bool moved = _moveIndexForward();
        if (!moved) {
          await _finish();
          return;
        }
        continue;
      }
      if (step.kind == RosaryStepKind.meditation) {
        await _player.stop();
        _preparedIndex = null;
        _meditationRemaining = Duration(seconds: _state.meditationSeconds);
        if (!_state.isPlaying) {
          _publishPlayback();
          return;
        }
        await _activateSession();
        _armMeditation(generation, _meditationRemaining!);
        _publishPlayback();
        return;
      }
      final String? assetPath = step.assetPath;
      if (assetPath == null) {
        _emit(_state.copyWith(isPlaying: false));
        return;
      }
      try {
        await _player.setAudioSource(AudioSource.asset(assetPath));
        if (generation != _playGeneration) {
          return;
        }
        await _player.setSpeed(_state.speed);
        _preparedIndex = _state.stepIndex;
        _loadedGeneration = generation;
        if (_state.isPlaying) {
          await _player.play();
        }
        _publishPlayback();
      } catch (error, stackTrace) {
        debugPrint('Unable to play $assetPath: $error\n$stackTrace');
        if (generation == _playGeneration) {
          _emit(_state.copyWith(isPlaying: false));
        }
      }
      return;
    }
  }

  Future<void> _moveTo(int index) async {
    _cancelMeditationTimer();
    _meditationRemaining = null;
    _playGeneration++;
    final bool playing = _state.isPlaying;
    _emit(
      _state.copyWith(stepIndex: index, isCompleted: false, isPlaying: playing),
    );
    if (playing) {
      await _startCurrentStep();
      return;
    }
    await _player.stop();
    _preparedIndex = null;
    if (_state.steps[index].kind == RosaryStepKind.meditation) {
      _meditationRemaining = Duration(seconds: _state.meditationSeconds);
    }
    _publishPlayback();
  }

  Future<void> _restartCurrent() async {
    final RosaryStep? step = _state.currentStep;
    _emit(_state.copyWith(isCompleted: false));
    if (step?.kind == RosaryStepKind.meditation) {
      _cancelMeditationTimer();
      _meditationRemaining = Duration(seconds: _state.meditationSeconds);
      if (_state.isPlaying) {
        _armMeditation(_playGeneration, _meditationRemaining!);
      }
      _publishPlayback();
      return;
    }
    if (_preparedIndex == _state.stepIndex && _canResumeCurrentAudio()) {
      await _player.seek(Duration.zero);
      if (_state.isPlaying) {
        await _player.play();
      }
      _publishPlayback();
      return;
    }
    if (_state.isPlaying) {
      await _startCurrentStep();
    }
  }

  Future<void> _advanceFrom(int generation) async {
    if (_advancing || generation != _playGeneration) {
      return;
    }
    _advancing = true;
    try {
      final bool moved = _moveIndexForward();
      if (!moved) {
        await _finish();
        return;
      }
      await _startCurrentStep();
    } finally {
      _advancing = false;
    }
  }

  bool _moveIndexForward() {
    final int nextIndex = _state.stepIndex + 1;
    if (nextIndex >= _state.steps.length) {
      return false;
    }
    _emit(_state.copyWith(stepIndex: nextIndex, isCompleted: false));
    return true;
  }

  Future<void> _finish() async {
    _cancelMeditationTimer();
    _meditationRemaining = null;
    _playGeneration++;
    await _player.stop();
    _preparedIndex = null;
    _hasActivatedService = true;
    _emit(
      _state.copyWith(
        isPlaying: false,
        isCompleted: true,
        stepIndex: _state.steps.length - 1,
      ),
    );
  }

  void _armMeditation(int generation, Duration remaining) {
    _cancelMeditationTimer();
    _meditationRemaining = remaining;
    _meditationEndsAt = _clock().add(remaining);
    _meditationTimer = Timer(remaining, () {
      _meditationRemaining = Duration.zero;
      _meditationEndsAt = null;
      _advanceFrom(generation);
    });
  }

  void _freezeMeditation() {
    final DateTime? endsAt = _meditationEndsAt;
    _cancelMeditationTimer();
    if (endsAt == null) {
      return;
    }
    final Duration remaining = endsAt.difference(_clock());
    _meditationRemaining = remaining.isNegative ? Duration.zero : remaining;
  }

  void _cancelMeditationTimer() {
    _meditationTimer?.cancel();
    _meditationTimer = null;
    _meditationEndsAt = null;
  }

  bool _canResumeCurrentAudio() {
    final ProcessingState processingState = _player.processingState;
    return processingState != ProcessingState.idle &&
        processingState != ProcessingState.completed;
  }

  void _handlePlayerState(PlayerState playerState) {
    if (playerState.processingState != ProcessingState.completed ||
        _loadedGeneration != _playGeneration ||
        !_state.isPlaying ||
        _state.currentStep?.kind == RosaryStepKind.meditation) {
      return;
    }
    _advanceFrom(_playGeneration);
  }

  Future<void> _activateSession() async {
    final AudioSession session = await AudioSession.instance;
    await session.setActive(true);
  }

  void _emit(RosaryPlayerState next) {
    _state = next;
    playerState.value = next;
    _publishPlayback();
    _persist();
  }

  void _publishPlayback() {
    if (!_hasActivatedService) {
      return;
    }
    final RosaryStep? step = _state.isCompleted ? null : _state.currentStep;
    final bool isMeditation = step?.kind == RosaryStepKind.meditation;
    final Duration position = isMeditation
        ? _meditationPosition()
        : _player.position;
    final Duration duration = isMeditation
        ? Duration(seconds: _state.meditationSeconds)
        : (_player.duration ?? Duration.zero);
    mediaItem.add(
      MediaItem(
        id: '${_state.setId.name}-${_state.stepIndex}',
        album: mysterySetById(_state.setId).name,
        title: portugueseStepLabel(step, isCompleted: _state.isCompleted),
        artist: step?.mysteryTitle,
        duration: duration,
      ),
    );
    playbackState.add(
      PlaybackState(
        processingState: _state.isCompleted
            ? AudioProcessingState.completed
            : AudioProcessingState.ready,
        playing: _state.isPlaying,
        controls: <MediaControl>[
          const MediaControl(
            androidIcon: 'drawable/audio_service_skip_previous',
            label: 'Anterior',
            action: MediaAction.skipToPrevious,
          ),
          _state.isPlaying
              ? const MediaControl(
                  androidIcon: 'drawable/audio_service_pause',
                  label: 'Pausar',
                  action: MediaAction.pause,
                )
              : const MediaControl(
                  androidIcon: 'drawable/audio_service_play_arrow',
                  label: 'Reproduzir',
                  action: MediaAction.play,
                ),
          const MediaControl(
            androidIcon: 'drawable/audio_service_skip_next',
            label: 'Seguinte',
            action: MediaAction.skipToNext,
          ),
        ],
        androidCompactActionIndices: const <int>[0, 1, 2],
        systemActions: const <MediaAction>{MediaAction.seek},
        updatePosition: position,
        bufferedPosition: isMeditation
            ? Duration.zero
            : _player.bufferedPosition,
        speed: isMeditation ? 1 : _state.speed,
        queueIndex: _state.stepIndex,
      ),
    );
  }

  Duration _meditationPosition() {
    final Duration total = Duration(seconds: _state.meditationSeconds);
    if (_meditationEndsAt != null && _state.isPlaying) {
      final Duration remaining = _meditationEndsAt!.difference(_clock());
      final Duration clamped = remaining.isNegative
          ? Duration.zero
          : remaining;
      final Duration elapsed = total - clamped;
      return elapsed.isNegative ? Duration.zero : elapsed;
    }
    final Duration? remaining = _meditationRemaining;
    if (remaining == null) {
      return Duration.zero;
    }
    final Duration elapsed = total - remaining;
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  void _persist() {
    _settings.save(_state, _clock()).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      debugPrint('Unable to save rosary session: $error\n$stackTrace');
    });
  }
}
