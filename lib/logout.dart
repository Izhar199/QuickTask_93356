import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
Future<void> logOut() async {
  final user = await ParseUser.currentUser();

  if (user != null) {
    final response = await user.logout();

    if (response.success) {
      print('User logged out successfully!');
    } else {
      print('Error during logout: ${response.error?.message}');
    }
  }
}
