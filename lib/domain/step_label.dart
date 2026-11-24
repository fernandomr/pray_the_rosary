import 'package:terco_app/domain/rosary_step.dart';

String portugueseStepLabel(RosaryStep? step, {required bool isCompleted}) {
  if (isCompleted || step == null) {
    return 'Terço concluído';
  }
  switch (step.kind) {
    case RosaryStepKind.signOfTheCross:
      return 'Sinal da Cruz';
    case RosaryStepKind.creed:
      return 'Credo';
    case RosaryStepKind.ourFather:
      return 'Pai Nosso';
    case RosaryStepKind.hailMary:
      return 'Ave Maria ${step.hailMaryIndex ?? 1} de ${step.hailMaryTotal ?? 1}';
    case RosaryStepKind.gloryBe:
      return 'Glória';
    case RosaryStepKind.hailHolyQueen:
      return 'Salve Rainha';
    case RosaryStepKind.mystery:
      return step.mysteryTitle ?? 'Mistério';
    case RosaryStepKind.meditation:
      return 'Meditação';
  }
}

String formatPlaybackSpeed(double speed) {
  if (speed == speed.truncateToDouble()) {
    return '${speed.toStringAsFixed(0)}x';
  }
  return '${speed}x';
}
