import 'package:exam_cell_staff/config/ip.dart';
import 'package:exam_cell_staff/login.dart';
import 'package:exam_cell_staff/main.dart';
import 'package:exam_cell_staff/screens/chief_home.dart';
import 'package:exam_cell_staff/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({super.key});

  @override
  State<ScreenSplash> createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash> {
  @override
  void initState() {
    checkLogedIn();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 50.0),
          child: Image.asset(
            'asset/kmct.png',
            height: 500,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> gotoLogin() async {
    await Future.delayed(
      Duration(seconds: 3),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) {
          return LoginPage();
        },
      ),
    );
  }

  Future<void> checkLogedIn() async {
    final _sh_pref = await SharedPreferences.getInstance();
    // _sh_pref.setBool(SAVE_KEY_NAME, true);
    final UserLogedin = _sh_pref.getBool(SAVE_KEY_NAME);
    final type = _sh_pref.getString('type');
    if (UserLogedin == null || UserLogedin == false) {
      gotoLogin();
    } else {
      // ignore: use_build_context_synchronously
      if (type == 'Invigilator') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: ((context) {
              return HomeScreen();
            }),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: ((context) {
              return ChiefHome();
            }),
          ),
        );
      }
    }
  }
}
