# native_admob_flutter

Easy-to-make native ads in flutter.

English | [Português](README-PT.md)

## ⚠️WARNING⚠️
- This is NOT production ready. You may find some issues
- iOS is NOT supported

# Platform setup

- [x] Android
- [ ] iOS

Google only supports native ads on mobile. Web and desktop are out of reach

## Android
Add your ADMOB App ID ([How to find it?](https://support.google.com/admob/answer/7356431)) in `AndroidManifest.xml`.

```xml
<manifest>
  <application>
    <!-- Sample AdMob app ID: ca-app-pub-3940256099942544~3347511713 -->
    <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy">
  </application>
</manifest>
```

Change `minSdkVersion` to `20`. It's the minimum sdk version required by flutter to use a PlatformView. [Learn more](https://flutter.dev/docs/development/platform-integration/platform-views#on-the-platform-side)

```groovy
android {
    defaultConfig {
        minSdkVersion 20
    }
}
```

## iOS

iOS is currently not supported (I don't have an Apple environment :/).
Feel free to [create a pull request](https://github.com/bdlukaa/native_admob_flutter/pulls) with the implementation for it :)

# Initialize

Before creating any native ads, you must initalize the admob. It can be initialized only once:

```dart
import 'package:flutter/foundation.dart';

String get admobUnitId {
  /// Always test with test ads
  if (kDebugMode)
    return 'ca-app-pub-3940256099942544/2247696110';
  else return 'your-native-ad-unit-id';
}

void main() {
  // Add this line if you will initialize it before runApp
  WidgetsFlutterBinding.ensureInitialized();
  // default native ad unit id: ca-app-pub-3940256099942544/2247696110
  NativeAds.initialize(admobUnitId);
  runApp(MyApp());
}
```

❗NOTE:❗ Unit IDs `are NOT` App IDs

## Always test with test ads

When building and testing your apps, make sure you use test ads rather than live, production ads. Failure to do so can lead to suspension of your account.

The easiest way to load test ads is to use the dedicated test ad unit ID for Native Ads on Android:

App ID: `ca-app-pub-3940256099942544~3347511713`\
Unit ID: `ca-app-pub-3940256099942544/2247696110`

It's been specially configured to return test ads for every request, and you're free to use it in your own apps while coding, testing, and debugging. Just make sure you replace it with your own ad unit ID before publishing your app.

For more information about how the Mobile Ads SDK's test ads work, see [Test Ads](https://developers.google.com/admob/android/test-ads).

Learn how to create your own native ads unit ids [here](https://support.google.com/admob/answer/7187428?hl=en&ref_topic=7384666)

## When to request ads
Applications displaying native ads are free to request them in advance of when they'll actually be displayed. In many cases, this is the recommended practice. An app displaying a list of items with native ads mixed in, for example, can load native ads for the whole list, knowing that some will be shown only after the user scrolls the view and some may not be displayed at all.

# Creating an ad

To create an ad, use the widget `NativeAd`:

```dart
NativeAd(
  buildLayout: adBannerLayoutBuilder,
  loading: Text('loading'),
  error: Text('error'),
)
```

This library provides a default layout builder: `adBannerLayoutBuilder`:
![A native ad screenshot](screenshots/default_banner_screenshot.png)

## Creating a layout builder

You can use each provided view only once. `headline` and `attribution` are required to be in the view by google

```dart
// ⭐Note⭐: The function must be a getter, otherwise hot reload will not work
AdLayoutBuilder get myCustomLayoutBuilder => (ratingBar, media, icon, headline,
    advertiser, body, price, store, attribution, button) {
  return AdLinearLayout(
    margin: EdgeInsets.all(10),
    borderRadius: AdBorderRadius.all(10),
    // The first linear layout width needs to be extended to the
    // parents width, otherwise the children won't fit good
    width: MATCH_PARENT,
    children: [
      AdLinearLayout(
        children: [
          icon,
          AdLinearLayout(
            children: [
              headline,
              AdLinearLayout(
                children: [attribution, advertiser],
                orientation: HORIZONTAL,
                width: WRAP_CONTENT,
              ),
            ],
          ),
        ],
        width: WRAP_CONTENT,
        orientation: HORIZONTAL,
        margin: EdgeInsets.all(6),
      ),
      button,
    ],
    backgroundColor: Colors.blue,
  );
};
```

🔴IMPORTANT❗🔴: You can NOT use flutter widgets to build your layouts

To use it in your NativeAd, pass it as an argument to `layoutBuilder`:

```dart
NativeAd(
  layoutBuilder: myCustomLayoutBuilder
)
```

Your layout must follow google's native ads policy & guidelines.
Learn more:

- [Native ads policies & guidelines](https://support.google.com/admob/answer/6329638?hl=en&ref_topic=7384666)
- [AdMob native ads policy compliance checklist](https://support.google.com/admob/answer/6240814?hl=en&ref_topic=7384666)

## Customizing views

All the avaiable views are customizable. To customize a view use:

```dart
NativeAd(
  layoutBuilder: ...,
  headling: AdTextView(
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
    maxLines: 1,
  ),
  attribution: AdTextView(
    width: WRAP_CONTENT, // You can use WRAP_CONTENT
    height: WRAP_CONTENT, // or MATCH_PARENT
    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
    backgroundColor: Colors.yellow,
    // The label to indicate the ad is an ad.
    // You can change it depending on the device's language
    text: 'Ad',
    margin: EdgeInsets.only(right: 2),
    maxLines: 1,
    borderRadius: AdBorderRadius.all(10),
  ),
  button: AdButtonView(
    backgroundColor: Colors.yellow,
    margin: EdgeInsets.all(6),
    borderRadius: AdBorderRadius.vertical(bottom: 10),
  ),
)
```

### Avaiable views

| Field          | Class           | Description                                                               | Always included? | Required to be displayed? |
| -------------- | --------------- | ------------------------------------------------------------------------- | :--------------: | :-----------------------: |
| Headline       | AdTextView      | Primary headline text (e.g., app title or article title).                 |       Yes        |            Yes            |
| Attribution   | AdTextView      | Indicate that the ad is an ad                                             |       Yes        |            Yes            |
| Image          | AdMediaView     | Large, primary image.                                                     |       Yes        |        Recommended        |
| Body           | AdTextView      | Secondary body text (e.g., app description or article description).       |       Yes        |        Recommended        |
| Icon           | AdImageView     | Small icon image (e.g., app store image or advertiser logo).              |        No        |        Recommended        |
| Call to action | AdButtonView    | Button or text field that encourages user to take action.                 |        No        |        Recommended        |
| Star rating    | AdRatingBarView | Rating from 0-5 that represents the average rating of the app in a store. |        No        |        Recommended        |
| Store          | AdTextView      | The app store where the user downloads the app.                           |        No        |        Recommended        |
| Price          | AdTextView      | Cost of the app.                                                          |        No        |        Recommended        |
| Advertiser     | AdTextView      | Text that identifies the advertiser (e.g., advertiser or brand name).     |        No        |        Recommended        |

[Learn more](https://support.google.com/admob/answer/6240809)

More screenshots
![](screenshots/full_native_ad_screenshot.png)
![](screenshots/banner_native_ad_screenshot.png)

The code for these can be found in [example](example/)

## Using controller and listening to events

```dart
// Init the controller
final controller = NativeAdController();

@override
void initState() {
  super.initState();
  controller.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case AdEvent.loading:
          print('loading');
          break;
        case AdEvent.loaded:
          print('loaded');
          break;
        case AdEvent.loadFailed:
          final errorCode = e.values.first;
          print('loadFailed $errorCode');
          break;
        case AdEvent.impression:
          print('ad rendered');
          break;
        case AdEvent.clicked;
          print('clicked');
          break;
        case AdEvent.muted:
          showDialog(
            ...,
            builder: (_) => AlertDialog(title: Text('Ad muted')),
          );
          break;
        default:
          break;
      }
  });
}

// Use the controller in the NativeAd
@override
Widget build(BuildContext context) {
  return NativeAd(controller: controller);
}

// Dispose the controller. 
// You can't use the it again once it's disposed
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

# TODO:
- [iOS support](https://developers.google.com/admob/ios/native/start)
- [Native Video Ads](https://developers.google.com/admob/android/native/video-ads)
- [Add elevation support](https://developer.android.com/training/material/shadows-clipping)
- Add interaction with the ad
  - Tooltips
  - Buttton press effect