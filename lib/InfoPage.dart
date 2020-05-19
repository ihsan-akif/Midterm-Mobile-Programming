import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visit_malaysia/Location.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toast/toast.dart';

void main() => runApp(InfoPage());

class InfoPage extends StatefulWidget {
  final Location location;
  const InfoPage({Key key, this.location}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  double screenHeight, screenWidth;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;
  CameraPosition _stateLocation;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> markers = Set();
  double latitude, longitude;
  String phoneNum, urlLocation;

  @override
  void initState() {
    super.initState();
    latitude = double.parse(widget.location.latitude);
    longitude = double.parse(widget.location.longitude);
    phoneNum = widget.location.contact;
    urlLocation = widget.location.url;
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.location.locationName),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                color: Colors.red,
                height: screenHeight / 2,
                width: screenWidth / 2.8,
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl:
                      "http://slumberjer.com/visitmalaysia/images/${widget.location.imagename}",
                ),
              ),
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                color: Colors.blueGrey,
                child: Table(
                  border: TableBorder.all(),
                  defaultColumnWidth: FlexColumnWidth(1.0),
                  columnWidths: {
                    0: FlexColumnWidth(3.5),
                    1: FlexColumnWidth(6.5),
                  },
                  children: [
                    TableRow(children: [
                      TableCell(
                          child: Container(
                        alignment: Alignment.center,
                        height: 100,
                        child: Text(
                          "Description",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                      TableCell(
                          child: Container(
                        alignment: Alignment.center,
                        height: 100,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(
                            widget.location.description,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ))
                    ]),
                    TableRow(children: [
                      TableCell(
                          child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: Text(
                          "URL",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                      TableCell(
                          child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => launch("http:$urlLocation"),
                          child: Text(
                            widget.location.url,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ))
                    ]),
                    TableRow(children: [
                      TableCell(
                          child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: Text(
                          "Address",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                      TableCell(
                          child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => {_loadMapDialog()},
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              widget.location.address,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      ))
                    ]),
                    TableRow(children: [
                      TableCell(
                          child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: Text(
                          "Phone",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                      TableCell(
                          child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            if (widget.location.contact != "No") {
                              launch("tel:$phoneNum"); //make call
                            } else {
                              Toast.show("Phone Number Not Available", context,
                                  duration: Toast.LENGTH_LONG,
                                  gravity: Toast.BOTTOM);
                            }
                          },
                          child: Text(
                            widget.location.contact,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ))
                    ])
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  _loadMapDialog() {
    _controller = Completer();
    _stateLocation =
        CameraPosition(target: LatLng(latitude, longitude), zoom: 14.4746);

    markers.add(Marker(
        markerId: markerId1,
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: widget.location.locationName)));

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, newSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: Text(widget.location.locationName),
              titlePadding: EdgeInsets.all(5),
              actions: <Widget>[
                Text(widget.location.address),
                Container(
                  height: screenHeight / 2 ?? 600,
                  width: screenWidth ?? 360,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _stateLocation,
                    markers: markers.toSet(),
                    onMapCreated: (controller) {
                      _controller.complete(controller);
                    },
                  ),
                ),
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    height: 30,
                    color: Colors.blueGrey,
                    child: Text("Close"),
                    elevation: 10,
                    onPressed: () =>
                        {markers.clear(), Navigator.of(context).pop(false)})
              ],
            );
          });
        });
  }
}
