import 'package:crash_app/view_models/login_view_model.dart';
import 'package:crash_app/views/map_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginViewModel _loginViewModel;

  @override
  void initState() {
    _loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    _loginViewModel.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool success;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (value) => _loginViewModel.username = value,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                onChanged: (value) => _loginViewModel.password = value,
                obscureText: true,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 60),
            SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async => {
                    success = await _loginViewModel.login(),
                    if (success == true)
                      {
                        Navigator.of(context).pushNamed('/map', arguments: {
                          'username': _loginViewModel.username,
                          'jwtoken': _loginViewModel.jwtoken
                        })
                      }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlue,
                    onPrimary: Colors.white,
                    elevation: 5, // Elevation
                    shadowColor: Colors.blueAccent, // Shadow Color
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 22)),
                )),
          ],
        ),
      ),
    );
  }
}
