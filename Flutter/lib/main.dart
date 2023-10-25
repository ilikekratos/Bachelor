import 'package:crash_app/services/http_login.dart';
import 'package:crash_app/services/http_register.dart';
import 'package:crash_app/view_models/login_view_model.dart';
import 'package:crash_app/view_models/register_view_model.dart';
import 'package:crash_app/view_models/map_view_model.dart';
import 'package:crash_app/views/login_view.dart';
import 'package:crash_app/views/main_view.dart';
import 'package:crash_app/views/map_view.dart';
import 'package:crash_app/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LoginViewModel(
          httpService: locator<LoginHttpService>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => RegisterViewModel(
          httpService: locator<RegisterHttpService>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => MapViewModel(),
      ),
    ],
    child: const MainPage(),
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RideTogether',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/main',
        routes: {
          '/main': (context) => const MyHomePage(),
          '/register': (context) => const RegisterPage(),
          '/login': (context) => const LoginPage(),
          '/map': (context) => const MapPage(),
        },
);
  }

  @override
  void initState() {
    super.initState();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RideTogether',
      home: Scaffold(
        appBar: AppBar(
          title: Text('RideTogether'),
        ),
        body: Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}
