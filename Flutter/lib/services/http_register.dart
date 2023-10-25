


import 'dart:convert';

import 'package:crash_app/models/User.dart';
import 'package:crash_app/myAPI.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http ;
import 'exceptions/http_exception.dart';

class RegisterHttpService {
  Future<String> register(String username,String password) async {
    final response = await http.post(
      Uri.parse(myAPI().registerUrl),
      body: json.encode({'username':username,'password':password}),
      headers: {"Content-Type": "application/json"},
    ).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw HttpServiceException('Failed to register');
    }
    return response.body;
  }

}