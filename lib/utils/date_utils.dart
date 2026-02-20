import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  static String getAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      return (age - 1).toString();
    }
    
    return age.toString();
  }
  
  static bool isValidDate(String dateString) {
    try {
      DateFormat('dd/MM/yyyy').parseStrict(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }
}