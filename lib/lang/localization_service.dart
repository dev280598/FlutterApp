import 'dart:collection';
import 'dart:ui';

import 'package:flutter_app/lang/str_vi.dart';
import 'package:get/get.dart';

import 'str_en.dart';

class LocalizationService extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {"en": en, "vi": vi};

  static final locale = _getLocaleFromLanguage();

  static const fallback = Locale('en', 'US');

  static final langCodes = [
    'en',
    'vi',
  ];
  static final locales = [const Locale("en", "US"), const Locale("vi", "VN")];

  static final langs ={
    "vi": "Tiếng Việt",
    "en": "English",
  };

  static void changeLocale(String langCode) {
    final mLocale = _getLocaleFromLanguage(langCode: langCode);
    Get.updateLocale(mLocale);
  }

  static Locale _getLocaleFromLanguage({String? langCode}) {
    final lang = langCode ?? Get.deviceLocale?.languageCode;

    for (var i = 0; i < langCodes.length; i++) {
      if (lang == langCodes[i]) {
        return locales[i];
      }
    }
    return Get.locale ?? fallback;
  }
}
