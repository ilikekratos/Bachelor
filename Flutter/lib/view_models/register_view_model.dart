

import 'dart:convert';
import 'dart:io';
import 'package:crash_app/services/http_login.dart';
import 'package:crash_app/services/http_register.dart';
import 'package:crash_app/views/map_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier{
  final RegisterHttpService httpService;
  RegisterViewModel({required this.httpService});
  String _username='';
  String _password='';
  String get username => _username;
  String get password => _password;
  void reset() {
    _username = '';
    _password = '';
  }
  set username(String value) {
    _username = value;
    notifyListeners();
  }
  set password(String value) {
    _password = value;
    notifyListeners();
  }
  Future<bool> register() async {
    try {
      final responseString = await httpService.register(_username, _password);
      final responseJson = jsonDecode(responseString);
      if(responseJson['success']==true){
        return true;
      }
      else{
        return false;
      }
    }
    catch (error){
    return false;}
  }
}