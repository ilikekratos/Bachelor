import 'package:crash_app/view_models/login_view_model.dart';
import 'package:crash_app/views/map_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePage();
}
void navigateLogin(BuildContext context){
  Navigator.of(context).pushNamed('/login');
}
void navigateRegister(BuildContext context){
  Navigator.of(context).pushNamed('/register');
}
class _MyHomePage extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RideTogether'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to RideTogether',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            SizedBox(
                width: 200.0, // Change these values as needed
                height: 80.0,
                child: ElevatedButton(
                    onPressed: () {
                      navigateRegister(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                      onPrimary: Colors.white,
                      elevation: 20, // Elevation
                      shadowColor: Colors.blueAccent, // Shadow Color
                    ),
                    child: const Text('Register', style: TextStyle(fontSize: 25)))),
            const SizedBox(height: 40),
            SizedBox(
              width: 200.0, // Change these values as needed
              height: 80.0,
              child: // Add some spacing between the buttons
                  ElevatedButton(
                onPressed: () {
                  navigateLogin(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlue,
                  onPrimary: Colors.white,
                  elevation: 20, // Elevation
                  shadowColor: Colors.blueAccent, // Shadow Color
                ),
                child: const Text('Login', style: TextStyle(fontSize: 25)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
