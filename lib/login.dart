import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
Future<void> logIn(String username, String password) async {
  final user = ParseUser(username, password, null);

  final response = await user.login();

  if (response.success) {
    print('User logged in successfully!');
  } else {
    print('Error during login: ${response.error?.message}');
  }
}
