import 'package:flutter/material.dart';
import 'package:terco_app/domain/rosary_session.dart';
import 'package:terco_app/domain/rosary_step.dart';
import 'package:terco_app/l10n/app_localizations.dart';

class BeadProgress extends StatelessWidget {
  const BeadProgress({required this.state, super.key});

  final RosaryPlayerState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final RosaryStep? step = state.currentStep;
    final String label = labelForStep(step, l10n, isCompleted: state.isCompleted);
    final String? detail = _detailFor(step, label);
    final int? activeIndex = _highlightedStepIndex(state);
    final List<_BeadGroup> groups = _beadGroups(state.steps);
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (detail != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        for (final _BeadGroup group in groups) ...<Widget>[
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: <Widget>[
              for (final _BeadEntry entry in group.entries)
                _BeadDot(
                  step: entry.step,
                  isActive: entry.stepIndex == activeIndex,
                  activeColor: colors.primary,
                  idleColor: colors.outlineVariant,
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  String? _detailFor(RosaryStep? step, String label) {
    if (step == null || step.mysteryTitle == null) {
      return null;
    }
    if (step.kind == RosaryStepKind.mystery || step.mysteryTitle == label) {
      return null;
    }
    return step.mysteryTitle;
  }
}

String labelForStep(
  RosaryStep? step,
  AppLocalizations l10n, {
  required bool isCompleted,
}) {
  if (isCompleted || step == null) {
    return l10n.finished;
  }
  switch (step.kind) {
    case RosaryStepKind.signOfTheCross:
      return l10n.signOfTheCross;
    case RosaryStepKind.creed:
      return l10n.creed;
    case RosaryStepKind.ourFather:
      return l10n.ourFather;
    case RosaryStepKind.hailMary:
      return l10n.hailMaryProgress(
        step.hailMaryIndex ?? 1,
        step.hailMaryTotal ?? 1,
      );
    case RosaryStepKind.gloryBe:
      return l10n.gloryBe;
    case RosaryStepKind.hailHolyQueen:
      return l10n.hailHolyQueen;
    case RosaryStepKind.mystery:
      return step.mysteryTitle ?? l10n.meditation;
    case RosaryStepKind.meditation:
      return l10n.meditation;
  }
}

int? _highlightedStepIndex(RosaryPlayerState state) {
  if (state.isCompleted || state.currentStep == null) {
    return null;
  }
  if (state.currentStep!.kind == RosaryStepKind.meditation) {
    return state.stepIndex - 1;
  }
  return state.stepIndex;
}

List<_BeadGroup> _beadGroups(List<RosaryStep> steps) {
  final List<_BeadEntry> opening = <_BeadEntry>[];
  final List<_BeadGroup> decades = <_BeadGroup>[];
  final List<_BeadEntry> closing = <_BeadEntry>[];
  List<_BeadEntry>? decade;
  bool seenMystery = false;
  bool inClosing = false;

  for (int index = 0; index < steps.length; index++) {
    final RosaryStep step = steps[index];
    if (step.kind == RosaryStepKind.meditation) {
      continue;
    }
    if (step.kind == RosaryStepKind.mystery) {
      if (decade != null) {
        decades.add(_BeadGroup(decade));
      }
      seenMystery = true;
      decade = <_BeadEntry>[_BeadEntry(index, step)];
      continue;
    }
    if (!seenMystery) {
      opening.add(_BeadEntry(index, step));
      continue;
    }
    if (step.kind == RosaryStepKind.hailHolyQueen) {
      inClosing = true;
    }
    if (inClosing) {
      if (decade != null) {
        decades.add(_BeadGroup(decade));
        decade = null;
      }
      closing.add(_BeadEntry(index, step));
      continue;
    }
    decade?.add(_BeadEntry(index, step));
  }

  return <_BeadGroup>[
    if (opening.isNotEmpty) _BeadGroup(opening),
    ...decades,
    if (closing.isNotEmpty) _BeadGroup(closing),
  ];
}

class _BeadGroup {
  const _BeadGroup(this.entries);

  final List<_BeadEntry> entries;
}

class _BeadEntry {
  const _BeadEntry(this.stepIndex, this.step);

  final int stepIndex;
  final RosaryStep step;
}

class _BeadDot extends StatelessWidget {
  const _BeadDot({
    required this.step,
    required this.isActive,
    required this.activeColor,
    required this.idleColor,
  });

  final RosaryStep step;
  final bool isActive;
  final Color activeColor;
  final Color idleColor;

  @override
  Widget build(BuildContext context) {
    final double size = _sizeFor(step.kind) + (isActive ? 4 : 0);
    final Color color = isActive ? activeColor : idleColor;
    final BoxDecoration decoration = step.kind == RosaryStepKind.mystery
        ? BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          )
        : BoxDecoration(color: color, shape: BoxShape.circle);
    return Container(width: size, height: size, decoration: decoration);
  }

  double _sizeFor(RosaryStepKind kind) {
    switch (kind) {
      case RosaryStepKind.ourFather:
        return 12;
      case RosaryStepKind.hailMary:
        return 8;
      case RosaryStepKind.mystery:
        return 10;
      case RosaryStepKind.signOfTheCross:
      case RosaryStepKind.creed:
      case RosaryStepKind.gloryBe:
      case RosaryStepKind.hailHolyQueen:
      case RosaryStepKind.meditation:
        return 10;
    }
  }
}
