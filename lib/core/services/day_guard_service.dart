import 'package:shared_preferences/shared_preferences.dart';

/// ENOUGH — Day Guard Service
/// 
/// Enforces the "once per day" rule.
/// Stores ONLY the last use date — nothing else.
/// 
/// ERROR HANDLING: Fails gracefully - if storage fails, 
/// defaults to allowing usage (user benefit).
class DayGuardService {
  static const String _key = 'enough_last_use_date';
  SharedPreferences? _prefs;
  
  /// Initialize shared preferences
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      // Silent fail - will allow usage if prefs unavailable
      _prefs = null;
    }
  }
  
  /// Check if the app can be used today
  bool canUseToday() {
    if (_prefs == null) return true;  // Fail open
    
    try {
      final lastUse = _prefs!.getString(_key);
      if (lastUse == null) return true;
      
      final today = _getDateString(DateTime.now());
      return lastUse != today;
    } catch (e) {
      return true;  // Fail open
    }
  }
  
  /// Mark today as used
  Future<void> markUsed() async {
    if (_prefs == null) return;  // Can't persist, but continue
    
    try {
      final today = _getDateString(DateTime.now());
      await _prefs!.setString(_key, today);
    } catch (e) {
      // Silent fail - action still proceeds
    }
  }
  
  /// Reset for testing (removes the stored date)
  Future<void> reset() async {
    if (_prefs == null) return;
    
    try {
      await _prefs!.remove(_key);
    } catch (e) {
      // Silent fail
    }
  }
  
  /// Format date as YYYY-MM-DD
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
