import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/LocalNotificationHelper.dart';
import 'package:frontend/config/ip.dart';
import 'package:frontend/splash.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

const SAVE_KEY_NAME = "UserLogedIn";
late final NotificationService notificationService;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final service = FlutterBackgroundService();

void main() async {
  // Initialize FlutterLocalNotificationsPlugin
  WidgetsFlutterBinding.ensureInitialized();

  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // _showNotification('dhrbfhruhruhf');
  // service.startService();




  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam cell KMCT',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      home: ScreenSplash(),
    );
  }
}

//

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart, isForegroundMode: true));
  await service.startService();
}


@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async{
  print("**********++++++++++++++++*");
  if(service is AndroidServiceInstance){
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
      print("============");
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  Timer.periodic(const Duration(seconds: 10), (timer) async{
    if (service is AndroidServiceInstance) {
      await _allocation();
      await _malNotification();

      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(title: 'title',
            content: 'updated at ${DateTime.now()}',
        );

    }

    }
  });
}

Future<void> _allocation() async {
  final _sharedprif = await SharedPreferences.getInstance();

  int id = _sharedprif.getInt('id') ?? 0;
  String idString = id.toString();
  print(idString + "****************");
  var request = http.MultipartRequest(
      'POST', Uri.parse('http://$MY_IP:8000/get_notification'));

  request.fields['uid'] = idString;
  var response = await request.send();

  if (response.statusCode == 200) {
    final body = await response.stream.bytesToString();
    final data = json.decode(body);
    _showNotification('You have ${data['count']} new allocation');
  }
}

Future<void> _malNotification() async {
  final _sharedprif = await SharedPreferences.getInstance();

  int id = _sharedprif.getInt('id') ?? 0;
  String idString = id.toString();
  print(idString + "****************");
  var request = http.MultipartRequest(
      'POST', Uri.parse('http://$MY_IP:8000/get_mal_notification_back'));

  request.fields['uid'] = idString;
  var response = await request.send();

  if (response.statusCode == 200) {
    final body = await response.stream.bytesToString();
    final data = json.decode(body);
    _showNotification('${data['count']} Malpractice detected !');
  }
}


Future<void> _showNotification(String message) async {


  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'EXAM CELL KMCT',
    message,
    platformChannelSpecifics,
  );
}
