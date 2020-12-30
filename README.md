# native_admob_flutter

Easy-to-make native ads in flutter.

## Platform support

- [x] Android
- [ ] iOS

Google only supports native ads on mobile. Web and desktop are out of reach

## ⚠️WARNING⚠️
- This is NOT production ready. You may find some issues
- Hot reload is NOT supported while building your layouts, neither changing them dynamically

# Initialize

Before creating any native ads, you must initalize the admob. It can be initialized only once:

```dart
void main() async {
  // Add this line if you will initialize it before runApp
  WidgetsFlutterBinding.ensureInitialized();
  // default admob app id: ca-app-pub-3940256099942544/2247696110
  /* await */ NativeAds.initialize('your-admob-app-id');
  runApp(MyApp());
}
```

## Always test with test ads

When building and testing your apps, make sure you use test ads rather than live, production ads. Failure to do so can lead to suspension of your account.

The easiest way to load test ads is to use our dedicated test ad unit ID for Native Advanced on Android:

`ca-app-pub-3940256099942544/2247696110`

It's been specially configured to return test ads for every request, and you're free to use it in your own apps while coding, testing, and debugging. Just make sure you replace it with your own ad unit ID before publishing your app.

For more information about how the Mobile Ads SDK's test ads work, see [Test Ads](https://developers.google.com/admob/android/test-ads).

Learn how to create your own native ads unit ids [here](https://support.google.com/admob/answer/7187428?hl=en&ref_topic=7384666)

## When to request ads
Applications displaying native ads are free to request them in advance of when they'll actually be displayed. In many cases, this is the recommended practice. An app displaying a list of items with native ads mixed in, for example, can load native ads for the whole list, knowing that some will be shown only after the user scrolls the view and some may not be displayed at all.

⭐Note⭐: While prefetching ads is a great technique, it's important that publishers not keep old ads around too long without displaying them. Any ad objects that have been held for longer than an hour without being displayed should be discarded and replaced with new ads from a new request.

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

You can use each provided view only once. `headline` and `attribuition` are required to be in the view by google

```dart
AdLayoutBuilder myCustomLayoutBuilder = (ratingBar, media, icon, headline,
    advertiser, body, price, store, attribuition, button) {
  return AdLinearLayout(
    margin: EdgeInsets.all(10),
    borderRadius: AdBorderRadius.all(10),
    // The first linear layout width needs to be extended to the
    // parents height, otherwise the children won't fit good
    width: MATCH_PARENT,
    children: [
      AdLinearLayout(
        children: [
          icon,
          AdLinearLayout(
            children: [
              headline,
              AdLinearLayout(
                children: [attribuition, advertiser],
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
  attribuition: AdTextView(
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
| Attribuition   | AdTextView      | Indicate that the ad is an ad                                             |       Yes        |            Yes            |
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
          print('add rendered');
          break;
        case AdEvent.clicked;
          print('clicked');
          break
        default:
          break;
      }
  });
}

// Use the controller in the NativeAd
Widget build(BuildContext context) {
  return NativeAd(controller: controller);
}

// Dispose the controller. 
// You can't use the it again once it's disposed
@override
void dispose() {
  super.dispose();
  controller.dispose();
}
```

# TODO:
- [iOS support](https://developers.google.com/admob/ios/native/start)
- Add button press effect
- Support hot reload