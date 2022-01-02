import 'package:flutter/material.dart';
import 'package:iptv/screen/channel/chennal.dart';
import 'package:iptv/screen/channel/grouped_chennal.dart';
import 'package:iptv/screen/channel/single_group_channel.dart';
import 'package:iptv/screen/player/player.dart';
import 'package:iptv/screen/playlist/playlist.dart';
import 'package:iptv/screen/start/start.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => StartScreen());
      case '/playlist':
        return MaterialPageRoute(builder: (_) => PlayListScreen());
      case '/player':
        return MaterialPageRoute(builder: (_) => Players(index: args));
      case '/group':
        return MaterialPageRoute(
            builder: (_) => GroupedChannel(playlist: args));
      case '/list/channel':
        return MaterialPageRoute(
            builder: (_) => ListChannel(listChannel: args));
      case '/play/group/channel':
        return MaterialPageRoute(
            builder: (_) => ListChannel(listChannel: args));
      case '/all':
        return MaterialPageRoute(
            builder: (_) => SingleGroupedChannels(m3u: args));
        return _errorRoute();
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
