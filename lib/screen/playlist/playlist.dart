import 'dart:io';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fzregex/fzregex.dart';
import 'package:fzregex/utils/pattern.dart';
import 'package:iptv/playlist_db.dart';
import 'package:iptv/screen/playlist/item_list.dart';
import 'package:iptv/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PlayListScreen extends StatefulWidget {
  @override
  _PlayListScreenState createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {
  bool isGrid = false;
  bool loading = true;
  var _focusNodePlaylistm3u = new FocusNode();
  var _focusNodeLinkm3u = new FocusNode();
  var _focusNodePlaylistm3uNew = new FocusNode();
  var _focusNodeLinkm3uNew = new FocusNode();
  List<PlaylistList> playlists = [];
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();

    refreshList();
  }

  refreshList() async {
    playlists.clear();
    final allRows = await dbHelper.queryAllRows();
    allRows.forEach((row) {
      playlists.add(PlaylistList(
        data: row,
        close: () {
          setState(() {
            loading = true;
          });
        },
        show: () {
          setState(() {
            loading = false;
          });
        },
        delete: () => deletePlaylist(row),
        edit: () => _showM3U(row),
        update: () =>updatePlaylist (row),
      ));
    });
    setState(() {});
  }

  deletePlaylist(el) async {
    String oldName = el['link'];
    await dbHelper.delete(el['_id']);
    var dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/" + oldName);
    await file.delete();
    refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: downloading
          ? Center(
              child: Container(
                height: 200,
                width: 150,
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 50,
                    ),
                    Text("Downloading... $progressString")
                  ],
                ),
              ),
            )
          : loading
              ? Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? screenHeight(context, dividedBy: 8)
                          : screenHeight(context, dividedBy: 8) + 50,
                      width: screenWidth(context),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xffFFE05D),
                            Color(0xffFF9642),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xffFF9642).withOpacity(0.5),
                            spreadRadius: 4,
                            blurRadius: 10,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).padding.top,
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  BackButton(
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Playlist",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: _showM3UNew,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenHeight(context) -
                                screenHeight(context, dividedBy: 8) -
                                MediaQuery.of(context).viewInsets.bottom
                            : screenHeight(context) -
                                screenHeight(context, dividedBy: 8) -
                                50 -
                                MediaQuery.of(context).viewInsets.bottom,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [...playlists],
                          ),
                        )),
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
        child: FloatingActionButton(
          onPressed: _showM3UNew,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  bool downloading = false;
  var progressString = "";
  m3uNew() async {
    if (_formM3UNew.currentState.validate()) {
      _formM3UNew.currentState.save();
      final find = '&type=m3u&';
      final replaceWith = '&type=m3u_plus&';
      final newM3u = _linkm3ucontrollerNew.text.replaceAll(find, replaceWith);
      try {
        Dio dio = Dio();
        var now = new DateTime.now();
        var dir = await getApplicationDocumentsDirectory();
        String nam = "m3u_${now.millisecondsSinceEpoch}.m3u";
        Navigator.of(context).pop();

        await dio.download(newM3u, "${dir.path}/" + nam,
            onReceiveProgress: (rec, total) {
          // print("Rec: $rec , Total: $total");
          setState(() {
            downloading = true;
            progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
          });
        }).then((value) async {
          Map<String, dynamic> row = {
            DatabaseHelper.columnName: _playlistm3ucontrollerNew.text,
            DatabaseHelper.columnLink: nam,
            DatabaseHelper.columnUrl: newM3u,
            DatabaseHelper.columnType: 1
          };
           await dbHelper.insert(row);
          // print('inserted row id: $id');
          _linkm3ucontrollerNew.text = "";
          _playlistm3ucontrollerNew.text = "";
          refreshList();
        });
      } catch (e) {
        var snackBar = SnackBar(
          content: Text('Update Not Successful The link may wrong or expired'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    setState(() {
      downloading = false;
      progressString = "Completed";
    });
  }

  final _formM3U = new GlobalKey<FormState>();
  TextEditingController _playlistm3ucontroller = new TextEditingController();
  TextEditingController _linkm3ucontroller = new TextEditingController();
  final _formM3UNew = new GlobalKey<FormState>();
  TextEditingController _playlistm3ucontrollerNew = new TextEditingController();
  TextEditingController _linkm3ucontrollerNew = new TextEditingController();
  _showM3U(playlist) {
    _playlistm3ucontroller.text = "${playlist['name']}";
    _linkm3ucontroller.text = "${playlist['url']}";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ), //this right here
            child: Form(
              key: _formM3U,
              child: Container(
                height: screenHeight(context, dividedBy: 2),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Update Playlist',
                              style: TextStyle(fontSize: 14),
                            ),
                            IconButton(
                                icon: Icon(
                                  FeatherIcons.xCircle,
                                  color: Color(0xff646464),
                                ),
                                onPressed: () => Navigator.of(context).pop())
                          ],
                        ),
                        Container(
                          width: screenWidth(context),
                          margin: EdgeInsets.only(bottom: 5),
                          height: 45.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: const Color(0xffFFF8CD).withOpacity(.4),
                          ),
                          child: TextFormField(
                            autocorrect: false,
                            autofocus: false,
                            focusNode: _focusNodePlaylistm3u,
                            // initialValue: name,
                            controller: _playlistm3ucontroller,
                            validator: (args) {
                              if (args.length < 1)
                                return 'Name Playlist must not be empty';
                              else
                                return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.only(left: 8, right: 8),
                              hintText: "Playlist Name",
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: Color(0xff646464),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: screenWidth(context),
                          height: 45.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: const Color(0xffFFF8CD).withOpacity(.4),
                          ),
                          child: TextFormField(
                            autocorrect: false,
                            autofocus: false,
                            focusNode: _focusNodeLinkm3u,
                            // initialValue: link,
                            controller: _linkm3ucontroller,
                            validator: (args) {
                              if (args.length < 1)
                                return 'Link M3U must not be empty';
                              else if (Fzregex.hasMatch('$args', FzPattern.url))
                                return null;
                              else
                                return 'Link M3U must be link';
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.only(left: 8, right: 8),
                              hintText: "M3U Link",
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: Color(0xff646464),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xffFF9642),
                              ),
                              child: Material(
                                child: InkWell(
                                  onTap: () {
                                    _linkm3ucontroller.text = "";
                                    _playlistm3ucontroller.text = "";
                                  },
                                  child: Container(
                                    height: 45,
                                    width: screenWidth(context, dividedBy: 6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Clear',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                color: Colors.transparent,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey,
                              ),
                              child: Material(
                                child: InkWell(
                                  onTap: () async {
                                    ClipboardData data =
                                        await Clipboard.getData('text/plain');
                                    setState(() {
                                      if (_focusNodeLinkm3u.hasFocus) {
                                        _linkm3ucontroller.text =
                                            data.text.toString();
                                      }
                                      if (_focusNodePlaylistm3u.hasFocus) {
                                        _playlistm3ucontroller.text =
                                            data.text.toString();
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 45,
                                    width: screenWidth(context, dividedBy: 6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Paste',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                color: Colors.transparent,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xff153B60),
                              ),
                              child: Material(
                                child: InkWell(
                                  onTap: () => m3u(playlist),
                                  child: Container(
                                    height: 45,
                                    width: screenWidth(context, dividedBy: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Update',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                color: Colors.transparent,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  _showM3UNew() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Form(
              key: _formM3UNew,
              child: Container(
                height: screenHeight(context, dividedBy: 2),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'New Playlist',
                              style: TextStyle(fontSize: 14),
                            ),
                            IconButton(
                                icon: Icon(
                                  FeatherIcons.xCircle,
                                  color: Color(0xff646464),
                                ),
                                onPressed: () => Navigator.of(context).pop())
                          ],
                        ),
                        Container(
                          width: screenWidth(context),
                          margin: EdgeInsets.only(bottom: 5),
                          height: 45.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: const Color(0xffFFF8CD).withOpacity(.4),
                          ),
                          child: TextFormField(
                            autocorrect: false,
                            autofocus: false,
                            focusNode: _focusNodePlaylistm3uNew,
                            // initialValue: name,
                            controller: _playlistm3ucontrollerNew,
                            validator: (args) {
                              if (args.length < 1)
                                return 'Name Playlist must not be empty';
                              else
                                return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.only(left: 8, right: 8),
                              hintText: "Playlist Name",
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: Color(0xff646464),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: screenWidth(context),
                          height: 45.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: const Color(0xffFFF8CD).withOpacity(.4),
                          ),
                          child: TextFormField(
                            autocorrect: false,
                            autofocus: false,
                            focusNode: _focusNodeLinkm3uNew,
                            // initialValue: link,
                            controller: _linkm3ucontrollerNew,
                            validator: (args) {
                              if (args.length < 1)
                                return 'Link M3U must not be empty';
                              else if (Fzregex.hasMatch('$args', FzPattern.url))
                                return null;
                              else
                                return 'Link M3U must be link';
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.only(left: 8, right: 8),
                              hintText: "M3U Link",
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: Color(0xff646464),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xffFF9642),
                                ),
                                child: Material(
                                  child: InkWell(
                                    onTap: () {
                                      _linkm3ucontrollerNew.text = "";
                                      _playlistm3ucontrollerNew.text = "";
                                    },
                                    child: Container(
                                      height: 45,
                                      width: screenWidth(context, dividedBy: 6),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Clear',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  color: Colors.transparent,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey,
                                ),
                                child: Material(
                                  child: InkWell(
                                    onTap: () async {
                                      ClipboardData data =
                                          await Clipboard.getData('text/plain');
                                      setState(() {
                                        if (_focusNodeLinkm3uNew.hasFocus) {
                                          _linkm3ucontrollerNew.text =
                                              data.text.toString();
                                        }
                                        if (_focusNodePlaylistm3uNew.hasFocus) {
                                          _playlistm3ucontrollerNew.text =
                                              data.text.toString();
                                        }
                                      });
                                    },
                                    child: Container(
                                      height: 45,
                                      width: screenWidth(context, dividedBy: 6),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Paste',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  color: Colors.transparent,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xff153B60),
                                ),
                                child: Material(
                                  child: InkWell(
                                    onTap: m3uNew,
                                    child: Container(
                                      height: 45,
                                      width: screenWidth(context, dividedBy: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Save',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  color: Colors.transparent,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  m3u(playlist) async {
    if (_formM3U.currentState.validate()) {
      _formM3U.currentState.save();
      String oldName = playlist['link'];
      final find = '&type=m3u&';
      final replaceWith = '&type=m3u_plus&';
      final newM3u = _linkm3ucontroller.text.replaceAll(find, replaceWith);
      try {
        Dio dio = Dio();
        var now = new DateTime.now();
        var dir = await getApplicationDocumentsDirectory();

        String nam = "m3u_${now.millisecondsSinceEpoch}.m3u";
        Navigator.of(context).pop();

        await dio.download(newM3u, "${dir.path}/" + nam,
            onReceiveProgress: (rec, total) {
          // print("Rec: $rec , Total: $total");
          setState(() {
            downloading = true;
            progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
          });
        }).then((value) async {
          Map<String, dynamic> row = {
            DatabaseHelper.columnId: playlist['_id'],
            DatabaseHelper.columnName: _playlistm3ucontroller.text,
            DatabaseHelper.columnLink: nam,
            DatabaseHelper.columnUrl: newM3u,
            DatabaseHelper.columnType: 1,
          };
           await dbHelper.update(row);
          // print('updated $rowsAffected row(s)');
          _linkm3ucontroller.text = "";
          _playlistm3ucontroller.text = "";
          refreshList();
          final file = File("${dir.path}/" + oldName);
          await file.delete();
        });
      } catch (e) {
        var snackBar = SnackBar(
          content: Text('Update Not Successful The link may wrong or expired'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    setState(() {
      downloading = false;
      progressString = "Completed";
    });
  }

  updatePlaylist(playlist) async {
    try {
      Dio dio = Dio();
      var dir = await getApplicationDocumentsDirectory();
      String nam = "${playlist['link']}";
      await dio.download(playlist['url'], "${dir.path}/" + nam,
          onReceiveProgress: (rec, total) {
        // print("Rec: $rec , Total: $total");
        setState(() {
          downloading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      }).then((value) async {
        refreshList();
      });
    } catch (e) {
      var snackBar = SnackBar(
        content: Text('Update Not Successful The link may wrong or expired'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      downloading = false;
      progressString = "Completed";
    });
  }

  // m3uNew() async {
  //   if (_formM3UNew.currentState.validate()) {
  //     _formM3UNew.currentState.save();
  //     Map<String, dynamic> row = {
  //       DatabaseHelper.columnName: _playlistm3ucontrollerNew.text,
  //       DatabaseHelper.columnLink: _linkm3ucontrollerNew.text,
  //       DatabaseHelper.columnType: 1
  //     };
  //     final id = await dbHelper.insert(row);
  //     downloadFile(_linkm3ucontrollerNew.text);
  //     print('inserted row id: $id');
  //     _linkm3ucontrollerNew.text = "";
  //     _playlistm3ucontrollerNew.text = "";
  //     Navigator.of(context).pop();
  //     refreshList();
  //   }
  // }
}
