


import 'dart:convert';

import 'package:crash_app/models/User.dart';
import 'package:crash_app/myAPI.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http ;
import 'exceptions/http_exception.dart';

class LoginHttpService {
  // static final log = Logger("DaysHttpService");


  Future<String> login(String username,String password) async {
    Position position = await Geolocator.getCurrentPosition();
    double latitude = position.latitude;
    double longitude = position.longitude;
    // log.info("Creating item (${item.toJson()}) on: /symptoms");
    final response = await http.post(
      Uri.parse(myAPI().loginUrl),
      body: json.encode({'username':username,'password':password,'latitude':latitude,'longitude':longitude,'state':'active','message':'ok'}),
      headers: {"Content-Type": "application/json"},
    ).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      // log.severe("Post method failed.");
      throw HttpServiceException('Failed to login');
    }
    return response.body;
  }

}