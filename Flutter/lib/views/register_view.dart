import 'package:crash_app/view_models/login_view_model.dart';
import 'package:crash_app/view_models/register_view_model.dart';
import 'package:crash_app/views/map_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  late RegisterViewModel _registerViewModel;
  @override
  void initState() {
    _registerViewModel = Provider.of<RegisterViewModel>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    _registerViewModel.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool success;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (value) => _registerViewModel.username = value,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 40), // Add some spacing between the text fields
            TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                onChanged: (value) => _registerViewModel.password = value,
                style: const TextStyle(fontSize: 20)),

            const SizedBox(height: 60),
            SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                    onPressed: () async => {
                          success = await _registerViewModel.register(),
                          if (success == true)
                            {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title:
                                        const Text('Registration Successful'),
                                    content: const Text(
                                        'You have registered successfully!'),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              )
                            }
                          else
                            {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Registration Failed'),
                                    content: const Text(
                                        'You have not been registered network issue/name already exists'),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              )
                            }
                        },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                      onPrimary: Colors.white,
                      elevation: 5, // Elevation
                      shadowColor: Colors.blueAccent, // Shadow Color
                    ),
                    child: const Text('Register', style: TextStyle(fontSize: 22)))) // Add some spacing between the text field and the button
            ,
          ],
        ),
      ),
    );
  }
}
