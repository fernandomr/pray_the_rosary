import 'package:flutter/material.dart';
import 'package:terco_app/domain/mystery_catalog.dart';
import 'package:terco_app/l10n/app_localizations.dart';

class MysterySetList extends StatelessWidget {
  const MysterySetList({
    required this.selectedId,
    required this.onSelect,
    super.key,
  });

  final MysterySetId selectedId;
  final ValueChanged<MysterySetId> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: mysterySets.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 8);
      },
      itemBuilder: (BuildContext context, int index) {
        final MysterySetDefinition set = mysterySets[index];
        return MysterySetTile(
          key: Key('mystery-set-${set.id.name}'),
          set: set,
          isSelected: set.id == selectedId,
          onTap: () => onSelect(set.id),
        );
      },
    );
  }
}

class MysterySetTile extends StatelessWidget {
  const MysterySetTile({
    required this.set,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final MysterySetDefinition set;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: isSelected,
      button: true,
      label: set.name,
      child: Material(
        color: isSelected ? colors.primaryContainer : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        set.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: colors.primary),
                  ],
                ),
                const SizedBox(height: 4),
                Text(set.weekdaysLabel),
                const SizedBox(height: 8),
                for (final MysteryDefinition mystery in set.mysteries)
                  Text(
                    '${mystery.index}. ${mystery.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (isSelected)
                  Text(
                    l10n.selected,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
