import 'package:terco_app/domain/mystery_catalog.dart';
import 'package:terco_app/domain/rosary_sequence.dart';
import 'package:terco_app/domain/rosary_step.dart';

class SavedRosarySession {
  const SavedRosarySession({
    required this.setId,
    required this.stepIndex,
    required this.speed,
    required this.meditationSeconds,
    required this.sessionDate,
  });

  final MysterySetId setId;
  final int stepIndex;
  final double speed;
  final int meditationSeconds;
  final String sessionDate;
}

class RosaryPlayerState {
  const RosaryPlayerState({
    required this.setId,
    required this.steps,
    required this.stepIndex,
    required this.isPlaying,
    required this.isCompleted,
    required this.speed,
    required this.meditationSeconds,
  });

  final MysterySetId setId;
  final List<RosaryStep> steps;
  final int stepIndex;
  final bool isPlaying;
  final bool isCompleted;
  final double speed;
  final int meditationSeconds;

  RosaryStep? get currentStep {
    if (isCompleted || stepIndex < 0 || stepIndex >= steps.length) {
      return null;
    }
    return steps[stepIndex];
  }

  RosaryPlayerState copyWith({
    MysterySetId? setId,
    List<RosaryStep>? steps,
    int? stepIndex,
    bool? isPlaying,
    bool? isCompleted,
    double? speed,
    int? meditationSeconds,
  }) {
    return RosaryPlayerState(
      setId: setId ?? this.setId,
      steps: steps ?? this.steps,
      stepIndex: stepIndex ?? this.stepIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isCompleted: isCompleted ?? this.isCompleted,
      speed: speed ?? this.speed,
      meditationSeconds: meditationSeconds ?? this.meditationSeconds,
    );
  }
}

String sessionDateKey(DateTime date) {
  final DateTime local = date.toLocal();
  final String month = local.month.toString().padLeft(2, '0');
  final String day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

double normalizePlaybackSpeed(double speed) {
  if (playbackSpeeds.contains(speed)) {
    return speed;
  }
  return defaultPlaybackSpeed;
}

int normalizeMeditationSeconds(int seconds) {
  if (meditationSecondOptions.contains(seconds)) {
    return seconds;
  }
  return defaultMeditationSeconds;
}

RosaryPlayerState stateFromSession({
  required DateTime now,
  SavedRosarySession? saved,
}) {
  final String today = sessionDateKey(now);
  final bool resumeToday =
      saved != null && saved.sessionDate == today && saved.stepIndex >= 0;
  final MysterySetId setId = resumeToday
      ? saved.setId
      : mysterySetForWeekday(now.weekday);
  final List<RosaryStep> steps = buildRosarySteps(setId);
  final int requestedIndex = resumeToday ? saved.stepIndex : 0;
  final int stepIndex = requestedIndex >= 0 && requestedIndex < steps.length
      ? requestedIndex
      : 0;
  return RosaryPlayerState(
    setId: setId,
    steps: steps,
    stepIndex: stepIndex,
    isPlaying: false,
    isCompleted: false,
    speed: normalizePlaybackSpeed(saved?.speed ?? defaultPlaybackSpeed),
    meditationSeconds: normalizeMeditationSeconds(
      saved?.meditationSeconds ?? defaultMeditationSeconds,
    ),
  );
}
