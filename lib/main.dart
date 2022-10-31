import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lipobatterymanager/pages/aircraft.dart';
import 'package:lipobatterymanager/theme/themedata.dart';
import 'package:lipobatterymanager/utils/storage_manager.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const LiPoManager());
}

class LiPoManager extends StatefulWidget {
  const LiPoManager({Key? key}) : super(key: key);

  @override
  _LiPoManager createState() => _LiPoManager();
}

class _LiPoManager extends State<LiPoManager> {
  @override
  Widget build(BuildContext context) {
    dynamic aircraftList = StorageManager.getAircraftList();
    if (aircraftList == null) {
      StorageManager.setAircraftList(["Aircraft 1"]);
    }

    dynamic selectedThemeMode = StorageManager.getTheme();
    if (selectedThemeMode == null) {
      StorageManager.setTheme("auto");
      selectedThemeMode = "auto";
    }

    switch (selectedThemeMode) {
      case "light":
        selectedThemeMode = appThemes[0].mode;
        break;

      case "dark":
        selectedThemeMode = appThemes[1].mode;
        break;

      case "auto":
        selectedThemeMode = appThemes[2].mode;
        break;
    }

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  ThemeProvider(selectedThemeMode: selectedThemeMode)),
        ],
        child: Consumer<ThemeProvider>(builder: (c, themeProvider, child) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.selectedThemeMode,
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: Colors.lightGreen,
                primarySwatch: Colors.lightGreen,
              ),
              darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  primaryColor: Colors.lightGreen,
                  primarySwatch: Colors.lightGreen,
                  primaryColorLight: Color.fromARGB(255, 83, 83, 83)),
              home: AircraftScreen(
                  aircraftName: StorageManager.getAircraftList()![0]));
        }));
  }
}
