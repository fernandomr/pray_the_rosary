enum MysterySetId {
  joyful,
  sorrowful,
  glorious,
  luminous,
}

enum PrayerId {
  signOfTheCross,
  creed,
  ourFather,
  hailMary,
  gloryBe,
  hailHolyQueen,
}

const String audioLanguageCode = 'pt';

const List<double> playbackSpeeds = <double>[0.5, 0.75, 1, 1.25, 1.5, 2];

const List<int> meditationSecondOptions = <int>[0, 5, 10, 15, 20, 30, 45, 60];

const double defaultPlaybackSpeed = 1;

const int defaultMeditationSeconds = 15;

const String signOfTheCrossFileName = 'sinal_da_cruz.mp3';
const String creedFileName = 'credo.mp3';
const String ourFatherFileName = 'pai_nosso.mp3';
const String hailMaryFileName = 'ave_maria.mp3';
const String gloryBeFileName = 'gloria.mp3';
const String hailHolyQueenFileName = 'salve_rainha.mp3';

class MysteryDefinition {
  const MysteryDefinition({
    required this.index,
    required this.title,
    required this.fileName,
  });

  final int index;
  final String title;
  final String fileName;

  String get assetPath => audioAssetPath(fileName);
}

class MysterySetDefinition {
  const MysterySetDefinition({
    required this.id,
    required this.name,
    required this.weekdaysLabel,
    required this.mysteries,
  });

  final MysterySetId id;
  final String name;
  final String weekdaysLabel;
  final List<MysteryDefinition> mysteries;
}

String audioAssetPath(String fileName) {
  return 'media_src/$audioLanguageCode/$fileName';
}

String prayerFileName(PrayerId prayerId) {
  switch (prayerId) {
    case PrayerId.signOfTheCross:
      return signOfTheCrossFileName;
    case PrayerId.creed:
      return creedFileName;
    case PrayerId.ourFather:
      return ourFatherFileName;
    case PrayerId.hailMary:
      return hailMaryFileName;
    case PrayerId.gloryBe:
      return gloryBeFileName;
    case PrayerId.hailHolyQueen:
      return hailHolyQueenFileName;
  }
}

String prayerAssetPath(PrayerId prayerId) {
  return audioAssetPath(prayerFileName(prayerId));
}

const List<MysterySetDefinition> mysterySets = <MysterySetDefinition>[
  MysterySetDefinition(
    id: MysterySetId.joyful,
    name: 'Mistérios Gozosos',
    weekdaysLabel: 'Segundas-feiras e sábados',
    mysteries: <MysteryDefinition>[
      MysteryDefinition(
        index: 1,
        title: 'Anunciação a Maria',
        fileName: 'gozoso_1_anunciacao.mp3',
      ),
      MysteryDefinition(
        index: 2,
        title: 'Visitação de Nossa Senhora a sua prima Isabel',
        fileName: 'gozoso_2_visitacao.mp3',
      ),
      MysteryDefinition(
        index: 3,
        title: 'Nascimento de Jesus',
        fileName: 'gozoso_3_nascimento.mp3',
      ),
      MysteryDefinition(
        index: 4,
        title: 'Apresentação do Menino Jesus no Templo',
        fileName: 'gozoso_4_apresentacao.mp3',
      ),
      MysteryDefinition(
        index: 5,
        title: 'Perda e encontro do Menino Jesus no Templo',
        fileName: 'gozoso_5_perda_encontro.mp3',
      ),
    ],
  ),
  MysterySetDefinition(
    id: MysterySetId.sorrowful,
    name: 'Mistérios Dolorosos',
    weekdaysLabel: 'Terças e sextas-feiras',
    mysteries: <MysteryDefinition>[
      MysteryDefinition(
        index: 1,
        title: 'Agonia de Jesus no Horto',
        fileName: 'doloroso_1_agonia.mp3',
      ),
      MysteryDefinition(
        index: 2,
        title: 'Flagelação de Jesus',
        fileName: 'doloroso_2_flagelacao.mp3',
      ),
      MysteryDefinition(
        index: 3,
        title: 'Coroação de Espinhos',
        fileName: 'doloroso_3_coroacao.mp3',
      ),
      MysteryDefinition(
        index: 4,
        title: 'Jesus carregando a cruz no caminho do Calvário',
        fileName: 'doloroso_4_calvario.mp3',
      ),
      MysteryDefinition(
        index: 5,
        title: 'Crucifixão e morte de Jesus',
        fileName: 'doloroso_5_crucifixao.mp3',
      ),
    ],
  ),
  MysterySetDefinition(
    id: MysterySetId.glorious,
    name: 'Mistérios Gloriosos',
    weekdaysLabel: 'Quartas-feiras e domingos',
    mysteries: <MysteryDefinition>[
      MysteryDefinition(
        index: 1,
        title: 'Ressurreição de Jesus',
        fileName: 'glorioso_1_ressurreicao.mp3',
      ),
      MysteryDefinition(
        index: 2,
        title: 'Ascensão de Jesus ao Céu',
        fileName: 'glorioso_2_ascensao.mp3',
      ),
      MysteryDefinition(
        index: 3,
        title: 'Vinda do Espírito Santo sobre os Apóstolos',
        fileName: 'glorioso_3_pentecostes.mp3',
      ),
      MysteryDefinition(
        index: 4,
        title: 'Assunção de Maria',
        fileName: 'glorioso_4_assuncao.mp3',
      ),
      MysteryDefinition(
        index: 5,
        title: 'Coroação de Maria no Céu',
        fileName: 'glorioso_5_coroacao_maria.mp3',
      ),
    ],
  ),
  MysterySetDefinition(
    id: MysterySetId.luminous,
    name: 'Mistérios Luminosos',
    weekdaysLabel: 'Quintas-feiras',
    mysteries: <MysteryDefinition>[
      MysteryDefinition(
        index: 1,
        title: 'Batismo de Jesus no rio Jordão',
        fileName: 'luminoso_1_batismo.mp3',
      ),
      MysteryDefinition(
        index: 2,
        title: 'Auto-revelação de Jesus nas Bodas de Caná',
        fileName: 'luminoso_2_cana.mp3',
      ),
      MysteryDefinition(
        index: 3,
        title: 'Anúncio do Reino de Deus',
        fileName: 'luminoso_3_reino.mp3',
      ),
      MysteryDefinition(
        index: 4,
        title: 'Transfiguração de Jesus',
        fileName: 'luminoso_4_transfiguracao.mp3',
      ),
      MysteryDefinition(
        index: 5,
        title: 'Instituição da Eucaristia',
        fileName: 'luminoso_5_eucaristia.mp3',
      ),
    ],
  ),
];

MysterySetDefinition mysterySetById(MysterySetId id) {
  return mysterySets.firstWhere((MysterySetDefinition set) => set.id == id);
}

MysterySetId mysterySetForWeekday(int weekday) {
  switch (weekday) {
    case DateTime.monday:
    case DateTime.saturday:
      return MysterySetId.joyful;
    case DateTime.tuesday:
    case DateTime.friday:
      return MysterySetId.sorrowful;
    case DateTime.wednesday:
    case DateTime.sunday:
      return MysterySetId.glorious;
    case DateTime.thursday:
      return MysterySetId.luminous;
    default:
      return MysterySetId.joyful;
  }
}
