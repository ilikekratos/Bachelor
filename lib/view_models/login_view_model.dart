
import 'dart:convert';
import 'package:crash_app/services/http_login.dart';
import 'package:crash_app/views/map_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier{

  final LoginHttpService httpService;
  LoginViewModel({required this.httpService});
  String _username='';
  String _password='';
  String _jwtoken='';
  String get jwtoken => _jwtoken;
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

  Future<bool> login() async {
    final responseString= await httpService.login(_username,_password);
    final responseJson = jsonDecode(responseString);
    if(responseJson['success']==true){
      _jwtoken=responseJson['jwtoken'];
      return true;
    }
    else{
      return false;
    }
  }
}