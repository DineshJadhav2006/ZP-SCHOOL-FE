import 'app_en.dart';
import 'app_mr.dart';

class LanguageService {
  static String currentLanguage = "en";

  static Map<String, String> get values {
    return currentLanguage == "mr"
        ? AppMr.values
        : AppEn.values;
  }

  static String text(String key) {
    return values[key] ?? key;
  }

  static void changeLanguage(String lang) {
    currentLanguage = lang;
  }
}
