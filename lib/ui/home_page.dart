import 'package:flutter/material.dart';
import 'package:terco_app/domain/mystery_catalog.dart';
import 'package:terco_app/domain/rosary_session.dart';
import 'package:terco_app/l10n/app_localizations.dart';
import 'package:terco_app/ui/bead_progress.dart';
import 'package:terco_app/ui/media_controls.dart';
import 'package:terco_app/ui/mystery_set_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.state,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onCycleSpeed,
    required this.onMeditationSeconds,
    required this.onSelectSet,
    super.key,
  });

  final RosaryPlayerState state;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onCycleSpeed;
  final ValueChanged<int> onMeditationSeconds;
  final ValueChanged<MysterySetId> onSelectSet;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SizedBox(
                height: 248,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MediaControls(
                      isPlaying: state.isPlaying,
                      speed: state.speed,
                      onPlayPause: onPlayPause,
                      onNext: onNext,
                      onPrevious: onPrevious,
                      onCycleSpeed: onCycleSpeed,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: BeadProgress(state: state),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MeditationControl(
              seconds: state.meditationSeconds,
              onChanged: onMeditationSeconds,
            ),
            const Divider(height: 1),
            Expanded(
              child: MysterySetList(
                selectedId: state.setId,
                onSelect: onSelectSet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MeditationControl extends StatelessWidget {
  const MeditationControl({
    required this.seconds,
    required this.onChanged,
    super.key,
  });

  final int seconds;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int index = meditationSecondOptions.indexOf(seconds);
    final int safeIndex = index < 0
        ? meditationSecondOptions.indexOf(defaultMeditationSeconds)
        : index;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(l10n.meditationDuration(meditationSecondOptions[safeIndex])),
          ),
          Expanded(
            flex: 3,
            child: Slider(
              value: safeIndex.toDouble(),
              min: 0,
              max: (meditationSecondOptions.length - 1).toDouble(),
              divisions: meditationSecondOptions.length - 1,
              label: l10n.meditationDuration(meditationSecondOptions[safeIndex]),
              onChanged: (double value) {
                onChanged(meditationSecondOptions[value.round()]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
