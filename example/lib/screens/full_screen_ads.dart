import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

InterstitialAd interstitialAd = InterstitialAd()..load();

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        FlatButton(
          child: Text('Show interstitial ad'),
          color: Colors.amber,
          onPressed: () async {
            // Load only if not loaded
            if (!interstitialAd.isLoaded) await interstitialAd.load();
            if (interstitialAd.isLoaded) interstitialAd.show();
          },
        ),
        FlatButton(
          child: Text('Show rewarded ad'),
          color: Colors.redAccent,
          onPressed: () async {
            (await RewardedAd.createAndLoad()).show();
          },
        ),
        Spacer(),
      ],
    );
  }

}
