import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
Future<void> signUp(String username, String password, String email) async {
  final user = ParseUser(username, password, email);

  final response = await user.signUp();

  if (response.success) {
    print('User registered successfully: ${user.objectId}');
  } else {
    print('Error during sign-up: ${response.error?.message}');
  }
}
