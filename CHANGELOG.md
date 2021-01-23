## 0.4.0

- **NEW**:
  - `rewardedAdUnitId` in `MobileAds.initialize()` is now possible
  - Implementation for `Native and Interstitial Video Ad Ids`
  - Video ad example
- **FIXED**: Rating bar size
- Removed tooltip text
- Documentation and wiki update
- Improved error messages
- Shows an warning if Production Ads are used in debug mode (`kDebugMode`)
- Version checking is done on build method now because Native and Banner Ads requires Android Api >= 19, but Interstitial and Rewarded requires Android Api >= 16. Required version for iOS is 9
- Pre-support for iOS:
  - [Required flutter version >= 1.22.0](https://flutter.dev/docs/development/platform-integration/platform-views?tab=android-platform-views-kotlin-tab#ios)
  - [Added iOS test ids getters](https://developers.google.com/admob/ios/test-ads#demo_ad_units)
  - [Target version needs to be 9 or higher](https://developers.google.com/admob/ios/quick-start#prerequisites)
  - [Updated wiki with iOS platform setup steps](https://github.com/bdlukaa/native_admob_flutter/wiki/Platform-setup#ios)

## 0.3.1

- **NEW**: `AdError` instead of only `errorCode`
- You can now `await` the `show()` method from `RewardedAd` and `InterstitialAd`
- Improved documentation
- Now disposed controllers throw an `AssertionError` if used

## 0.3.0

- **NEW**: Rewarded ads
- Removed unused methods from interstitial

## 0.2.0+1

- Banner Ad Builder is only applied if loaded

## 0.2.0

- **NEW**:
  - InterstitialAd
  - Adaptive Banner Ads

## 0.1.2+1

- Readme update
- All AdViews are documentated now
- Deprecate `SMART_BANNER`, as it's deprecated in SDK v20
  - See [this](https://developers.google.com/admob/android/migration#smart)

## 0.1.2

- **NEW**:
  - `AdSingleChildView`. Equivalent to `SingleChildView`
  - `AdExpanded`. Equivalent to `Expanded`
- Use `AdDecoration` for decorating `AdView`s
- Changed the default native ad layout builder design to make it more like [this](https://developers.google.com/admob/android/banner/adaptive#when_to_use_adaptive_banners)
- `Loading` and `Error` placeholders are now avaiable on `BannerAd`s
- Updated example app. It's more clear and more intuitive to use

## 0.1.1

- Documentation improvement

## 0.1.0

- **NEW**: BannerAds
- **BREAKING**:
  - Rename `AdEvent` to `NativeAdEvent`
  - Rename `NativeAds` to `MobileAds`
- Size is only applied to the ad, not the builder

## 0.0.8+1

- Implement ad builder

## 0.0.8

- Implement MediaContent
- Fixed mute this ad info

## 0.0.7

- **HIGHLIGHT**: Automatic support for Hybrid Composition on android
- Removed custom mute this button from native side
- Removed web implementation
- Improved readme
- Improve view size calculation and warnings

## 0.0.6+4

- Improved documentation

## 0.0.6+3

- Update the documentation
- Created the wiki

## 0.0.6+2

- Fix custom this ad reasons
- Implemented `isCustomMuteThisAdEnabled` on controller

## 0.0.6+1

- Custom mute this ad is still avaiable but you can't use a `AdView` for it

## 0.0.6

- Implementation for NativeAdOptions
  - **HIGHLIGHT**: adChoicesPlacement
  - **HIGHLIGHT**: mediaAspectRatio
  - **HIGHLIGHT**: requestCustomMuteThisAd
  - returnUrlsForImageAssets
  - requestMultipleImages
  - videoOptions
- Implement custom mute this ad
- Performance update

## 0.0.5

- Implementation for new methods
  - **HIGHLIGHT**: setChildDirected
  - **HIGHLIGHT**: setTagForUnderAgeOfConsent
  - **HIGHLIGHT**: setMaxAdContentRating
  - setAppVolume
  - setAppMuted
- Improved documentation
- Preparation for `Custom Mute this Ad` and `Native Video Ads`

## 0.0.4+1

- Portuguese translation
- Improvoved documentation
- Remove useless files

## 0.0.4

- Button text style is now customizable
- Fixed `Colors.transparent` color bug

## 0.0.3+1

- Added layout gravity
- Changed examples to support hot reload

## 0.0.3

- Remove context from builder
- Changing the layout during runtime is now supported 🥳🥳🎉

## 0.0.2

- Add Linear and Radial Gradient

## 0.0.1+1

- Fix some issues

## 0.0.1

- Initial release
