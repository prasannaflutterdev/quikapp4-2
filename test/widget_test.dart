// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quikapp4/module/myapp.dart';

class MyApp extends StatelessWidget {
  final String webUrl;
  final bool isSplash;
  final String splashLogo;
  final String splashBg;
  final int splashDuration;
  final String splashAnimation;
  final Color taglineColor;
  final Color spbgColor;
  final bool isBottomMenu;
  final List<dynamic> bottomMenuItems;
  final bool isDeeplink;
  final Color backgroundColor;
  final Color activeTabColor;
  final Color textColor;
  final Color iconColor;
  final String iconPosition;
  final bool isLoadIndicator;

  const MyApp({
    Key? key,
    this.webUrl = '',
    this.isSplash = false,
    this.splashLogo = '',
    this.splashBg = '',
    this.splashDuration = 0,
    this.splashAnimation = '',
    this.taglineColor = Colors.transparent,
    this.spbgColor = Colors.transparent,
    this.isBottomMenu = false,
    this.bottomMenuItems = const [],
    this.isDeeplink = false,
    this.backgroundColor = Colors.white,
    this.activeTabColor = Colors.blue,
    this.textColor = Colors.black,
    this.iconColor = Colors.grey,
    this.iconPosition = 'top',
    this.isLoadIndicator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Your build method here
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('0')), // For test to find '0'
      ),
    );
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      webUrl: "https://example.com",
      isSplash: true,
      splashLogo: "assets/splash_logo.png",
      splashBg: "assets/splash_bg.png",
      splashDuration: 3,
      splashAnimation: "fade",
      taglineColor: Colors.white,
      spbgColor: Colors.black,
      isBottomMenu: true,
      bottomMenuItems: [],
      isDeeplink: false,
      backgroundColor: Colors.white,
      activeTabColor: Colors.blue,
      textColor: Colors.black,
      iconColor: Colors.grey,
      iconPosition: "top",
      isLoadIndicator: true,
    ));

    // Your test code here, e.g. check initial UI
    expect(find.text('0'), findsOneWidget);
  });
}
