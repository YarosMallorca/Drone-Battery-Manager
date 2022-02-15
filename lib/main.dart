import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LiPoManager());
}

class LiPoManager extends StatefulWidget {
  const LiPoManager({Key? key}) : super(key: key);

  @override
  _LiPoManager createState() => _LiPoManager();
}

class _LiPoManager extends State<LiPoManager> {
  List<int> cyclesList = [0, 0, 0];
  String battery1Text = "0";
  String battery2Text = "0";
  String battery3Text = "0";
  String recommendedBattery = "1";

  void modifyCycles(action) {
    if (action == "1-") {
      if (cyclesList[0] > 0) {
        cyclesList[0] -= 1;
      }
    } else if (action == "1+") {
      cyclesList[0] += 1;
    } else if (action == "2-") {
      if (cyclesList[1] > 0) {
        cyclesList[1] -= 1;
      }
    } else if (action == "2+") {
      cyclesList[1] += 1;
    } else if (action == "3-") {
      if (cyclesList[2] > 0) {
        cyclesList[2] -= 1;
      }
    } else if (action == "3+") {
      cyclesList[2] += 1;
    }

    updateLabels();

    saveChargeCycle(1, cyclesList[0]);
    saveChargeCycle(2, cyclesList[1]);
    saveChargeCycle(3, cyclesList[2]);

    calculateRecommended();
  }

  void updateLabels() {
    setState(() {
      battery1Text = cyclesList[0].toString();
      battery2Text = cyclesList[1].toString();
      battery3Text = cyclesList[2].toString();
    });
  }

  void calculateRecommended() {
    int smallestValue = cyclesList[0];
    for (int i = 0; i < cyclesList.length; i++) {
      if (cyclesList[i] < smallestValue) {
        smallestValue = cyclesList[i];
      }
    }
    setState(() {
      recommendedBattery =
          (cyclesList.indexOf(smallestValue).toInt() + 1).toString();
    });
  }

  Future<void> getChargeCycles() async {
    final prefs = await SharedPreferences.getInstance();
    cyclesList[0] = prefs.getInt("1") ?? -1;
    cyclesList[1] = prefs.getInt("2") ?? -1;
    cyclesList[2] = prefs.getInt("3") ?? -1;

    for (int i = 0; i < cyclesList.length; i++) {
      if (cyclesList[i] == -1) {
        cyclesList[i] = 0;
        prefs.setInt((i + 1).toString(), 0);
      }
    }

    updateLabels();
  }

  Future<void> saveChargeCycle(batteryId, value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(batteryId.toString(), value);
  }

  @override
  Widget build(BuildContext context) {
    double logicWidth = 400;
    double logicHeight = 800;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    getChargeCycles();
    calculateRecommended();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                    primary: Colors.green))),
        home: Scaffold(
            body: SafeArea(
                child: SizedBox.expand(
                    child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
              width: logicWidth,
              height: logicHeight,
              child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                        top: 20,
                        height: 120,
                        child: Image.asset('assets/Title.png')),
                    Center(
                        child: FractionallySizedBox(
                            heightFactor: 0.7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Text(
                                      'Battery\n1',
                                      style: TextStyle(fontSize: 35),
                                      textAlign: TextAlign.center,
                                    ),
                                    ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(minWidth: 70),
                                        child: Text(battery1Text,
                                            style:
                                                const TextStyle(fontSize: 40),
                                            textAlign: TextAlign.center)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () => modifyCycles("1-"),
                                            child: const Text('-',
                                                style:
                                                    TextStyle(fontSize: 50))),
                                        ElevatedButton(
                                          onPressed: () => modifyCycles("1+"),
                                          child: const Text('+',
                                              style: TextStyle(fontSize: 30)),
                                        )
                                      ]
                                          .map((e) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3),
                                              child: e))
                                          .toList(),
                                    )
                                  ]
                                      .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: e))
                                      .toList(),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Text(
                                      'Battery\n2',
                                      style: TextStyle(fontSize: 35),
                                      textAlign: TextAlign.center,
                                    ),
                                    ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(minWidth: 70),
                                        child: Text(battery2Text,
                                            style:
                                                const TextStyle(fontSize: 40),
                                            textAlign: TextAlign.center)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => modifyCycles("2-"),
                                          child: const Text('-',
                                              style: TextStyle(fontSize: 50)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => modifyCycles("2+"),
                                          child: const Text('+',
                                              style: TextStyle(fontSize: 30)),
                                        )
                                      ]
                                          .map((e) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3),
                                              child: e))
                                          .toList(),
                                    )
                                  ]
                                      .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: e))
                                      .toList(),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Text(
                                      'Battery\n3',
                                      style: TextStyle(fontSize: 35),
                                      textAlign: TextAlign.center,
                                    ),
                                    ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(minWidth: 70),
                                        child: Text(battery3Text,
                                            style:
                                                const TextStyle(fontSize: 40),
                                            textAlign: TextAlign.center)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => modifyCycles("3-"),
                                          child: const Text('-',
                                              style: TextStyle(fontSize: 50)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => modifyCycles("3+"),
                                          child: const Text('+',
                                              style: TextStyle(fontSize: 30)),
                                        )
                                      ]
                                          .map((e) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3),
                                              child: e))
                                          .toList(),
                                    )
                                  ]
                                      .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: e))
                                      .toList(),
                                )
                              ]
                                  .map((e) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 30),
                                      child: e))
                                  .toList(),
                            ))),
                    Positioned(
                        bottom: 30,
                        child: Text(
                          "Recommended\nBattery to Fly: $recommendedBattery",
                          style: const TextStyle(fontSize: 40),
                        ))
                  ])),
        )))));
  }
}
