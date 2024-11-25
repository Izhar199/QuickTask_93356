import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import './taskpage.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Parse SDK
  const String appId = 'Xg51ldfudzkMS4w2ofcxroyhercroMf2Yy0XDyQU'; // Replace with your Back4App App ID
  const String serverUrl = 'https://parseapi.back4app.com/'; // Replace with your Back4App Server URL
  const String clientKey = 'k0HkqnTFdd7Sc30hXYqdQK1XdWo6EjmcklIMLk2V'; // Optional if configured in Back4App

  await Parse().initialize(
    appId,
    serverUrl,
    clientKey: clientKey,
    autoSendSessionId: true,
  );
final currentUser = await ParseUser.currentUser() as ParseUser?;
  runApp(MyApp(initialPage: currentUser == null ? AuthenticationPage() : TaskPage()));
  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  MyApp({required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTask',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: initialPage,
    );
  }
}

class TestParsePage extends StatelessWidget {
  Future<void> testParseConnection() async {
    // Create a test object in the Back4App database
    final testObject = ParseObject('TestObject')
      ..set('key', 'value'); // Example key-value pair

    final ParseResponse response = await testObject.save();

    if (response.success) {
      print('Connection successful! Object saved in Back4App.');
    } else {
      print('Error during connection: ${response.error?.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parse SDK Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: testParseConnection,
          child: Text('Test Parse Connection'),
        ),
      ),
    );
  }
}
class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}
class _AuthenticationPageState extends State<AuthenticationPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> signUp() async {
    final user = ParseUser(
      usernameController.text.trim(),
      passwordController.text.trim(),
      null, // Email is optional
    );

    final response = await user.signUp(allowWithoutEmail: true);
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.error?.message}')),
      );
    }
  }

  Future<void> logIn() async {
    final user = ParseUser(
      usernameController.text.trim(),
      passwordController.text.trim(),
      null,
    );

    final response = await user.login();
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TaskPage()),
    );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.error?.message}')),
      );
    }
  }

  Future<void> logOut() async {
  final user = await ParseUser.currentUser() as ParseUser?;
  final response = await user?.logout();

  if (response?.success ?? false) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully!')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${response?.error?.message}')),
    );
  }
}

  Future<void> resetPassword(String email) async {
  final response = await ParseUser(null, null, email).requestPasswordReset();

  if (response.success) {
    print('Password reset email sent successfully!');
  } else {
    print('Error: ${response.error?.message}');
  }
  }
  void _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    await resetPassword(email);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('If the email exists, a reset link was sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QuickTask Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resetPassword,
                      child: Text('Send Reset Link'),
                    ),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              child: Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: logIn,
              child: Text('Log In'),
            ),
          ],
        ),
      ),
    );
    
    
  }
}
