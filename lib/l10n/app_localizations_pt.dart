// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Rezar o Terço';

  @override
  String get play => 'Reproduzir';

  @override
  String get pause => 'Pausar';

  @override
  String get next => 'Seguinte';

  @override
  String get previous => 'Anterior';

  @override
  String speed(String speed) {
    return 'Velocidade $speed';
  }

  @override
  String get meditation => 'Meditação';

  @override
  String meditationDuration(int seconds) {
    return 'Meditação: $seconds s';
  }

  @override
  String get finished => 'Terço concluído';

  @override
  String get signOfTheCross => 'Sinal da Cruz';

  @override
  String get creed => 'Credo';

  @override
  String get ourFather => 'Pai Nosso';

  @override
  String hailMaryProgress(int current, int total) {
    return 'Ave Maria $current de $total';
  }

  @override
  String get gloryBe => 'Glória';

  @override
  String get hailHolyQueen => 'Salve Rainha';

  @override
  String get selected => 'Selecionado';
}
