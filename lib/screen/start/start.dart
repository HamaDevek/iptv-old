import 'dart:io';

import 'package:dio/dio.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fzregex/fzregex.dart';
import 'package:fzregex/utils/pattern.dart';
import 'package:iptv/playlist_db.dart';
import 'package:iptv/utils/ads.dart';
import 'package:iptv/utils/storage_class.dart';
import 'package:iptv/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
  }

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formM3U = new GlobalKey<FormState>();
  final _formStream = new GlobalKey<FormState>();
  var _focusNodeSingleStream = new FocusNode();
  var _focusNodePlaylistm3u = new FocusNode();
  var _focusNodeLinkm3u = new FocusNode();
  TextEditingController _singleStreamcontroller = new TextEditingController();
  TextEditingController _playlistm3ucontroller = new TextEditingController();
  TextEditingController _linkm3ucontroller = new TextEditingController();
  String phone = "+9647510252971";
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    List<MethodModel> data = [
      MethodModel('M3U URL', FeatherIcons.link, _showM3U),
      MethodModel('LOCAL FILE', FeatherIcons.folder, localFile),
      MethodModel('SINGLE STREAM', FeatherIcons.playCircle, _showStream),
      MethodModel(
          'PLAYLIST',
          FeatherIcons.list,
          () => Navigator.of(context)
              .pushNamed('/playlist')
              .whenComplete(() => enableRotation())),
    ];
    // print(MediaQuery.of(context).);
    return WillPopScope(
      onWillPop: () {
        return new Future(() {
          SystemNavigator.pop();
          return false;
        });
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            Center(
              child: Container(
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
              ),
            ),
            downloading
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
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  const url =
                                      'https://api.whatsapp.com/send?phone=+9647510252971';
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    'To get IPTV, Contact us Via WhatsApp : +964 751 025 2971',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xffFFF8CD),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: screenHeight(context, dividedBy: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xffFFF8CD).withOpacity(.3),
                                ),
                                child: GridView.builder(
                                  itemCount: data.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: (orientation ==
                                                  Orientation.portrait)
                                              ? 2
                                              : 3),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      onTap: data[index].onClick,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Icon(
                                                data[index].icon,
                                                color: Color(0xffFFF8CD),
                                                size: 40,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Center(
                                              child: Text(
                                                data[index].name,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Color(0xffFFF8CD),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Color(0xff153B60),
                                    ),
                                    child: Material(
                                      child: InkWell(
                                        onTap: () => Navigator.of(context)
                                            .pushNamed('/playlist')
                                            .whenComplete(
                                                () => enableRotation()),
                                        child: Container(
                                          height: 50,
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Playlist',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _showM3U() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
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
                              'New  Playlist',
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
                                    onTap: m3u,
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

  _showStream() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Form(
              key: _formStream,
              child: Container(
                height: screenHeight(context, dividedBy: 2.4),
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
                              'Single Link Stream',
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
                            focusNode: _focusNodeSingleStream,
                            autofocus: false,
                            controller: _singleStreamcontroller,
                            validator: (args) {
                              if (args.length < 1)
                                return 'Link Stream must not be empty';
                              else
                                return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.only(left: 8, right: 8),
                              hintText: "Link Stream",
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
                                      _singleStreamcontroller.text = "";
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
                                        _singleStreamcontroller.text = data.text
                                            .toString(); // this will paste "copied text" to textFieldController
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
                                    onTap: stream,
                                    child: Container(
                                      height: 45,
                                      width: screenWidth(context, dividedBy: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Show',
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

  // m3u() async {
  //   if (_formM3U.currentState.validate()) {
  //     _formM3U.currentState.save();
  //     Map<String, dynamic> row = {
  //       DatabaseHelper.columnName: _playlistm3ucontroller.text,
  //       DatabaseHelper.columnLink: _linkm3ucontroller.text,
  //       DatabaseHelper.columnType: 1
  //     };
  //     final id = await dbHelper.insert(row);
  //     print('inserted row id: $id');
  //     _linkm3ucontroller.text = "";
  //     _playlistm3ucontroller.text = "";
  //     Navigator.of(context).pop();
  //   }
  // }
  bool downloading = false;
  var progressString = "";
  m3u() async {
    if (_formM3U.currentState.validate()) {
      _formM3U.currentState.save();

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
            DatabaseHelper.columnName: _playlistm3ucontroller.text,
            DatabaseHelper.columnLink: nam,
            DatabaseHelper.columnUrl: newM3u,
            DatabaseHelper.columnType: 1
          };
          await dbHelper.insert(row);
          // print('inserted row id: $id');
          _linkm3ucontroller.text = "";
          _playlistm3ucontroller.text = "";
          Navigator.of(context)
              .pushNamed('/playlist')
              .whenComplete(() => enableRotation());
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

  stream() {
    if (_formStream.currentState.validate()) {
      _formStream.currentState.save();
      Navigator.of(context).pop();
      Navigator.of(context)
          .pushNamed('/player', arguments: _singleStreamcontroller.text)
          .whenComplete(() {
        AdMobService.showHomeBannerAd();
        enableRotation();
      });
      _singleStreamcontroller.text = "";
    }
  }

  localFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['m3u'],
    );
    String path = await Storage().localPath;
    if (result != null) {
      var now = new DateTime.now();
      PlatformFile fileinfo = result.files.first;
      File file = File(result.files.single.path);
      String realPath =
          "m3u_${now.millisecondsSinceEpoch}.${fileinfo.extension}";
      file.copy("$path/$realPath");

      Map<String, dynamic> row = {
        DatabaseHelper.columnName: fileinfo.name,
        DatabaseHelper.columnLink: realPath,
        DatabaseHelper.columnType: 2
      };
      await dbHelper.insert(row);
      Navigator.of(context)
          .pushNamed('/playlist')
          .whenComplete(() => enableRotation());
      // print('inserted row id: $id');
    } else {
      // User canceled the picker
    }
  }
}

class MethodModel {
  final name;
  final icon;
  final onClick;
  MethodModel(this.name, this.icon, this.onClick);
}
