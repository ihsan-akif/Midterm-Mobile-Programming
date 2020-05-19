import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_malaysia/InfoPage.dart';
import 'package:visit_malaysia/Location.dart';

void main() => runApp(MainScreen());

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List locationData;
  double screenHeight, screenWidth;
  String currentState = "Kedah";
  String newState;
  SharedPreferences prefs;
  final _key = 'state';
  List<String> dropDownButtonValue = [
    "Johor",
    "Kedah",
    "Kelantan",
    "Perak",
    "Selangor",
    "Melaka",
    "Negeri Sembilan",
    "Pahang",
    "Perlis",
    "Penang",
    "Sabah",
    "Sarawak",
    "Terengganu"
  ];

  @override
  void initState() {
    super.initState();
    _loadLocation();
    //save state pref
    _savePrefs();
    print("newState: $newState");
  }

  _savePrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      newState = prefs.getString(_key) ?? "Kedah"; //get the value
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    if (locationData == null) {
      return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Visit Malaysia'),
              centerTitle: true,
            ),
            body: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  Card(
                    color: Colors.white24,
                    elevation: 5,
                    child: Container(
                      height: screenHeight / 14.5,
                      margin: EdgeInsets.fromLTRB(20, 2, 20, 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Flexible(
                              child: Container(
                            height: 30,
                            child: Text(
                              "Choose State:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          )),
                          Flexible(
                              child: Container(
                            height: 30,
                            child: DropdownButton<String>(
                                value: newState,
                                onChanged: (String newValue) {
                                  setState(() {
                                    newState = newValue;
                                  });
                                  prefs.setString(_key, newState);

                                  _sortLocation(newValue);
                                  _onDropDownSelectedItem(newValue);
                                },
                                items: dropDownButtonValue
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList()),
                          ))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Location Not Available",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      Text("Please Choose Other State",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20))
                    ],
                  )
                ]))),
      );
    } else {
      return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Visit Malaysia'),
            centerTitle: true,
          ),
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Card(
                  color: Colors.white24,
                  elevation: 5,
                  child: Container(
                    height: screenHeight / 14.5,
                    margin: EdgeInsets.fromLTRB(20, 2, 20, 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Flexible(
                            child: Container(
                          height: 30,
                          child: Text(
                            "Choose State:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        )),
                        Flexible(
                            child: Container(
                          height: 30,
                          child: DropdownButton<String>(
                              value: newState,
                              onChanged: (String newValue) {
                                setState(() {
                                  newState = newValue;
                                });
                                prefs.setString(_key, newState);

                                _sortLocation(newValue);
                                _onDropDownSelectedItem(newValue);
                              },
                              items: dropDownButtonValue
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList()),
                        ))
                      ],
                    ),
                  ),
                ),
                Flexible(
                    child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: (screenWidth / screenHeight) / 0.7,
                        children: List.generate(locationData.length, (index) {
                          return Container(
                            child: GestureDetector(
                              onTap: () {
                                _getLocation(index);
                              },
                              child: Card(
                                color: Colors.white24,
                                elevation: 10,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: screenHeight / 4.5,
                                        width: screenWidth / 2.8,
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            imageUrl:
                                                "http://slumberjer.com/visitmalaysia/images/${locationData[index]['imagename']}",
                                            placeholder: (context, url) =>
                                                new CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    new Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Name: " +
                                            locationData[index]['loc_name'],
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "State: " +
                                            locationData[index]['state'],
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        })))
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
                  title: new Text('Exit App?'),
                  content: new Text('Do you want to exit an App'),
                  actions: <Widget>[
                    MaterialButton(
                        onPressed: () {
                          SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop');
                        },
                        child: Text('Yes')),
                    MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text('No'),
                    )
                  ],
                )) ??
        false;
  }

  void _loadLocation() {
    String urlLoadLocation =
        "http://slumberjer.com/visitmalaysia/load_destinations.php";
    http.post(urlLoadLocation, body: {}).then((res) {
      setState(() {
        var extractLocation = json.decode(res.body);
        locationData = extractLocation["locations"];
        //_sortLocation(currentState);
        _sortLocation(newState);
      });
    }).catchError((err) {
      print(err);
    });
  }

  void _onDropDownSelectedItem(String newStateSelected) {
    setState(() {
      this.currentState = newStateSelected;
    });
  }

  void _sortLocation(String state) {
    try {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: true);
      pr.style(message: "Searching by state...");
      pr.show();

      String urlSortLocation =
          "http://slumberjer.com/visitmalaysia/load_destinations.php";
      http.post(urlSortLocation, body: {
        "state": state,
      }).then((res) {
        print(state);
        if (res.body == "nodata") {
          Toast.show("State Not Available", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          pr.hide();
          FocusScope.of(context).requestFocus(new FocusNode());
          locationData = null;
          return;
        }

        setState(() {
          print("state: $state");
          currentState = state;
          var extractLocation = json.decode(res.body);
          locationData = extractLocation["locations"];
          FocusScope.of(context).requestFocus(new FocusNode());
          pr.hide();
        });
      }).catchError((err) {
        print(err);
        pr.hide();
      });
      pr.hide();
    } catch (e) {
      Toast.show("Error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  _getLocation(int index) async {
    Location location = new Location(
      pid: locationData[index]['pid'],
      locationName: locationData[index]['loc_name'],
      state: locationData[index]['state'],
      description: locationData[index]['description'],
      latitude: locationData[index]['latitude'],
      longitude: locationData[index]['longitude'],
      url: locationData[index]['url'],
      contact: locationData[index]['contact'],
      address: locationData[index]['address'],
      imagename: locationData[index]['imagename'],
    );

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => InfoPage(location: location)));
  }
}
