import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crash_app/models/User.dart';
import 'package:crash_app/view_models/map_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../services/audiohandler.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver{
  bool mystate = false;
  AudioHandler audioHandler=AudioHandler();
  bool isDialogOn = false;
  late Timer _timer1;
  late Timer _timer2;
  GoogleMapController? _controller;
  int index = 0;
  Map<MarkerId, Marker> _markers = {};
  late MapViewModel _mapViewModel;
  @override
  void dispose() {
    _timer1.cancel();
    _timer2.cancel();
    _mapViewModel.reset();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }
  
  void trigger(){
    bool trig=false;
    _mapViewModel.socket.on('alarma/${_mapViewModel.username}',
            (data) => {if(trig==false){                    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Somebody might need help'),
          content: const Text('Check map please'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                trig=true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    )}, _mapViewModel.socket.ack(data)});
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // user is coming back to our app, resume the connection
      startTimer();
      startTimer2();
    } else if (state == AppLifecycleState.paused) {
      // user is leaving our app, disconnect the connection
      _timer1.cancel();
      _timer2.cancel();
    }
    else
    if (state == AppLifecycleState.detached) {
      _timer1.cancel();
      _timer2.cancel();
      _mapViewModel.closeSocket();
    }
    super.didChangeAppLifecycleState(state);
  }
  @override
  void initState() {

    _mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _mapViewModel.username = arguments['username'];
      _mapViewModel.jwtoken = arguments['jwtoken'];
      await _mapViewModel.buildUser();
      if (!_mapViewModel.socket.connected) {
        _mapViewModel.startSocket();
        trigger();
      }
      startTimer();
      startTimer2();
    });

    super.initState();
  }

  void startTimer() {
     mystate = false;
    _timer1 = Timer.periodic(const Duration(seconds: 2), (timer) async {
      index += 1;
      mystate = await audioHandler.recordAndSendAudio(_mapViewModel.username, index);
      if (mystate == true) {
        _timer1.cancel();
        falsePositiveCheck();
      }
    });
  }
  void startTimer2(){
    _timer2 = Timer.periodic(const Duration(seconds: 3), (timer) {
      _mapViewModel.emitUpdate();
      updateMarkers();
    });
  }
  void falsePositiveCheck() {
    if (isDialogOn == false) {
      isDialogOn = true;
      Timer _timer;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          _timer = Timer(const Duration(seconds: 15), () {
            Navigator.of(context).pop();
            _mapViewModel.mainUser.state = "danger";
            _mapViewModel.setMessageText("automated detection");
            isDialogOn = false;
          });
          return WillPopScope(
            onWillPop: () async {
              _timer.cancel();
              return true;
            },
            child: AlertDialog(
              title: const Text('Accident detected!'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Help'),
                  onPressed: () {
                    _timer.cancel();
                    _mapViewModel.mainUser.state = "danger";
                    _mapViewModel
                        .setMessageText("confirmed automated detection");
                    isDialogOn = false;
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    _timer.cancel();
                    startTimer();
                    isDialogOn = false;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void updateMarkers() {
    _markers.clear();
    for (var user in _mapViewModel.users) {
      LatLng location =
          LatLng(double.parse(user.latitude), double.parse(user.longitude));
      if (user.username == _mapViewModel.username) {
        Marker marker = Marker(
            markerId: MarkerId(user.username),
            position: location,
            infoWindow: InfoWindow(title: user.username, snippet: user.message),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen));
        _markers[marker.markerId] = marker;
      } else {
        if (user.state == "danger") {
          Marker marker = Marker(
              markerId: MarkerId(user.username),
              position: location,
              infoWindow:
                  InfoWindow(title: user.username, snippet: user.message),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed));
          _markers[marker.markerId] = marker;
        } else if (user.state == "inactive") {
          Marker marker = Marker(
              markerId: MarkerId(user.username),
              position: location,
              infoWindow:
                  InfoWindow(title: user.username, snippet: user.message),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet));
          _markers[marker.markerId] = marker;
        } else {
          Marker marker = Marker(
              markerId: MarkerId(user.username),
              position: location,
              infoWindow:
                  InfoWindow(title: user.username, snippet: user.message),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue));
          _markers[marker.markerId] = marker;
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map screen'),
      ),
      body: FutureBuilder<Position>(
          future: Geolocator.getCurrentPosition(),
          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
            if (snapshot.hasData) {
              return Center(
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        snapshot.data!.latitude, snapshot.data!.longitude),
                    zoom: 12,
                  ),
                  markers: Set<Marker>.of(_markers.values),
                ),
              );
            } else {
              return const Center(
                  child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ));
            }
          }),
      floatingActionButton: Stack(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                width: 70,
                height: 70,
                child: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('State set to normal'),
                          content: const Text('Hope you are okay :D'),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('OK'),
                              onPressed: () {
                                _mapViewModel.mainUser.state = "active";
                                _mapViewModel.mainUser.message = "all good";
                                startTimer();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.check, size: 50),
                )),
          ),
        ),
        Align(
          alignment: const Alignment(0.2, 1.0),
          child: SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Enter your problem'),
                        content: TextField(
                            maxLines: null,
                            decoration: const InputDecoration(
                              labelText: 'Message',
                              border: OutlineInputBorder(),
                              hintText: 'Enter your text here',
                            ),
                            onChanged: (value) =>
                                _mapViewModel.manualMessage = value,
                            style: const TextStyle(fontSize: 15)),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('OK'),
                            onPressed: () {
                              _mapViewModel.mainUser.state = "danger";
                              _mapViewModel.setMessage();
                              _timer1.cancel();
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.warning_rounded, size: 50),
              )),
        ),
      ]),
    );
  }
}
