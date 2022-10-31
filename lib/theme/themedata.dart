import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({Key? key}) : super(key: key);

  Future<void> saveTheme(theme) async {
    String currentTheme;
    if (theme == ThemeMode.light) {
      currentTheme = "light";
    } else if (theme == ThemeMode.dark) {
      currentTheme = "dark";
    } else {
      currentTheme = "auto";
    }
    final storage = LocalStorage('settings.json');
    await storage.ready;
    storage.setItem("theme", currentTheme);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (c, themeProvider, _) => SizedBox(
        height: (450.0 - (17 * 2) - (10 * 2)) / 3,
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          crossAxisCount: appThemes.length,
          children: List.generate(
            appThemes.length,
            (i) {
              bool isSelectedTheme =
                  appThemes[i].mode == themeProvider.selectedThemeMode;
              return GestureDetector(
                onTap: isSelectedTheme
                    ? null
                    : () => {
                          themeProvider.setSelectedThemeMode(appThemes[i].mode),
                          saveTheme(appThemes[i].mode),
                        },
                child: AnimatedContainer(
                  height: 100,
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelectedTheme
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        width: 2, color: Theme.of(context).primaryColor),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 7),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).cardColor.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(appThemes[i].icon),
                          Text(
                            appThemes[i].title == "Light"
                                ? "Light"
                                : appThemes[i].title == "Dark"
                                    ? "Dark"
                                    : "Auto",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeProvider({required this.selectedThemeMode});
  ThemeMode selectedThemeMode;
  setSelectedThemeMode(ThemeMode themeMode) {
    selectedThemeMode = themeMode;
    notifyListeners();
  }
}

class AppTheme {
  ThemeMode mode;
  String title;
  IconData icon;

  AppTheme({
    required this.mode,
    required this.title,
    required this.icon,
  });
}

List<AppTheme> appThemes = [
  AppTheme(
    mode: ThemeMode.light,
    title: 'Light',
    icon: Icons.brightness_5_rounded,
  ),
  AppTheme(
    mode: ThemeMode.dark,
    title: 'Dark',
    icon: Icons.brightness_2_rounded,
  ),
  AppTheme(
    mode: ThemeMode.system,
    title: 'Auto',
    icon: Icons.brightness_4_rounded,
  ),
];
