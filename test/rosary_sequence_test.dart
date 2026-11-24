import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:terco_app/domain/mystery_catalog.dart';
import 'package:terco_app/domain/rosary_sequence.dart';
import 'package:terco_app/domain/rosary_session.dart';
import 'package:terco_app/domain/rosary_step.dart';

void main() {
  test('weekday selects the traditional mystery set', () {
    expect(mysterySetForWeekday(DateTime.monday), MysterySetId.joyful);
    expect(mysterySetForWeekday(DateTime.saturday), MysterySetId.joyful);
    expect(mysterySetForWeekday(DateTime.tuesday), MysterySetId.sorrowful);
    expect(mysterySetForWeekday(DateTime.friday), MysterySetId.sorrowful);
    expect(mysterySetForWeekday(DateTime.wednesday), MysterySetId.glorious);
    expect(mysterySetForWeekday(DateTime.sunday), MysterySetId.glorious);
    expect(mysterySetForWeekday(DateTime.thursday), MysterySetId.luminous);
  });

  test('sequence has the fixed opening, decades, and closing', () {
    final List<RosaryStep> steps = buildRosarySteps(MysterySetId.joyful);
    expect(steps, hasLength(rosaryStepCount));
    expect(rosaryStepCount, 79);

    expect(
      steps.take(openingStepCount).map((RosaryStep step) => step.kind).toList(),
      <RosaryStepKind>[
        RosaryStepKind.signOfTheCross,
        RosaryStepKind.creed,
        RosaryStepKind.ourFather,
        RosaryStepKind.hailMary,
        RosaryStepKind.hailMary,
        RosaryStepKind.hailMary,
        RosaryStepKind.gloryBe,
      ],
    );

    for (int decade = 0; decade < mysteryCount; decade++) {
      final int start = openingStepCount + (decade * decadeStepCount);
      final List<RosaryStep> decadeSteps = steps.sublist(
        start,
        start + decadeStepCount,
      );
      expect(decadeSteps.first.kind, RosaryStepKind.mystery);
      expect(decadeSteps.first.mysteryIndex, decade + 1);
      expect(decadeSteps[1].kind, RosaryStepKind.meditation);
      expect(decadeSteps[1].assetPath, isNull);
      expect(decadeSteps[2].kind, RosaryStepKind.ourFather);
      expect(
        decadeSteps.where((RosaryStep step) => step.kind == RosaryStepKind.hailMary),
        hasLength(10),
      );
      expect(decadeSteps.last.kind, RosaryStepKind.gloryBe);
    }

    expect(steps[steps.length - 2].kind, RosaryStepKind.hailHolyQueen);
    expect(steps.last.kind, RosaryStepKind.signOfTheCross);
    expect(
      steps.last.assetPath,
      prayerAssetPath(PrayerId.signOfTheCross),
    );
  });

  test('hail mary repeats share one asset and stay distinct steps', () {
    final List<RosaryStep> steps = buildRosarySteps(MysterySetId.sorrowful);
    final List<RosaryStep> openingHails = steps
        .where(
          (RosaryStep step) =>
              step.kind == RosaryStepKind.hailMary && step.mysteryIndex == null,
        )
        .toList();
    expect(openingHails, hasLength(3));
    expect(
      openingHails.map((RosaryStep step) => step.assetPath).toSet(),
      <String?>{prayerAssetPath(PrayerId.hailMary)},
    );
    expect(openingHails[0].hailMaryIndex, 1);
    expect(openingHails[2].hailMaryIndex, 3);
    expect(identical(openingHails[0], openingHails[1]), isFalse);

    final List<RosaryStep> decadeHails = steps
        .where(
          (RosaryStep step) =>
              step.kind == RosaryStepKind.hailMary && step.mysteryIndex == 1,
        )
        .toList();
    expect(decadeHails, hasLength(10));
    expect(decadeHails.first.assetPath, openingHails.first.assetPath);
    expect(decadeHails[3].hailMaryIndex, 4);
    expect(decadeHails[3].hailMaryTotal, 10);
  });

  test('every audio step points at a file in media_src', () {
    for (final MysterySetId setId in MysterySetId.values) {
      final List<RosaryStep> steps = buildRosarySteps(setId);
      for (final RosaryStep step in steps) {
        final String? assetPath = step.assetPath;
        if (assetPath == null) {
          expect(step.kind, RosaryStepKind.meditation);
          continue;
        }
        expect(
          File(assetPath).existsSync(),
          isTrue,
          reason: assetPath,
        );
      }
    }
  });

  test('same-day session resumes and a new day follows the weekday', () {
    final DateTime monday = DateTime(2026, 11, 23);
    final RosaryPlayerState fresh = stateFromSession(now: monday);
    expect(fresh.setId, MysterySetId.joyful);
    expect(fresh.stepIndex, 0);
    expect(fresh.speed, defaultPlaybackSpeed);
    expect(fresh.meditationSeconds, defaultMeditationSeconds);

    const SavedRosarySession saved = SavedRosarySession(
      setId: MysterySetId.luminous,
      stepIndex: 12,
      speed: 1.5,
      meditationSeconds: 30,
      sessionDate: '2026-11-23',
    );
    final RosaryPlayerState resumed = stateFromSession(
      now: monday,
      saved: saved,
    );
    expect(resumed.setId, MysterySetId.luminous);
    expect(resumed.stepIndex, 12);
    expect(resumed.speed, 1.5);
    expect(resumed.meditationSeconds, 30);

    final RosaryPlayerState tuesday = stateFromSession(
      now: DateTime(2026, 11, 24),
      saved: saved,
    );
    expect(tuesday.setId, MysterySetId.sorrowful);
    expect(tuesday.stepIndex, 0);
    expect(tuesday.speed, 1.5);
    expect(tuesday.meditationSeconds, 30);
  });
}
