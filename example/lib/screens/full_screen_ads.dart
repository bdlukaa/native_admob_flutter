import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

final interstitialAd = InterstitialAd();
final interstitialVideoAd = InterstitialAd()
  ..load(unitId: MobileAds.interstitialAdVideoTestUnitId);

final rewardedAd = RewardedAd()..load();

final AppOpenAd appOpenAd = AppOpenAd()..load();
final rewardedInterstitial = RewardedInterstitialAd()..load();

class FullScreenAds extends StatefulWidget {
  const FullScreenAds({Key? key}) : super(key: key);

  @override
  _FullScreenAdsState createState() => _FullScreenAdsState();
}

class _FullScreenAdsState extends State<FullScreenAds> {
  @override
  void initState() {
    if (!interstitialAd.isLoaded) interstitialAd.load();
    interstitialAd.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case FullScreenAdEvent.closed:
          // Here is a handy place to load a new interstitial after displaying the previous one
          interstitialAd.load();
          // Do not show an ad here
          break;
        default:
          break;
      }
    });
    appOpenAd.onEvent.listen((e) => print(e));

    rewardedAd.onEvent.listen((e) {
      print('rewarded event $e');
    });
    rewardedInterstitial.onEvent.listen((e) {
      print('rewarded interstitial event $e');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await interstitialAd.load();
        await interstitialVideoAd.load(
            unitId: MobileAds.interstitialAdVideoTestUnitId);
        await rewardedAd.load(force: true);
        await appOpenAd.load(force: true);
      },
      child: ListView(
        shrinkWrap: true,
        children: [
          TextButton(
            child: Text('Show interstitial ad'),
            onLongPress: () => interstitialAd.load(force: true),
            onPressed: () async {
              // Load only if not loaded
              if (!interstitialAd.isAvailable) await interstitialAd.load();
              if (interstitialAd.isAvailable) {
                await interstitialAd.show();

                /// You can also load a new ad here, because the `show()` will
                /// only complete when the ad gets closed
                // interstitialAd.load();
              }
            },
          ),
          TextButton(
            child: Text('Show interstitial video ad'),
            onLongPress: () => interstitialVideoAd.load(
              unitId: MobileAds.interstitialAdVideoTestUnitId,
              force: true,
            ),
            onPressed: () async {
              // Load only if not loaded
              if (!interstitialVideoAd.isAvailable)
                await interstitialVideoAd.load(
                  unitId: MobileAds.interstitialAdVideoTestUnitId,
                );
              if (interstitialVideoAd.isAvailable) {
                await interstitialVideoAd.show();
                interstitialVideoAd.load(
                  unitId: MobileAds.interstitialAdVideoTestUnitId,
                );
              }
            },
          ),
          TextButton(
            child: Text('Show rewarded ad'),
            onLongPress: () => rewardedAd.load(force: true),
            onPressed: () async {
              if (!rewardedAd.isAvailable) await rewardedAd.load();
              await rewardedAd.show();
              rewardedAd.load();
            },
          ),
          TextButton(
            child: Text('Show rewarded interstitial ad'),
            onLongPress: () => rewardedInterstitial.load(force: true),
            onPressed: () async {
              if (!rewardedInterstitial.isAvailable)
                await rewardedInterstitial.load();
              await rewardedInterstitial.show();
              rewardedInterstitial.load();
            },
          ),
          TextButton(
            child: Text('Show App Open Ad'),
            onLongPress: () => appOpenAd.load(force: true),
            onPressed: () async {
              if (!appOpenAd.isAvailable) await appOpenAd.load();
              if (appOpenAd.isAvailable) {
                await appOpenAd.show();
                appOpenAd.load();
              }
            },
          ),
        ],
      ),
    );
  }
}
