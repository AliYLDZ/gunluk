class PasswordEntry {
  final String id;
  final String appName;
  final String username;
  final String password;

  PasswordEntry({
    required this.id,
    required this.appName,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'appName': appName,
        'username': username,
        'password': password,
      };

  factory PasswordEntry.fromJson(Map<String, dynamic> json) => PasswordEntry(
        id: json['id'],
        appName: json['appName'],
        username: json['username'],
        password: json['password'],
      );
}
