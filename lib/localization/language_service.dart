import 'app_en.dart';

class LanguageService {
  static Map<String, String> get values => AppEn.values;

  static String text(String key) {
    return AppEn.values[key] ?? key;
  }
}
