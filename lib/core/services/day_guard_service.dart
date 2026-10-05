import 'package:shared_preferences/shared_preferences.dart';

class DayGuardService {
  static const String _key = 'enough_last_use_date';
  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      _prefs = null;
    }
  }

  bool canUseToday() {
    if (_prefs == null) return true;

    try {
      final lastUse = _prefs!.getString(_key);
      if (lastUse == null) return true;

      final today = _getDateString(DateTime.now());
      return lastUse != today;
    } catch (e) {
      return true;
    }
  }

  Future<void> markUsed() async {
    if (_prefs == null) return;

    try {
      final today = _getDateString(DateTime.now());
      await _prefs!.setString(_key, today);
    } catch (_) {}
  }

  Future<void> reset() async {
    if (_prefs == null) return;

    try {
      await _prefs!.remove(_key);
    } catch (_) {}
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
