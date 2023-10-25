import 'package:crash_app/main.dart';
import 'package:crash_app/models/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../myAPI.dart';

class MapViewModel extends ChangeNotifier {
  late IO.Socket socket;
  String _username = '';
  String _jwtoken = '';
  String get jwtoken => _jwtoken;
  String get username => _username;
  double currentLatitude = 0;
  double currentLongitude = 0;
  late User mainUser;
  List<User> users = [];
  set username(String value) {
    _username = value;
    notifyListeners();
  }
  String _manualMessage = '';
  String get manualMessage => _username;
  set manualMessage(String value) {
    _manualMessage = value;
    notifyListeners();
  }
  set jwtoken(String value) {
    _jwtoken = value;
    notifyListeners();
  }
  Future<void> buildUser() async {
    Position position = await Geolocator.getCurrentPosition();
    currentLatitude = position.latitude;
    currentLongitude = position.longitude;
    String latitude = currentLatitude.toString();
    String longitude = currentLongitude.toString();
    mainUser = User(
        username: username,
        latitude: latitude,
        longitude: longitude,
        state: 'active',
        message: 'all good');
    socket = IO.io(myAPI().connectionUrl, {
      'transports': ['websocket'],
      'extraHeaders': {'authorization': jwtoken},
      'query': {
        'username': mainUser.username,
        'latitude': currentLatitude,
        'longitude': currentLongitude
      }
    });
  }

  void setMessage() {
    mainUser.message = _manualMessage;
  }

  void setMessageText(String text) {
    mainUser.message = text;
  }
  void closeSocket(){
    socket.disconnect();
  }
  void startSocket() {
    if (!socket.connected) {
      socket.connect();
    }
    socket.on(
        'updateres/${mainUser.username}',
        (data) => {
              users.clear(),
              for (var elem in data) {users.add(User.fromJson(elem))}
            });
    socket.onConnectError((error) {
      print("Connection error: " + error.toString());
    });
  }

  Future<void> emitUpdate() async {
    Position position = await Geolocator.getCurrentPosition();
    String latitude = position.latitude.toString();
    String longitude = position.longitude.toString();
    mainUser.latitude = latitude;
    mainUser.longitude = longitude;
    socket.emit('update', {
      'username': mainUser.username,
      'latitude': mainUser.latitude,
      'longitude': mainUser.longitude,
      'state': mainUser.state,
      'message': mainUser.message
    });
  }

  void reset() {
    closeSocket();
    users.clear();
  }
}
