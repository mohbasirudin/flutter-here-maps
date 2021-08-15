import 'package:flutter/material.dart';
import 'package:flutter_here_maps/controller_main.dart';
import 'package:flutter_here_maps/page_main.dart';
import 'package:get/get.dart';
import 'package:here_sdk/core.dart';

void main() {
  SdkContext.init(IsolateOrigin.main);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: "/page_main",
      getPages: [
        GetPage(
          name: "/page_main",
          page: () => PageMain(),
          binding: BindingMain(),
        ),
      ],
    );
  }
}
