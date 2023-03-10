import 'package:exam_cell_staff/main.dart';
import 'package:exam_cell_staff/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final _userCntrlr = TextEditingController();
  final _passwdCntrlr = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.lightBlueAccent.shade100,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(
          right: 30.0,
          left: 30,
          top: 120,
          bottom: 30,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 30, bottom: 10),
              child: Image.asset('asset/kmct.png'),
            ),
            TextFormField(
              controller: _userCntrlr,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              obscureText: true,
              controller: _passwdCntrlr,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              onPressed: () {
                String username = _userCntrlr.text.toString();
                String passwd = _passwdCntrlr.text.toString();
                print('enterd*****************');
                login(username, passwd, context);
              },
              icon: const Icon(Icons.login),
              label: Text(
                'Login',
                style: GoogleFonts.abel(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.indigoAccent),
                foregroundColor: MaterialStateProperty.all(Colors.greenAccent),
                overlayColor: MaterialStateProperty.all(Colors.blueGrey),
                shadowColor: MaterialStateProperty.all(Colors.red),
                elevation: MaterialStateProperty.all(20),
                padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                minimumSize: MaterialStateProperty.all(const Size(200, 40)),
                animationDuration: const Duration(
                  milliseconds: 5000,
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  //
  Future<void> login(String username, String password, BuildContext ctx) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://10.0.2.2:8000/staff_login'));
    final Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
    };
    request.headers.addAll(headers);

    request.fields['username'] = username;
    request.fields['password'] = password;
    var response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body);
      final _sharedPref = await SharedPreferences.getInstance();
      await _sharedPref.setBool(SAVE_KEY_NAME, true);
      await _sharedPref.setInt('id', data['id']);
      await _sharedPref.setString('name', data['name']);
      await _sharedPref.setString('type', data['type']);
      Navigator.of(ctx).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) {
            return HomeScreen();
          },
        ),
      );
    } else {
      const error = "username password does not match";
      //Snackbar.
      // ignore: prefer_const_constructors
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: const Text(error),
        margin: const EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.amberAccent,
      ));
    }
  }
}
