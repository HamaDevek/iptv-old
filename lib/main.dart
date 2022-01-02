import 'package:flutter/material.dart';
import 'package:iptv/utils/ads.dart';
import 'package:iptv/utils/route.dart';

void main() {
  runApp(MyApp());
  AdMobService.showHomeBannerAd();

  // SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
      title: 'M3u Iptv Player',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 255, 150, 66),
        accentColor: Color.fromARGB(255, 255, 150, 66),
        disabledColor: Color.fromARGB(255, 255, 150, 66),
        canvasColor: Colors.transparent,
      ),
      initialRoute: '/',
    );
  }
}

