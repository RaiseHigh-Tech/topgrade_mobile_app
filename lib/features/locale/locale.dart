

import 'package:get/get_navigation/src/root/internacionalization.dart';

import 'en_US.dart';
import 'es_ES.dart';

class XLocale extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUS, 'es_ES': esES};
}
