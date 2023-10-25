

import 'package:crash_app/services/http_login.dart';
import 'package:crash_app/services/http_register.dart';
import 'package:get_it/get_it.dart';



final GetIt locator = GetIt.instance;
void setupLocator() {
  locator.registerFactory<LoginHttpService>(
          () => LoginHttpService()
  );
  locator.registerFactory<RegisterHttpService>(
          () => RegisterHttpService()
  );
}