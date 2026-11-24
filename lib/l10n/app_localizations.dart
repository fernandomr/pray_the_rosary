import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Rezar o Terço'**
  String get appTitle;

  /// No description provided for @play.
  ///
  /// In pt, this message translates to:
  /// **'Reproduzir'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In pt, this message translates to:
  /// **'Pausar'**
  String get pause;

  /// No description provided for @next.
  ///
  /// In pt, this message translates to:
  /// **'Seguinte'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In pt, this message translates to:
  /// **'Anterior'**
  String get previous;

  /// No description provided for @speed.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade {speed}'**
  String speed(String speed);

  /// No description provided for @meditation.
  ///
  /// In pt, this message translates to:
  /// **'Meditação'**
  String get meditation;

  /// No description provided for @meditationDuration.
  ///
  /// In pt, this message translates to:
  /// **'Meditação: {seconds} s'**
  String meditationDuration(int seconds);

  /// No description provided for @finished.
  ///
  /// In pt, this message translates to:
  /// **'Terço concluído'**
  String get finished;

  /// No description provided for @signOfTheCross.
  ///
  /// In pt, this message translates to:
  /// **'Sinal da Cruz'**
  String get signOfTheCross;

  /// No description provided for @creed.
  ///
  /// In pt, this message translates to:
  /// **'Credo'**
  String get creed;

  /// No description provided for @ourFather.
  ///
  /// In pt, this message translates to:
  /// **'Pai Nosso'**
  String get ourFather;

  /// No description provided for @hailMaryProgress.
  ///
  /// In pt, this message translates to:
  /// **'Ave Maria {current} de {total}'**
  String hailMaryProgress(int current, int total);

  /// No description provided for @gloryBe.
  ///
  /// In pt, this message translates to:
  /// **'Glória'**
  String get gloryBe;

  /// No description provided for @hailHolyQueen.
  ///
  /// In pt, this message translates to:
  /// **'Salve Rainha'**
  String get hailHolyQueen;

  /// No description provided for @selected.
  ///
  /// In pt, this message translates to:
  /// **'Selecionado'**
  String get selected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
