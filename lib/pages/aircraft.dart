import 'package:flutter/material.dart';
import 'package:lipobatterymanager/components/drawer.dart';
import 'package:lipobatterymanager/theme/themedata.dart';
import 'package:lipobatterymanager/utils/storage_manager.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:numberpicker/numberpicker.dart';

class AircraftScreen extends StatefulWidget {
  const AircraftScreen({Key? key, required this.aircraftName})
      : super(key: key);
  final String aircraftName;

  @override
  _AircraftScreen createState() => _AircraftScreen();
}

enum TargetThemeMode { auto, light, dark }

class _AircraftScreen extends State<AircraftScreen> {
  List<String> batteryList = [];
  final listKey = GlobalKey<AnimatedListState>();
  List<Widget> listItems = [];

  Tween<Offset> animationTween = Tween(begin: Offset(-1, 0), end: Offset(0, 0));

  TargetThemeMode? _themeMode = TargetThemeMode.auto;
  int _batteryEditingValue = 0;

  @override
  void initState() {
    if (StorageManager.getNumBatteries(widget.aircraftName) == null) {
      StorageManager.setBatteryChargeCycles(widget.aircraftName, []);
    } else {
      batteryList =
          StorageManager.getBatteryChargeCycles(widget.aircraftName) ?? [];
    }

    final _currentTheme = StorageManager.getTheme();
    switch (_currentTheme) {
      case "light":
        _themeMode = TargetThemeMode.light;
        break;

      case "dark":
        _themeMode = TargetThemeMode.dark;
        break;

      case "auto":
        _themeMode = TargetThemeMode.auto;
        break;
    }
    super.initState();
  }

  void addItem(String name) {
    batteryList.add(name);
    listKey.currentState!.insertItem(batteryList.length - 1);
  }

  void removeItem(int index) {
    final removedItem = listItems[index];
    batteryList.removeAt(index);
    listKey.currentState!.removeItem(index, ((context, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: removedItem,
      );
    }));
  }

  String getLowCycles() {
    if (batteryList.isEmpty) {
      return "No Battery Available";
    }
    int smallestValue = int.parse(batteryList[0]);
    for (int i = 0; i < batteryList.length; i++) {
      if (int.parse(batteryList[i]) < smallestValue) {
        smallestValue = int.parse(batteryList[i]);
      }
    }
    return "Battery ${batteryList.indexOf(smallestValue.toString()).toInt() + 1}";
  }

  void editBatteryCycles(i) {
    _batteryEditingValue = int.parse(batteryList[i]);
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, ss) {
              return AlertDialog(
                title: const Text('Battery Charge Cycle Editing'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      NumberPicker(
                        textStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                        selectedTextStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 28),
                        value: _batteryEditingValue,
                        minValue: 0,
                        maxValue: 10000,
                        onChanged: (value) =>
                            ss(() => _batteryEditingValue = value),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Apply'),
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).pop();
                        batteryList[i] = _batteryEditingValue.toString();
                        StorageManager.setBatteryChargeCycles(
                            widget.aircraftName, batteryList);
                      });
                    },
                  ),
                ],
              );
            },
          );
        });
  }

  void deleteBattery(i) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Battery'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete Battery ${i + 1}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  removeItem(i);
                  StorageManager.setBatteryChargeCycles(
                      widget.aircraftName, batteryList);
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget lowestCyclesContainer() {
    return Center(
      child: Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: Container(
              padding: const EdgeInsets.only(bottom: 20, top: 20),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Stack(children: [
                Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.battery_0_bar, size: 32),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Lowest № of Cycles:",
                          style: TextStyle(fontSize: 28),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      getLowCycles(),
                      style: TextStyle(fontSize: 28),
                    ),
                  ],
                )),
                Positioned(
                    bottom: -15,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.info_outline, size: 18),
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('About Lowest № of Cycles'),
                              content: SingleChildScrollView(
                                  child: ListBody(children: <Widget>[
                                Text(
                                    'This is an indicator which shows the battery that has the least charge cycles.\n'),
                                Text(
                                    'Make sure to fly the battery which has less cycles than the others to keep the charge cycles in balance, thus extending the longevity of your batteries.')
                              ])),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ))
              ]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    listItems = List<Widget>.generate(
        batteryList.length,
        (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 10),
              child: InkWell(
                onLongPress: () => deleteBattery(i),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Battery ${i + 1}',
                        style: TextStyle(fontSize: 30),
                        textAlign: TextAlign.center,
                      ),
                      ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 80),
                          child: GestureDetector(
                            onTap: (() => editBatteryCycles(i)),
                            onLongPress: (() => editBatteryCycles(i)),
                            child: Text(batteryList[i].toString(),
                                style: const TextStyle(fontSize: 35),
                                textAlign: TextAlign.center),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(50, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              onPressed: () {
                                if (int.parse(batteryList[i]) > 0) {
                                  setState(() {
                                    batteryList[i] =
                                        (int.parse(batteryList[i]) - 1)
                                            .toString();
                                    StorageManager.setBatteryChargeCycles(
                                        widget.aircraftName, batteryList);
                                  });
                                }
                              },
                              child: const Text('-',
                                  style: TextStyle(fontSize: 40))),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            onPressed: () {
                              setState(() {
                                batteryList[i] =
                                    (int.parse(batteryList[i]) + 1).toString();
                                StorageManager.setBatteryChargeCycles(
                                    widget.aircraftName, batteryList);
                              });
                            },
                            child:
                                const Text('+', style: TextStyle(fontSize: 30)),
                          )
                        ]
                            .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: e))
                            .toList(),
                      )
                    ]
                        .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: e))
                        .toList(),
                  ),
                ),
              ),
            ));

    listItems.add(Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 10),
        child: InkWell(
          onTap: () {
            setState(() {
              addItem("0");
              StorageManager.setBatteryChargeCycles(
                  widget.aircraftName, batteryList);
            });
          },
          child: Container(
              padding: const EdgeInsets.only(bottom: 20, top: 20),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 32),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    "Add Battery",
                    style: TextStyle(fontSize: 32),
                  ),
                ],
              ))),
        )));

    return Consumer<ThemeProvider>(builder: (c, themeProvider, _) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            actions: [
              Container(
                margin: const EdgeInsets.all(4.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                    icon: const Icon(MdiIcons.themeLightDark),
                    onPressed: () => showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return AlertDialog(
                                title: const Text('Change Theme'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          ListTile(
                                            onTap: () {
                                              setState(() {
                                                _themeMode =
                                                    TargetThemeMode.auto;
                                              });
                                            },
                                            title: const Text('Auto'),
                                            leading: Radio<TargetThemeMode>(
                                              activeColor: Theme.of(context)
                                                  .primaryColor,
                                              value: TargetThemeMode.auto,
                                              groupValue: _themeMode,
                                              onChanged:
                                                  (TargetThemeMode? value) {
                                                setState(() {
                                                  _themeMode = value;
                                                });
                                              },
                                            ),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              setState(() {
                                                _themeMode =
                                                    TargetThemeMode.light;
                                              });
                                            },
                                            title: const Text('Light'),
                                            leading: Radio<TargetThemeMode>(
                                              activeColor: Theme.of(context)
                                                  .primaryColor,
                                              value: TargetThemeMode.light,
                                              groupValue: _themeMode,
                                              onChanged:
                                                  (TargetThemeMode? value) {
                                                setState(() {
                                                  _themeMode = value;
                                                });
                                              },
                                            ),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              setState(() {
                                                _themeMode =
                                                    TargetThemeMode.dark;
                                              });
                                            },
                                            title: const Text('Dark'),
                                            leading: Radio<TargetThemeMode>(
                                              activeColor: Theme.of(context)
                                                  .primaryColor,
                                              value: TargetThemeMode.dark,
                                              groupValue: _themeMode,
                                              onChanged:
                                                  (TargetThemeMode? value) {
                                                setState(() {
                                                  _themeMode = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Apply'),
                                    onPressed: () {
                                      switch (_themeMode) {
                                        case TargetThemeMode.light:
                                          themeProvider.setSelectedThemeMode(
                                              appThemes[0].mode);
                                          StorageManager.setTheme("light");

                                          break;
                                        case TargetThemeMode.dark:
                                          themeProvider.setSelectedThemeMode(
                                              appThemes[1].mode);
                                          StorageManager.setTheme("dark");

                                          break;

                                        case TargetThemeMode.auto:
                                          themeProvider.setSelectedThemeMode(
                                              appThemes[2].mode);
                                          StorageManager.setTheme("auto");
                                          break;
                                        default:
                                          break;
                                      }
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                          },
                        )),
              ),
            ],
            title: Text(widget.aircraftName),
          ),
          drawer: LiPoDrawer(),
          // MAIN BODY
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
                child: SizedBox.expand(
              child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 450,
                      height: 850,
                      child: Column(children: [
                        Expanded(
                          child: AnimatedList(
                              key: listKey,
                              initialItemCount: listItems.length,
                              itemBuilder:
                                  (BuildContext context, int index, animation) {
                                return SizeTransition(
                                    key: UniqueKey(),
                                    sizeFactor: animation,
                                    child: listItems[index]);
                              }),
                        ),
                        lowestCyclesContainer()
                      ]))),
            )),
          ));
    });
  }
}
