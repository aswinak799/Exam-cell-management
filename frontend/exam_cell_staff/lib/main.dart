import 'dart:ui';

import 'package:exam_cell_staff/config/LocalNotificationHelper.dart';
import 'package:exam_cell_staff/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background/flutter_background.dart';

import 'login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const SAVE_KEY_NAME = "UserLogedIn";
// late final NotificationService notificationService;
void main() async {
  // listenToNotificationStream();

  WidgetsFlutterBinding.ensureInitialized();
  // await initializeService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam cell KMCT',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: ScreenSplash(),
    );
  }
}

// Future<void> onStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();

//   if (service is FlutterBackgroundService) {
//     // Subscribe to the 'setAsForeground' event and set the service as foreground when it's received
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });

//     // Subscribe to the 'setAsBackground' event and set the service as background when it's received
//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });

//     // Start the service if it hasn't been started already
//     if (!service.isStarted) {
//       try {
//         await service.start();
//       } catch (e) {
//         print('Error starting service: $e');
//       }
//     }
//   } else {
//     // Handle other platforms or unsupported service types here
//     print('Unsupported service type: $service');
//   }
// }

// // service.on('stopService').listen((event) {
// //     service.stopSelf();
// //   });

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onStart,
//     ),
//   );
//   service.startService();

//   // Initialize Flutter Local Notifications
//   // FlutterLocalNotificationsPlugin notifications =
//   //     FlutterLocalNotificationsPlugin();

//   // // Android-specific initialization

//   // // Request permission to display notifications
//   // notificationService = NotificationService();
//   // notificationService.initializePlatformNotifications();
//   // // Call notify() function here
//   // notify();
// }

// void listenToNotificationStream() =>
//     notificationService.behaviorSubject.listen((payload) {
//       Navigator.push(
//           context, MaterialPageRoute(builder: (context) => Allocation()));
//     });
// Future<void> notify() async {
//   await notificationService.showLocalNotification(
//       id: 0,
//       title: "EXAMCELL KMCT",
//       body: "YOU WHERE ALLOCATED NEW DUTY",
//       payload: "You just took water! Huurray!");
// }
