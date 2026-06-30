import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_history_item.dart';

class LocalLocationDataSource {
  static const String _historyKey = 'gps_location_history';

  Future<List<LocationHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? historyJsonList = prefs.getStringList(_historyKey);
    if (historyJsonList == null) {
      return [];
    }
    return historyJsonList
        .map((jsonStr) => LocationHistoryItem.fromJson(jsonStr))
        .toList();
  }

  Future<void> addLocation(LocationHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<LocationHistoryItem> currentHistory = await getHistory();
    
    // Add to the beginning of the list (most recent first)
    currentHistory.insert(0, item);
    
    // Keep only the last 30 items
    if (currentHistory.length > 30) {
      currentHistory.removeRange(30, currentHistory.length);
    }
    
    final List<String> jsonList =
        currentHistory.map((item) => item.toJson()).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
