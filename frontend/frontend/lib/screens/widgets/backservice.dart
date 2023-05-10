// import 'package:flutter/cupertino.dart'
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class BackGround extends StatefulWidget {
  const BackGround({Key? key}) : super(key: key);

  @override
  State<BackGround> createState() => _BackGroundState();
}

class _BackGroundState extends State<BackGround> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(onPressed: (){
              FlutterBackgroundService().invoke('setAsBackground');
            }, child: Text('Background')),
            ElevatedButton(onPressed: (){
              FlutterBackgroundService().invoke('setAsForeground');
            }, child: Text('foreground')),
            ElevatedButton(onPressed: () async{
              final service = FlutterBackgroundService();
              var isRunning = await service.isRunning();
              if (isRunning){
                service.invoke('stopService');

              }else{
                service.startService();
              }
            }, child: Text('start'))
          ],
        ),
      ),
    );
  }
}
