// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:lipobatterymanager/pages/aircraft.dart';
import 'package:lipobatterymanager/utils/storage_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class LiPoDrawer extends StatefulWidget {
  const LiPoDrawer({Key? key}) : super(key: key);

  @override
  _LiPoDrawer createState() => _LiPoDrawer();
}

class _LiPoDrawer extends State<LiPoDrawer> {
  List<String> aircraftList = [];
  final listKey = GlobalKey<AnimatedListState>();

  final newAircraftNameController = TextEditingController();
  final editAircraftNameController = TextEditingController();

  final _addFormKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();

  List<Widget> listItems = [];

  @override
  void initState() {
    if (StorageManager.getAircraftList() == null) {
      StorageManager.setAircraftList(["Aircraft 1"]);
    } else {
      aircraftList = StorageManager.getAircraftList() ?? ["Aircraft 1"];
    }

    super.initState();
  }

  Tween<Offset> animationTween = Tween(begin: Offset(-1, 0), end: Offset(0, 0));

  void addItem(String name) {
    aircraftList.add(name);
    listKey.currentState!.insertItem(aircraftList.length);
  }

  void removeItem(int index) {
    final removedItem = listItems[index + 1];
    aircraftList.removeAt(index);
    listKey.currentState!.removeItem(index + 1, ((context, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: removedItem,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    listItems = List<Widget>.generate(
        aircraftList.length,
        (i) => ListTile(
              leading: Icon(Boxicons.bxs_plane),
              title: Text('${aircraftList[i]}'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AircraftScreen(
                      aircraftName: StorageManager.getAircraftList()![i],
                    ),
                  ),
                );
              },
              onLongPress: () {
                editAircraftNameController.text =
                    StorageManager.getAircraftList()![i];
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Edit Aircraft'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Form(
                              key: _editFormKey,
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a valid name';
                                  }
                                  return null;
                                },
                                controller: editAircraftNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Aircraft Name',
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        if (aircraftList.length > 1) ...[
                          TextButton(
                              child: const Text("Delete"),
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  StorageManager.setBatteryChargeCycles(
                                      StorageManager.getAircraftList()![i], []);
                                  //aircraftList.removeAt(i);
                                  removeItem(i);
                                  StorageManager.setAircraftList(aircraftList);
                                });
                              }),
                        ],
                        TextButton(
                          child: const Text('Done'),
                          onPressed: () {
                            setState(() {
                              if (_editFormKey.currentState!.validate()) {
                                aircraftList[i] =
                                    editAircraftNameController.text;
                                StorageManager.setAircraftList(aircraftList);
                                Navigator.of(context).pop();
                              }
                            });
                          },
                        )
                      ],
                    );
                  },
                );
              },
            ));

    listItems.insert(0, Header());
    listItems.add(ListTile(
      leading: Icon(Icons.add),
      title: Text("Add Aircraft"),
      onTap: () {
        newAircraftNameController.text = "";
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add Aircraft'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Form(
                      key: _addFormKey,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid name';
                          }
                          return null;
                        },
                        controller: newAircraftNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Aircraft Name',
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Done'),
                  onPressed: () {
                    setState(() {
                      if (_addFormKey.currentState!.validate()) {
                        addItem(newAircraftNameController.text);
                        StorageManager.setAircraftList(aircraftList);
                        Navigator.of(context).pop();
                      }
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    ));

    // DRAWER RENDERER
    return Drawer(
        child: AnimatedList(
      key: listKey,
      initialItemCount: listItems.length,
      itemBuilder: (context, index, animation) {
        return SizeTransition(sizeFactor: animation, child: listItems[index]);
      },
    ));
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  Future<void> launchInBrowser(String url) async {
    if (!await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
        height: 220,
        child: DrawerHeader(
            child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset("assets/logo.png", height: 65),
                SizedBox(height: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Drone Battery Manager",
                      style: TextStyle(fontSize: 24),
                    ),
                    Text("By Yaros"),
                  ],
                )
              ],
            ),
          ),
        )),
      ),
      Positioned(
          bottom: 5,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.info_outline, size: 18),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('About Drone Battery Manager'),
                    content: SingleChildScrollView(
                        child: ListBody(children: <Widget>[
                      Text(
                          'This is an app to keep track of battery cycles of your LiPo Batteries.\n'),
                      Text(
                          'Make sure to have approximately the same charge cycles on all batteries.\n'),
                      RichText(
                          textScaleFactor: 1.2,
                          text: TextSpan(children: [
                            TextSpan(
                                text:
                                    "It is very important to follow all safety measures when handling LiPo batteries! ",
                                style: Theme.of(context).textTheme.bodyLarge),
                            TextSpan(
                                style: TextStyle(color: Colors.blue),
                                text: "Learn more here",
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => launchInBrowser(
                                      "https://www.thedronegirl.com/2015/02/07/lipo-battery/#:~:text=Always%20use%20a%20fire%20proof,to%20set%20the%20battery%20off.")),
                          ]))
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
    ]);
  }
}
