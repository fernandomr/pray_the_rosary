import 'package:terco_app/domain/mystery_catalog.dart';
import 'package:terco_app/domain/rosary_step.dart';

List<RosaryStep> buildRosarySteps(MysterySetId setId) {
  final MysterySetDefinition set = mysterySetById(setId);
  final List<RosaryStep> steps = <RosaryStep>[
    _prayerStep(setId, RosaryStepKind.signOfTheCross),
    _prayerStep(setId, RosaryStepKind.creed),
    _prayerStep(setId, RosaryStepKind.ourFather),
    for (int index = 1; index <= 3; index++)
      _hailMaryStep(setId, index: index, total: 3),
    _prayerStep(setId, RosaryStepKind.gloryBe),
  ];

  for (final MysteryDefinition mystery in set.mysteries) {
    steps
      ..add(
        RosaryStep(
          kind: RosaryStepKind.mystery,
          setId: setId,
          assetPath: mystery.assetPath,
          mysteryIndex: mystery.index,
          mysteryTitle: mystery.title,
        ),
      )
      ..add(
        RosaryStep(
          kind: RosaryStepKind.meditation,
          setId: setId,
          mysteryIndex: mystery.index,
          mysteryTitle: mystery.title,
        ),
      )
      ..add(
        _prayerStep(
          setId,
          RosaryStepKind.ourFather,
          mysteryIndex: mystery.index,
          mysteryTitle: mystery.title,
        ),
      );
    for (int index = 1; index <= 10; index++) {
      steps.add(
        _hailMaryStep(
          setId,
          index: index,
          total: 10,
          mysteryIndex: mystery.index,
          mysteryTitle: mystery.title,
        ),
      );
    }
    steps.add(
      _prayerStep(
        setId,
        RosaryStepKind.gloryBe,
        mysteryIndex: mystery.index,
        mysteryTitle: mystery.title,
      ),
    );
  }

  steps
    ..add(_prayerStep(setId, RosaryStepKind.hailHolyQueen))
    ..add(_prayerStep(setId, RosaryStepKind.signOfTheCross));
  return steps;
}

RosaryStep _prayerStep(
  MysterySetId setId,
  RosaryStepKind kind, {
  int? mysteryIndex,
  String? mysteryTitle,
}) {
  return RosaryStep(
    kind: kind,
    setId: setId,
    assetPath: prayerAssetPath(_prayerIdFor(kind)),
    mysteryIndex: mysteryIndex,
    mysteryTitle: mysteryTitle,
  );
}

RosaryStep _hailMaryStep(
  MysterySetId setId, {
  required int index,
  required int total,
  int? mysteryIndex,
  String? mysteryTitle,
}) {
  return RosaryStep(
    kind: RosaryStepKind.hailMary,
    setId: setId,
    assetPath: prayerAssetPath(PrayerId.hailMary),
    hailMaryIndex: index,
    hailMaryTotal: total,
    mysteryIndex: mysteryIndex,
    mysteryTitle: mysteryTitle,
  );
}

PrayerId _prayerIdFor(RosaryStepKind kind) {
  switch (kind) {
    case RosaryStepKind.signOfTheCross:
      return PrayerId.signOfTheCross;
    case RosaryStepKind.creed:
      return PrayerId.creed;
    case RosaryStepKind.ourFather:
      return PrayerId.ourFather;
    case RosaryStepKind.gloryBe:
      return PrayerId.gloryBe;
    case RosaryStepKind.hailHolyQueen:
      return PrayerId.hailHolyQueen;
    case RosaryStepKind.hailMary:
      return PrayerId.hailMary;
    case RosaryStepKind.mystery:
    case RosaryStepKind.meditation:
      throw ArgumentError('$kind has no shared prayer audio');
  }
}
