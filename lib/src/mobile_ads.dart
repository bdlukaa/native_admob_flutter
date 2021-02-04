import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'utils.dart';

class MobileAds {
  // Unit ids
  static String nativeAdUnitId;
  static String get nativeAdTestUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';
  static String get nativeAdVideoTestUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1044960115'
      : 'ca-app-pub-3940256099942544/2521693316';

  static String bannerAdUnitId;
  static String get bannerAdTestUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static String interstitialAdUnitId;
  static String get interstitialAdTestUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';
  static String get interstitialAdVideoTestUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/8691691433'
      : 'ca-app-pub-3940256099942544/5135589807';

  static String rewardedAdUnitId;
  static String get rewardedAdTestUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  static String appOpenAdUnitId;
  static String get appOpenAdTestUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/3419835294'
      : 'ca-app-pub-3940256099942544/5662855259';

  static bool _initialized = false;

  /// Check if the SDK is initialized. To initialize it, use
  /// `MobileAds.initialize()`
  static bool get isInitialized => _initialized;

  static bool _useHybridComposition = false;

  /// Check if hybrid composition is enabled on android. It's enabled by default if
  /// the android version is 19 and on iOS. Do NOT set it before `MobileAds.initialize()`.
  /// Note that on Android versions prior to Android 10 Hybrid Composition has some
  /// [performance drawbacks](https://flutter.dev/docs/development/platform-integration/platform-views?tab=android-platform-views-kotlin-tab#performance).
  ///
  /// Hybrid composition is enabled in iOS and can NOT be disabled
  ///
  /// Basic usage:
  /// ```dart
  /// MobileAds.initialize(
  ///   useHybridComposition: true,
  /// )
  /// ```
  ///
  /// For more info on hybrid composition, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize#enabling-hybrid-composition-for-android)
  static bool get useHybridComposition => _useHybridComposition;
  static set useHybridComposition(bool use) {
    assert(use != null);
    _useHybridComposition = use ?? useHybridComposition;
  }

  static int _version = 0;
  static int get osVersion => _version;

  /// Before creating any native ads, you must initalize the admob.
  /// This can be done only once, ideally at app launch. If you try to
  /// initialize it more than once, an AssertionError is thrown
  ///
  /// ```dart
  /// void main() async {
  ///   MobileAds.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// This method must be called in the main thread\
  /// You can find a complete example [here](https://github.com/bdlukaa/native_admob_flutter/blob/master/example/lib/main.dart)\
  /// For more info on intialization, read the [documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize#initialize-the-mobile-ads-sdk)
  static Future<void> initialize({
    String nativeAdUnitId,
    String bannerAdUnitId,
    String interstitialAdUnitId,
    String rewardedAdUnitId,
    String appOpenAdUnitId,
    bool useHybridComposition,
  }) async {
    assertPlatformIsSupported();
    WidgetsFlutterBinding.ensureInitialized();
    assert(
      !isInitialized,
      '''The mobile ads sdk is already initialized. It can be initialized only once
      Check if it's initialized before trying to initialize it using `MobileAds.isInitialized`
      For more info on initialization, visit https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize#initialize-the-mobile-ads-sdk''',
    );

    // Ad Ids
    MobileAds.nativeAdUnitId ??= nativeAdUnitId ?? nativeAdTestUnitId;
    debugCheckIsTestId(MobileAds.nativeAdUnitId, [
      nativeAdTestUnitId,
      nativeAdVideoTestUnitId,
    ]);
    MobileAds.bannerAdUnitId ??= bannerAdUnitId ?? bannerAdTestUnitId;
    debugCheckIsTestId(MobileAds.bannerAdUnitId, [bannerAdTestUnitId]);
    MobileAds.interstitialAdUnitId ??=
        interstitialAdUnitId ?? interstitialAdTestUnitId;
    debugCheckIsTestId(MobileAds.interstitialAdUnitId, [
      interstitialAdTestUnitId,
      interstitialAdVideoTestUnitId,
    ]);
    MobileAds.rewardedAdUnitId ??= rewardedAdUnitId ?? rewardedAdTestUnitId;
    debugCheckIsTestId(MobileAds.rewardedAdUnitId, [rewardedAdTestUnitId]);
    MobileAds.appOpenAdUnitId ??= appOpenAdUnitId ?? appOpenAdTestUnitId;
    debugCheckIsTestId(MobileAds.appOpenAdUnitId, [appOpenAdTestUnitId]);

    // Make sure the version is supported
    _version = await _pluginChannel.invokeMethod<int>('initialize');
    if (Platform.isAndroid) {
      // hybrid composition is enabled in android 19 and can't be disabled
      MobileAds.useHybridComposition =
          osVersion == 19 ? true : useHybridComposition ?? false;

      if (osVersion >= 29 && MobileAds.useHybridComposition) {
        print(
          'It is NOT recommended to use hybrid composition on Android 10 or greater. '
          'It has some performance drawbacks',
        );
      }
    } else {
      assertVersionIsSupported();
      assert(
        osVersion >= 9,
        'The required version to use the AdMOB SDk is 9 or higher',
      );
      if (!(useHybridComposition ?? true))
        print(
          'Virtual display is not avaiable on iOS. Using hybrid composition',
        );
    }
    _initialized = true;
  }

  /// Sets a list of test device IDs corresponding to test devices which will
  /// always request test ads. The test device ID for the current device is
  /// logged in logcat when the first ad request is made. Be sure to remove
  /// the code that sets these test device IDs before you release your app.
  ///
  /// [Learn more](https://github.com/bdlukaa/native_admob_flutter/wiki/Initialize#enable-test-devices)
  ///
  /// Pass null to clear the list
  static Future<void> setTestDeviceIds(List<String> ids) {
    return _pluginChannel.invokeMethod('setTestDeviceIds', {'ids': ids});
  }

  /// Returns `true` if this device will receive test ads.
  ///
  static Future<bool> isTestDevice() {
    return _pluginChannel.invokeMethod<bool>('isTestDevice');
  }

  /// For purposes of the Children's Online Privacy Protection Act (COPPA),
  /// there is a setting called "tag for child-directed treatment". By setting this tag,
  /// you certify that this notification is accurate and you are authorized to act on behalf
  /// of the owner of the app. You understand that abuse of this setting may result in
  /// termination of your Google account.
  ///
  /// As an app developer, you can indicate whether you want Google to treat your content as
  /// child-directed when you make an ad request. If you indicate that you want Google to treat
  /// your content as child-directed, we take steps to disable IBA and remarketing ads on that
  /// ad request.
  ///
  /// [Learn more](https://developers.google.com/admob/android/targeting#child-directed_setting)
  ///
  /// true = TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE\
  /// false = TAG_FOR_CHILD_DIRECTED_TREATMENT_FALSE\
  /// null = TAG_FOR_CHILD_DIRECTED_TREATMENT_UNSPECIFIED
  static Future<void> setChildDirected(bool directed) async {
    await _pluginChannel.invokeMethod('setChildDirected', {
      'directed': directed,
    });
  }

  /// You can mark your ad requests to receive treatment for users in the
  /// European Economic Area (EEA) under the age of consent. This feature is
  /// designed to help facilitate compliance with the General Data Protection
  /// Regulation (GDPR). Note that you may have other legal obligations under GDPR.
  /// Please review the European Union’s guidance and consult with your own legal counsel.
  /// Please remember that Google's tools are designed to facilitate compliance and do not
  /// relieve any particular publisher of its obligations under the law. Learn more about
  /// how the GDPR affects publishers.
  ///
  /// When using this feature, a Tag For Users under the Age of Consent in Europe (TFUA)
  /// parameter will be included in the ad request. This parameter disables personalized
  /// advertising, including remarketing, for all ad requests. It also disables requests
  /// to third-party ad vendors, such as ad measurement pixels and third-party ad servers.
  ///
  /// [Learn more](https://developers.google.com/admob/android/targeting#users_under_the_age_of_consent)
  ///
  /// Both `setChildDirected` and `setTagForUnderAgeOfConsent` should not be `true`
  /// at the same time. If they are, the child-directed setting takes precedence.
  ///
  /// true = TAG_FOR_UNDER_AGE_OF_CONSENT_TRUE\
  /// false = TAG_FOR_UNDER_AGE_OF_CONSENT_FALSE\
  /// null = TAG_FOR_UNDER_AGE_OF_CONSENT_UNSPECIFIED
  static Future<void> setTagForUnderAgeOfConsent(bool underAge) async {
    await _pluginChannel.invokeMethod('setTagForUnderAgeOfConsent', {
      'under': underAge,
    });
  }

  /// Apps can set a maximum ad content rating for their ad requests using the
  /// setMaxAdContentRating method. AdMob ads returned when this is configured
  /// have a content rating at or below that level. The possible values for this
  /// network extra are based on digital content label classifications, and must
  /// be one of the following values: 0, 1, 2, 3
  ///
  /// | Max Rating | Digital Content Label | Google Play (Android) | App Store (iOS) |
  /// | :--------: | :-------------------: | :-------------------: | :-------------: |
  /// | 0          | G                     | 3+                    | 4+              |
  /// | 1          | PG                    | 7+                    | 9+              |
  /// | 2          | T                     | 12+                   | 12+             |
  /// | 3          | MA                    | 16+, 18+              | 17+             |
  ///
  /// [Learn more](https://support.google.com/admob/answer/7562142)
  static Future<void> setMaxAdContentRating(int maxRating) async {
    assert(maxRating != null, 'Max rating must not be null');
    assert(
      [0, 1, 2, 3].contains(maxRating),
      'The provided int is not avaiable. Avaiable values: 0, 1, 2, 3',
    );
    await _pluginChannel.invokeMethod('setMaxAdContentRating', {
      'maxRating': maxRating ?? 0,
    });
  }

  /// If your app has its own volume controls (such as custom music or sound effect volumes),
  /// disclosing app volume to the Google Mobile Ads SDK allows video ads to respect app volume
  /// settings. This ensures users receive video ads with the expected audio volume.
  ///
  /// The device volume, controlled through volume buttons or OS-level volume slider, determines
  /// the volume for device audio output. However, apps can independently adjust volume levels
  /// relative to the device volume to tailor the audio experience. You can report the relative
  /// app volume to the Mobile Ads SDK through the static setAppVolume() method. Valid ad volume
  /// values range from 0.0 (silent) to 1.0 (current device volume). Here's an example of how to
  /// report the relative app volume to the SDK:
  ///
  /// ```dart
  /// MobileAds.initialize();
  /// // Set app volume to be half of current device volume.
  /// MobileAds.setAppVolume(0.5);
  /// ```
  static Future<void> setAppVolume(double volume) {
    assert(volume != null, 'The volume can NOT be null');
    assert(
        volume >= 0 && volume <= 1, 'The volume must be in bettwen of 0 and 1');
    return _pluginChannel.invokeMethod('setAppVolume', {'volume': volume ?? 1});
  }

  /// To inform the SDK that the app volume has been muted, use the `setAppMuted()` method:
  ///
  /// Unmuting the app volume reverts it to the previously set level. By default, the app
  /// volume for the Google Mobile Ads SDK is set to 1 (the current device volume).
  static Future<void> setAppMuted(bool muted) {
    assert(muted != null, 'The value can NOT be null');
    return _pluginChannel
        .invokeMethod('setAppMuted', {'muted', muted ?? false});
  }

  static const _pluginChannel = const MethodChannel('native_admob_flutter');
  static MethodChannel get pluginChannel => _pluginChannel;

}
