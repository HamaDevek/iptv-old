import 'package:flutter/material.dart';
import 'package:iptv/screen/channel/grouped_chennal.dart';
import 'package:iptv/screen/player/player_group.dart';
import 'package:iptv/utils/utils.dart';

class SingleGroupedChannels extends StatefulWidget {
  final m3u;

  const SingleGroupedChannels({Key key, this.m3u}) : super(key: key);
  @override
  _SingleGroupedChannelsState createState() =>
      _SingleGroupedChannelsState(this.m3u);
}

class _SingleGroupedChannelsState extends State<SingleGroupedChannels> {
  bool loading = true;
  final m3u;

  TextEditingController _searchController = new TextEditingController();
  List<ListItemM3u> channels = [];

  _SingleGroupedChannelsState(this.m3u);
  @override
  void initState() {
    super.initState();
    resfresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? SingleChildScrollView(
              child: Column(
                children: [
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
                                onFieldSubmitted: (e) => onSearchTextChanged(e),
                                // onChanged: (e) => onSearchTextChanged(e),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: screenHeight(context) - 150,
                    child: ListView.builder(
                        itemCount: channels.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return InkWell(
                            onTap: () => onClickIPTV(channels[index]),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(0xffFFE05D),
                                child: Text(
                                  "IPTV",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black38),
                                ),
                              ),
                              title: Text('${channels[index].title}'),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
    );
  }

  List<ListItemM3u> _searchResult = [];

  onSearchTextChanged(String text) async {
    _searchResult.clear();

    if (text.isEmpty) {
      resfresh();
      setState(() {});
      return;
    }
    channels.forEach((element) {
      if (element.title.toLowerCase().contains(text) ||
          element.title.toLowerCase().contains(text))
        _searchResult.add(element);
    });
    channels.clear();
    _searchResult.forEach((el) {
      channels.add(el);
    });
    setState(() {});
  }

  resfresh() {
    channels.clear();
    for (final entry in m3u) {
      channels.add(ListItemM3u(
          group: null, image: "", link: entry.link, title: entry.title));
    }
    setState(() {});
  }

  onClickIPTV(el) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerGroup(
          index: el,
          playlist: channels,
        ),
      ),
    ).whenComplete(() => enableRotation());
  }
}
