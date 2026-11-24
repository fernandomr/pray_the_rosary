import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terco_app/domain/mystery_catalog.dart';
import 'package:terco_app/domain/rosary_session.dart';
import 'package:terco_app/l10n/app_localizations.dart';
import 'package:terco_app/ui/home_page.dart';
import 'package:terco_app/ui/mystery_set_list.dart';

void main() {
  testWidgets('weekday mystery set is selected on the home screen', (
    WidgetTester tester,
  ) async {
    final RosaryPlayerState state = stateFromSession(
      now: DateTime(2026, 11, 23),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomePage(
          state: state,
          onPlayPause: () {},
          onNext: () {},
          onPrevious: () {},
          onCycleSpeed: () {},
          onMeditationSeconds: (_) {},
          onSelectSet: (_) {},
        ),
      ),
    );

    final MysterySetTile joyful = tester.widget<MysterySetTile>(
      find.byKey(const Key('mystery-set-joyful')),
    );
    expect(joyful.isSelected, isTrue);
    expect(state.setId, MysterySetId.joyful);

    await tester.scrollUntilVisible(
      find.byKey(const Key('mystery-set-luminous')),
      300,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    final MysterySetTile luminous = tester.widget<MysterySetTile>(
      find.byKey(const Key('mystery-set-luminous')),
    );
    expect(luminous.isSelected, isFalse);
  });
}
