import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/ip.dart';
import 'package:frontend/login.dart';
import 'package:frontend/screens/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _oldcntrl = TextEditingController();
  final _newcntrl = TextEditingController();
  final _confirmCntrlr = TextEditingController();
  bool _isPasswordVisible = true;
  bool _isPasswordVisiblenew = true;
  bool _isPasswordVisibleconfirm = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _togglePasswordVisibilitynew() {
    setState(() {
      _isPasswordVisiblenew = !_isPasswordVisiblenew;
    });
  }

  void _togglePasswordVisibilityconfirm() {
    setState(() {
      _isPasswordVisibleconfirm = !_isPasswordVisibleconfirm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(
          child: Text(
            'KMCT EXAM CELL',
            style: GoogleFonts.aladin(
              fontWeight: FontWeight.bold,
              color: Colors.white60,
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              final _sharedprif = await SharedPreferences.getInstance();
              await _sharedprif.clear();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                builder: ((ctx1) {
                  return LoginPage();
                }),
              ), (route) => false);
            },
            icon: Icon(Icons.logout),
            label: Text('logout'),
          )
        ],
      ),
      drawer: DrawerNav(),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                obscureText: _isPasswordVisible,
                controller: _oldcntrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the old password';
                  } else if (!RegExp(
                          r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}$')
                      .hasMatch(value)) {
                    return 'Enter a valid value (e.g. Abcd@123 8 characters must)';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        _togglePasswordVisibility();
                      },
                    ),
                    labelText: 'OLD PASSWORD',
                    labelStyle: GoogleFonts.aladin(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                obscureText: _isPasswordVisiblenew,
                controller: _newcntrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the new password';
                  } else if (!RegExp(
                          r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}$')
                      .hasMatch(value)) {
                    return 'Enter a valid value (e.g. Abcd@123 8 characters must)';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisiblenew
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      _togglePasswordVisibilitynew();
                    },
                  ),
                  labelText: 'NEW PASSWORD',
                  labelStyle: GoogleFonts.aladin(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                obscureText: _isPasswordVisibleconfirm,
                controller: _confirmCntrlr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm the password';
                  } else if (!RegExp(
                          r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}$')
                      .hasMatch(value)) {
                    return 'Enter a valid value (e.g. Abcd@123 8 characters must)';
                  } else if (value != _newcntrl.text.toString()) {
                    return 'Both new and confirm passwords not match';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisibleconfirm
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        _togglePasswordVisibilityconfirm();
                      },
                    ),
                    labelText: 'CONFIRM PASSWORD',
                    labelStyle: GoogleFonts.aladin(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
              ),
              SizedBox(
                height: 15,
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      String oldpass = _oldcntrl.text.toString();
                      String newpass = _newcntrl.text.toString();

                      editPassword(
                          oldpass, newpass, context); // handle form submission
                    }
                  },
                  icon: Icon(Icons.password),
                  label: textView('SUBMIT', 20))
            ],
          ),
        ),
      )),
    );
  }

  Future<void> editPassword(
      String oldpass, String newPass, BuildContext ctx) async {
    final sharedPref = await SharedPreferences.getInstance();
    int id = sharedPref.getInt('id') ?? 0;
    String idString = id.toString();
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://$MY_IP:8000/edit_password_app'));
    final Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
    };
    request.headers.addAll(headers);
    request.fields['id'] = idString;
    request.fields['oldpass'] = oldpass;
    request.fields['newpass'] = newPass;
    var response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final data = json.decode(body);
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: textView(data['message'], 15),
        margin: const EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.greenAccent,
      ));
      Navigator.of(context).pop();
    } else {
      final body = await response.stream.bytesToString();
      final data = json.decode(body);
      String error = data['message'];

      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: textView(error, 15),
        margin: const EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ));
    }
  }
}
