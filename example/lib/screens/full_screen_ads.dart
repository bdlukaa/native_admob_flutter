import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

final interstitialAd = InterstitialAd()..load();
final interstitialVideoAd =
    InterstitialAd(MobileAds.interstitialAdVideoTestUnitId)..load();

final AppOpenAd appOpenAd = AppOpenAd(Duration(seconds: 5))..load();

class FullScreenAds extends StatefulWidget {
  const FullScreenAds({Key key}) : super(key: key);

  @override
  _FullScreenAdsState createState() => _FullScreenAdsState();
}

class _FullScreenAdsState extends State<FullScreenAds> {
  @override
  void initState() {
    interstitialAd.load();
    interstitialAd.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case InterstitialAdEvent.closed:
          // Here is a handy place to load a new interstitial after displaying the previous one
          interstitialAd.load();
          break;
        default:
          break;
      }
    });
    appOpenAd.onEvent.listen((e) => print(e));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlatButton(
          child: Text('Show interstitial ad'),
          color: Colors.yellow,
          onPressed: () async {
            // Load only if not loaded
            if (!interstitialAd.isLoaded) await interstitialAd.load();
            if (interstitialAd.isLoaded) {
              await interstitialAd.show();

              /// You can also load a new ad here, because the `show()` will
              /// only complete when the ad gets closed
              // interstitialAd.load();
            }
          },
        ),
        FlatButton(
          child: Text('Show interstitial video ad'),
          color: Colors.amber,
          onPressed: () async {
            // Load only if not loaded
            if (!interstitialVideoAd.isLoaded) await interstitialVideoAd.load();
            if (interstitialVideoAd.isLoaded) {
              await interstitialVideoAd.show();
              interstitialVideoAd.load();
            }
          },
        ),
        FlatButton(
          child: Text('Show rewarded ad'),
          color: Colors.redAccent,
          onPressed: () async {
            (await RewardedAd.createAndLoad()).show();
          },
        ),
        FlatButton(
          child: Text('Show App Open Ad'),
          color: Colors.lime,
          onPressed: () async {
            if (!appOpenAd.isAvaiable) await appOpenAd.load();
            if (appOpenAd.isAvaiable) {
              await appOpenAd.show();
              print('dismissed');
              appOpenAd.load();
            }
          },
        ),
      ],
    );
  }
}
