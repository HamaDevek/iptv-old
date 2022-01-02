import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';

class AdMobService {
  static String getAdMobAppId() {
    if (Platform.isIOS) {
      return '';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-9864273947312704~7437246558';
    }
    return null;
  }

  static String _getBannerAdId() {
    if (Platform.isIOS) {
      return '';
    } else if (Platform.isAndroid) {
      return "ca-app-pub-9864273947312704/8107986938";
    }
    return null;
  }

  String getInterstitialAdId() {
    if (Platform.isIOS) {
      return '';
    } else if (Platform.isAndroid) {
      return "";
    }
    return null;
  }

  InterstitialAd getNewTripInterstitial() {
    return InterstitialAd(
      adUnitId: getInterstitialAdId(),
      listener: (MobileAdEvent event) {
        // print("InterstitialAd event is $event");
      },
    );
  }

  static BannerAd _homeBannerAd;

  static BannerAd _getHomePageBannerAd() {
    return BannerAd(
      adUnitId: _getBannerAdId(),
      size: AdSize.banner,
    );
    // return BannerAd(adUnitId: BannerAd.testAdUnitId, size: AdSize.smartBanner);
  }

  static void showHomeBannerAd() {
    if (_homeBannerAd == null) {
      FirebaseAdMob.instance.initialize(appId: getAdMobAppId());
      _homeBannerAd = _getHomePageBannerAd();
      _homeBannerAd
        ..load()
        ..show(anchorType: AnchorType.bottom, anchorOffset: 0.0);
    }
  }

  static void hideHomeBannerAd() {
    _homeBannerAd?.dispose();
    _homeBannerAd = null;
  }
}
