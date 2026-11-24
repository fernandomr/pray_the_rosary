import 'package:terco_app/domain/mystery_catalog.dart';

enum RosaryStepKind {
  signOfTheCross,
  creed,
  ourFather,
  hailMary,
  gloryBe,
  hailHolyQueen,
  mystery,
  meditation,
}

class RosaryStep {
  const RosaryStep({
    required this.kind,
    required this.setId,
    this.assetPath,
    this.hailMaryIndex,
    this.hailMaryTotal,
    this.mysteryIndex,
    this.mysteryTitle,
  });

  final RosaryStepKind kind;
  final MysterySetId setId;
  final String? assetPath;
  final int? hailMaryIndex;
  final int? hailMaryTotal;
  final int? mysteryIndex;
  final String? mysteryTitle;
}

const int openingStepCount = 7;
const int decadeStepCount = 14;
const int closingStepCount = 2;
const int mysteryCount = 5;
const int rosaryStepCount =
    openingStepCount + (decadeStepCount * mysteryCount) + closingStepCount;
