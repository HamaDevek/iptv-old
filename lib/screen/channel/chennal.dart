import 'package:flutter/material.dart';
import 'package:iptv/model/channel.dart';
import 'package:iptv/screen/channel/grouped_chennal.dart';
import 'package:iptv/screen/player/player_group.dart';
import 'package:iptv/utils/utils.dart';

class ListChannel extends StatefulWidget {
  final listChannel;

  const ListChannel({Key key, this.listChannel}) : super(key: key);
  @override
  _ListChannelState createState() => _ListChannelState(this.listChannel);
}

class _ListChannelState extends State<ListChannel> {
  bool isGrid = false;
  final listChannel;
  List<ChannelIPTV> channels = [];
  bool loading = true;
  TextEditingController _searchController = new TextEditingController();

  _ListChannelState(this.listChannel);
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
          ? Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 150,
                      ),
                      isGrid
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 20),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [...channels],
                              ),
                            )
                          : Container(
                              height: screenHeight(context) - 150,
                              child: ListView.builder(
                                  itemCount: channels.length,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    ListItemM3u temp;
                                    listChannel.forEach((key) {
                                      if (key.title == channels[index].title &&
                                          key.image == channels[index].image &&
                                          key.group == channels[index].group &&
                                          key.link == channels[index].link) {
                                        temp = key;
                                      }
                                    });
                                    return InkWell(
                                      onTap: () => onClickIPTV(temp),
                                      child: channels[index].image == ''
                                          ? ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    Color(0xffFFE05D),
                                                child: Text(
                                                  "IPTV",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black38),
                                                ),
                                              ),
                                              title: Text(
                                                  '${channels[index].title}'),
                                            )
                                          : ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    Color(0xffFFE05D),
                                                backgroundImage: NetworkImage(
                                                    '${channels[index].image}'),
                                              ),
                                              title: Text(
                                                  '${channels[index].title}'),
                                            ),
                                    );
                                  }),
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
                              // onFieldSubmitted: (e) => onSearchTextChanged(e),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: channels.length > 200
            ? null
            : FloatingActionButton(
                onPressed: () {
                  setState(() {
                    isGrid = !isGrid;
                  });
                },
                child: isGrid
                    ? Icon(Icons.format_list_bulleted, color: Colors.white)
                    : Icon(Icons.grid_view, color: Colors.white),
              ),
      ),
    );
  }

  List<ChannelIPTV> _searchResult = [];

  onSearchTextChanged(String text) async {
    _searchResult.clear();

    resfresh();
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

  onClickIPTV(el) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerGroup(
          index: el,
          playlist: listChannel,
        ),
      ),
    ).whenComplete(() {
      enableRotation();
    });
  }

  resfresh() {
    channels.clear();
    listChannel.forEach((el) {
      channels.add(ChannelIPTV(
        title: el.title,
        image: el.image,
        link: el.link,
        group: el.group,
        onClick: () => onClickIPTV(el),
      ));
    });
  }
}
