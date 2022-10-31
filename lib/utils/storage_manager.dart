import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static late SharedPreferences _preferences;

  static const String _keyAircraftList = "Aircraft List";

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static List<String>? getAircraftList() =>
      _preferences.getStringList(_keyAircraftList);

  static Future setAircraftList(List<String> aircraftList) async {
    await _preferences.setStringList(_keyAircraftList, aircraftList);
  }

  static List<String>? getBatteryChargeCycles(aircraftName) =>
      _preferences.getStringList("$aircraftName Cycles");

  static int? getNumBatteries(aircraftName) {
    if (_preferences.getStringList("$aircraftName Cycles") == null) {
      return 0;
    }
    return _preferences.getStringList("$aircraftName Cycles")!.length;
  }

  static Future setBatteryChargeCycles(
      String aircraftName, List<String> cyclesList) async {
    await _preferences.setStringList("$aircraftName Cycles", cyclesList);
  }

  static String? getTheme() => _preferences.getString("theme");

  static Future setTheme(String theme) async {
    await _preferences.setString("theme", theme);
  }
}
