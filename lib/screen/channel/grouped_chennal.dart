import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fzregex/fzregex.dart';
import 'package:fzregex/utils/pattern.dart';
import 'package:http/http.dart' as http;
import 'package:iptv/model/category.dart';
import 'package:iptv/utils/storage_class.dart';
import 'package:iptv/utils/utils.dart';
import 'package:m3u/m3u.dart';

class GroupedChannel extends StatefulWidget {
  final playlist;

  const GroupedChannel({Key key, this.playlist}) : super(key: key);
  @override
  _GroupedChannelState createState() => _GroupedChannelState(this.playlist);
}

class _GroupedChannelState extends State<GroupedChannel> {
  final playlist;
  final list = [];
  TextEditingController _searchController = new TextEditingController();

  bool loading = true;
  Set<String> groupSet = {};
  List<String> groupSetList = [];
  List<ListItemM3u> listByGroup = [];
  _GroupedChannelState(this.playlist);
  @override
  void initState() {
    // AdMobService.hideHomeBannerAd();

    super.initState();
    local();
    // playlist['type'] == 1 ? m3us() : local();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 150,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (_searchResult.length == 0)
                              Category(
                                category: 'ALL',
                                onClick: () {
                                  Navigator.of(context)
                                      .pushNamed('/list/channel',
                                          arguments: listByGroup)
                                      .whenComplete(() => enableRotation());
                                },
                              ),
                            if (_searchResult.length == 0)
                              ...groupSetList.map((e) {
                                return Category(
                                  category: e,
                                  onClick: () {
                                    final sub = listByGroup
                                        .where((element) => element.group == e);

                                    Navigator.of(context)
                                        .pushNamed('/list/channel',
                                            arguments: sub)
                                        .whenComplete(() => enableRotation());
                                  },
                                );
                              }).toList()
                            else
                              ..._searchResult.map((e) {
                                return Category(
                                  category: e,
                                  onClick: () {
                                    final sub = listByGroup
                                        .where((element) => element.group == e);

                                    Navigator.of(context)
                                        .pushNamed('/list/channel',
                                            arguments: sub)
                                        .whenComplete(() => enableRotation());
                                  },
                                );
                              }).toList()
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'Copyright IPTV',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xffFFE05D),
                        Color(0xffFF9642),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BackButton(
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: screenWidth(context) - 40,
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            height: 45.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: const Color(0xffFFF8CD).withOpacity(.4),
                            ),
                            child: TextFormField(
                              autocorrect: false,
                              autofocus: false,
                              controller: _searchController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.only(left: 8, right: 8),
                                hintText: "Search",
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xff646464),
                                ),
                              ),
                              onChanged: (e) => onSearchTextChanged(e),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
      // floatingActionButton: BackButton(),
    );
  }

  Future<void> m3us() async {
    setState(() {
      loading = false;
    });
    if (Fzregex.hasMatch('${playlist['link']}', FzPattern.url)) {
      try {
        var response = await http.get('${playlist['link']}');
        if (response.statusCode == 200) {
          final m3u = await M3uParser.parse(utf8.decode(response.bodyBytes));
          if (m3u[0].attributes['group-title'] != null) {
            for (final entry in m3u) {
              groupSet.add(entry.attributes['group-title']);
              listByGroup.add(ListItemM3u(
                title: entry.title,
                image: entry.attributes['tvg-logo'],
                link: entry.link,
                group: entry.attributes['group-title'],
              ));
            }
            groupSetList = groupSet.toList();
            // groupSetList.sort((a, b) => a.compareTo(b));
          } else {
            Navigator.of(context)
                .pushReplacementNamed('/all', arguments: m3u)
                .whenComplete(() => enableRotation());
          }
        } else {
          // print(response.statusCode);
        }
      } catch (e) {
        // print(e);
      }
    }
    setState(() {
      loading = true;
    });
  }

  Future<void> local() async {
    setState(() {
      loading = false;
    });
    final path = await Storage().localPath;
    final fileContent = await File('$path/${playlist['link']}').readAsString();
    final List<M3uGenericEntry> m3u = await parseFile(fileContent);
    if (m3u[0].attributes['group-title'] != null) {
      for (final entry in m3u) {
        groupSet.add(entry.attributes['group-title']);
        listByGroup.add(ListItemM3u(
          title: entry.title,
          image: entry.attributes['tvg-logo'],
          link: entry.link,
          group: entry.attributes['group-title'],
        ));
      }
      groupSetList = groupSet.toList();
      // groupSetList.sort((a, b) => a.compareTo(b));
    } else {
      Navigator.of(context)
          .pushReplacementNamed('/all', arguments: m3u)
          .whenComplete(() => enableRotation());
    }
    setState(() {
      loading = true;
    });
  }

  List<String> _searchResult = [];

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    groupSetList.forEach((el) {
      if (el.toLowerCase().contains(text) || el.toLowerCase().contains(text))
        _searchResult.add(el);
    });
    setState(() {});
  }
}

class ListItemM3u {
  final title;
  final image;
  final link;
  final group;
  ListItemM3u(
      {@required this.group,
      @required this.title,
      @required this.image,
      @required this.link});
}
