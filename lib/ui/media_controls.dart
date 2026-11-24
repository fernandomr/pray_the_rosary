import 'package:flutter/material.dart';
import 'package:terco_app/domain/step_label.dart';
import 'package:terco_app/l10n/app_localizations.dart';

class MediaControls extends StatelessWidget {
  const MediaControls({
    required this.isPlaying,
    required this.speed,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onCycleSpeed,
    super.key,
  });

  static const double buttonSize = 72;

  final bool isPlaying;
  final double speed;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onCycleSpeed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String speedLabel = formatPlaybackSpeed(speed);
    return SizedBox(
      width: (buttonSize * 2) + 12,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          _ControlButton(
            tooltip: l10n.previous,
            icon: Icons.skip_previous,
            onPressed: onPrevious,
          ),
          _ControlButton(
            key: const Key('play-pause'),
            tooltip: isPlaying ? l10n.pause : l10n.play,
            icon: isPlaying ? Icons.pause : Icons.play_arrow,
            onPressed: onPlayPause,
            filled: true,
          ),
          _ControlButton(
            tooltip: l10n.next,
            icon: Icons.skip_next,
            onPressed: onNext,
          ),
          _ControlButton(
            tooltip: l10n.speed(speedLabel),
            label: speedLabel,
            onPressed: onCycleSpeed,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.label,
    this.filled = false,
    super.key,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = FilledButton.styleFrom(
      minimumSize: const Size(
        MediaControls.buttonSize,
        MediaControls.buttonSize,
      ),
      padding: EdgeInsets.zero,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
    final Widget child = icon == null
        ? Text(label ?? '')
        : Icon(icon, size: 36);
    return Tooltip(
      message: tooltip,
      child: filled
          ? FilledButton(
              style: style,
              onPressed: onPressed,
              child: child,
            )
          : FilledButton.tonal(
              style: style,
              onPressed: onPressed,
              child: child,
            ),
    );
  }
}
