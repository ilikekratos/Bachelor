class myAPI {
  static final myAPI _instance = myAPI._internal();

  factory myAPI() {
    return _instance;
  }

  myAPI._internal();
  String registerUrl = 'http://35.242.210.242:8080/register';
  String loginUrl = 'http://35.242.210.242:8080/login';
  String connectionUrl='ws://35.242.210.242:8080';
  String pythonUrl='http://35.242.210.242:5000';

// Add other methods and properties for your API here
}