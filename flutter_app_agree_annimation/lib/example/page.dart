import 'package:flutter/material.dart';
import 'package:flutter_app_agree_annimation/agreerouter/agrrerouter.dart';

@AgreeRoute(url:"agree://flutter/pageA")
class page extends StatelessWidget{
  final AgreeRouteOption agreeRouteOption;
  page(this.agreeRouteOption);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Text('测试'),
    );
  }
  }
