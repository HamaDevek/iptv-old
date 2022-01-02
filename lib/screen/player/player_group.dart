import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iptv/screen/channel/grouped_chennal.dart';
import 'package:iptv/utils/ads.dart';
import 'package:iptv/utils/utils.dart';
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';
import 'package:volume/volume.dart';

class PlayerGroup extends StatefulWidget {
  final index;
  final playlist;

  const PlayerGroup({Key key, this.index, this.playlist}) : super(key: key);
  @override
  _PlayerGroupState createState() =>
      _PlayerGroupState(this.index, this.playlist);
}

class _PlayerGroupState extends State<PlayerGroup> {
  final index;
  final playlist;
  ListItemM3u current;
  bool show = true;
  _PlayerGroupState(this.index, this.playlist);
  VideoPlayerController _controller;
  bool loading = false;
  double _currentSliderValue = 0;
  double _max = 0;
  int maxVol = 1;
  int currentVol = 1;
  @override
  void initState() {
    AdMobService.hideHomeBannerAd();
    SystemChrome.setEnabledSystemUIOverlays([]);
    Screen.keepOn(true);
    current = index;
    super.initState();
    initAudioStreamType();
    updateVolumes();
    _controller = VideoPlayerController.network(current.link)
      ..initialize().then((_) {
        setState(() {
          loading = true;
          _max = _controller.value.duration.inSeconds.toDouble();
        });
        _controller.play();
      });
  }

  Future<void> initAudioStreamType() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  updateVolumes() async {
    // get Max Volume
    maxVol = await Volume.getMaxVol;
    // get Current Volume
    currentVol = await Volume.getVol;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return new Future(() {
          AdMobService.showHomeBannerAd();
          return true;
        });
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: loading
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: InkWell(
                        child: VideoPlayer(_controller),
                        onTap: () {
                          setState(() {
                            show = !show;
                            _max =
                                _controller.value.duration.inSeconds.toDouble();
                          });
                        },
                      ),
                    )
                  : CircularProgressIndicator(),
            ),
            show
                ? Container(
                    height: screenHeight(context),
                    width: screenWidth(context),
                    // color: Colors.amber.withOpacity(.4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 100,
                          margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Material(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white24,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    currentVol = await Volume.getVol;
                                    Navigator.of(context).pop();
                                    AdMobService.showHomeBannerAd();
                                  },
                                  child: Container(
                                    child: Icon(Icons.keyboard_arrow_left,
                                        color: Colors.white70),
                                    height: 40,
                                    width: 40,
                                  ),
                                ),
                              ),
                              Container(
                                height: 100,
                                width: 150,
                                child: Center(
                                  child: Text(
                                    "${current.title}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white24,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? SystemChrome.setPreferredOrientations(
                                            [DeviceOrientation.landscapeLeft])
                                        : SystemChrome.setPreferredOrientations(
                                            [DeviceOrientation.portraitUp]);
                                    setState(() async {
                                      currentVol = await Volume.getVol;
                                    });
                                  },
                                  child: Container(
                                    child: Icon(
                                        MediaQuery.of(context).orientation ==
                                                Orientation.landscape
                                            ? Icons.fullscreen_exit
                                            : Icons.fullscreen,
                                        color: Colors.white70),
                                    height: 40,
                                    width: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                              color: Colors.white30),
                          height: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 180
                              : 200,
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: screenWidth(context) - 20,
                                    child: Center(
                                      child: _max != 0
                                          ? Slider(
                                              activeColor: Colors.amber,
                                              inactiveColor:
                                                  Colors.amber.withOpacity(.3),
                                              value: _currentSliderValue,
                                              min: 0,
                                              max: _max,
                                              label: _currentSliderValue
                                                  .round()
                                                  .toString(),
                                              onChanged: (double value) {
                                                setState(() {
                                                  _currentSliderValue = value;
                                                  _controller.seekTo(Duration(
                                                      seconds: value.toInt()));
                                                });
                                              },
                                            )
                                          : Container(),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: loading
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ValueListenableBuilder(
                                            valueListenable: _controller,
                                            builder: (context,
                                                VideoPlayerValue value, child) {
                                              _currentSliderValue = value
                                                  .position.inSeconds
                                                  .toDouble();
                                              return Text(
                                                Duration(
                                                        milliseconds: value
                                                            .position
                                                            .inMilliseconds)
                                                    .toString()
                                                    .substring(0, 7),
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 16),
                                              );
                                            },
                                          ),
                                          Text(
                                              _controller.value.duration
                                                  .toString()
                                                  .substring(0, 7),
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 16))
                                        ],
                                      )
                                    : Container(),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                      icon: Icon(
                                        Icons.skip_previous,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          loading = false;
                                        });
                                        int prev = -1;
                                        List<ListItemM3u> play = [...playlist];
                                        play.asMap().forEach((key, value) {
                                          if (value == current) {
                                            prev = key - 1;
                                          }
                                        });
                                        if (prev >= 0) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlayerGroup(
                                                index: play[prev],
                                                playlist: play,
                                              ),
                                            ),
                                          ).whenComplete(
                                              () => enableRotation());
                                        } else {
                                          setState(() {
                                            loading = true;
                                          });
                                        }
                                      }),
                                  IconButton(
                                      icon: Icon(
                                        Icons.replay_10,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        if (_max != 0) {
                                          setState(() {
                                            _controller.seekTo(Duration(
                                                seconds: _currentSliderValue
                                                        .toInt() -
                                                    10));
                                          });
                                        }
                                      }),
                                  IconButton(
                                      icon: Icon(
                                        _controller.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _controller.value.isPlaying
                                              ? _controller.pause()
                                              : _controller.play();
                                          if (_currentSliderValue == _max) {
                                            _currentSliderValue = 0;
                                            _controller.seekTo(Duration(
                                                seconds: _currentSliderValue
                                                    .toInt()));
                                          }
                                        });
                                      }),
                                  IconButton(
                                      icon: Icon(
                                        Icons.forward_10,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        if (_max != 0) {
                                          setState(() {
                                            _controller.seekTo(Duration(
                                                seconds: _currentSliderValue
                                                        .toInt() +
                                                    10));
                                          });
                                        }
                                      }),
                                  IconButton(
                                      icon: Icon(
                                        Icons.skip_next,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          loading = false;
                                        });
                                        int next = -1;
                                        List<ListItemM3u> play = [...playlist];
                                        play.asMap().forEach((key, value) {
                                          if (value == current) {
                                            next = key + 1;
                                          }
                                        });
                                        if (next <= play.length - 1) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlayerGroup(
                                                index: play[next],
                                                playlist: play,
                                              ),
                                            ),
                                          ).whenComplete(
                                              () => enableRotation());
                                        } else {
                                          setState(() {
                                            loading = true;
                                          });
                                        }
                                      }),
                                ],
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  trackShape: RoundedRectSliderTrackShape(),
                                  trackHeight: 2.0,
                                  valueIndicatorShape:
                                      PaddleSliderValueIndicatorShape(),
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 9),
                                  thumbColor: Colors.white,
                                  valueIndicatorColor: Colors.white,
                                  activeTrackColor: Colors.grey[500],
                                  inactiveTrackColor: Colors.white,
                                  valueIndicatorTextStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                child: Slider(
                                  value: currentVol.toDouble(),
                                  min: 0,
                                  label: '🔊',
                                  divisions: maxVol,
                                  max: maxVol.toDouble(),
                                  onChanged: (double value) {
                                    setState(() {
                                      currentVol = value.toInt();
                                      Volume.setVol(value.toInt(),
                                          showVolumeUI: ShowVolumeUI.HIDE);
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void isChange(val) {
    if (_currentSliderValue != _max) {
      setState(() {
        _currentSliderValue = val;
      });
    } else {}
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }
}
