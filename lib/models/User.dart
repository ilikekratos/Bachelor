class User {
  final String username;
   String latitude;
   String longitude;
   String state;
   String message;
  User({
    required this.username,
    required this.latitude,
    required this.longitude,
    required this.state,
    required this.message
  });
  factory User.fromJson(Map<String, dynamic> json) {
    final coordinates= json['coordinates'] as Map<String,dynamic>;
    return User(
      username: json['username'],
      latitude:coordinates['latitude'],
      longitude:coordinates['longitude'],
      state:json['state'],
      message: json['message']
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'usernaname': username,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'state':state,
      'message':message
    };
  }
}




