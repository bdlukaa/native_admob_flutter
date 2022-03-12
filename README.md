<div>
  <h1 align="center">native_admob_flutter</h1>
  <p align="center" >
    <a title="Discord" href="https://discord.gg/674gpDQUVq">
      <img src="https://img.shields.io/discord/809528329337962516?label=discord&logo=discord" />
    </a>
    <a title="Pub" href="https://pub.dartlang.org/packages/native_admob_flutter" >
      <img src="https://img.shields.io/pub/v/native_admob_flutter.svg?style=popout&include_prereleases" />
    </a>
    <a title="Github License">
      <img src="https://img.shields.io/github/license/bdlukaa/native_admob_flutter" />
    </a>
    <a title="PRs are welcome">
      <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" />
    </a>
  </p>
Easy-to-make ads in Flutter with Google's AdMob SDK.\
English | [Português](README-PT.md)

</div>

# ⚠️ Deprecated

The project is now archived. Reasons are documented below:

- **Flutter Platform Views**: This plugin will never be good enough if the flutter platform views don't work correctly: Virtual Display (`AndroidView`) should work fine, but the gestures are mapped and performed progamatically, which isn't allowed by the admob policy and can make your account be banned. Hybrid Composition, on the other hand, is unperformatic, buggy and can let to several crashes (by 03/2022) - see [open issues](https://github.com/flutter/flutter/issues?q=is%3Aopen+is%3Aissue+label%3A%22a%3A+platform-views%22+sort%3Areactions-%2B1-desc). I know that several improvements are being done to Hybrid Composition, but it's currently not usable in production;
- **Google Mobile Ads**: This plugin uses the same native implementation (Hybrid Composition) as [google_mobile_ads](https://pub.dev/packages/google_mobile_ads) - the ads plugin maintained by the Google Ads Team themselves -, which I believe they'll be able to maintain it better than me;
- **Poor iOS support**: ([#58](https://github.com/bdlukaa/native_admob_flutter/issues/58)) **I** don't have a macOS to be able to develop for iOS. All the current iOS implementation was done by the community itself. Hybrid Composition on iOS has the same issue as on Android - see [open issues](https://github.com/flutter/flutter/issues?q=is%3Aopen+is%3Aissue+label%3A%22a%3A+platform-views%22+sort%3Areactions-%2B1-desc+label%3Aplatform-ios) - as well, which makes your app unusable.

## Get started

To get started with Native Ads for Flutter, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki)

✔️ Native Ads (Android-only)\
✔️ Banner Ads\
✔️ Interstitial Ads\
✔️ Rewarded Ads\
✔️ App Open Ads\
✔️ Rewarded Intersitital Ads

### [Supported platforms](https://github.com/bdlukaa/native_admob_flutter/wiki/Platform-setup)

AdMOB only supports ads on mobile. Web and desktop are out of reach

✔️ Android\
✔️ iOS (Huge thanks to [@clemortel](https://github.com/clemortel))

## Issues and feedback

Please file issues, bugs, or feature requests in our [issue tracker](https://github.com/bdlukaa/native_admob_flutter/issues/new).

To contribute a change to this plugin open a [pull request](https://github.com/bdlukaa/native_admob_flutter/pulls).
