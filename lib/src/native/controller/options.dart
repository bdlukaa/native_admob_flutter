const int ADCHOICES_TOP_LEFT = 0;
const int ADCHOICES_TOP_RIGHT = 1;
const int ADCHOICES_BOTTOM_RIGHT = 2;
const int ADCHOICES_BOTTOM_LEFT = 3;

const int MEDIA_ASPECT_RATIO_ANY = 1;
const int MEDIA_ASPECT_RATIO_LANDSCAPE = 2;
const int MEDIA_ASPECT_RATIO_PORTRAIT = 3;
const int MEDIA_ASPECT_RATIO_SQUARE = 4;

class NativeAdOptions {
  NativeAdOptions({
    bool requestCustomMuteThisAd,
    int adChoichesPlacement,
    int mediaAspectRatio,
    VideoOptions videoOptions,
  }) {
    this.requestCustomMuteThisAd = requestCustomMuteThisAd;
    this.adChoicesPlacement = adChoicesPlacement;
    this.mediaAspectRatio = mediaAspectRatio;
    this.videoOptions = videoOptions ?? VideoOptions();
  }
  bool _requestCustomMuteThisAd = false;
  bool get requestCustomMuteThisAd => _requestCustomMuteThisAd;
  set requestCustomMuteThisAd(bool request) =>
      _requestCustomMuteThisAd = request ?? false;

  int _adChoichesPlacement = ADCHOICES_TOP_RIGHT;

  /// The AdChoices overlay is set to the top right corner by default.
  /// Apps can change which corner this overlay is rendered in by setting
  /// this property to one of the following:
  ///
  /// 1. `ADCHOICES_TOP_LEFT`
  /// 2. `ADCHOICES_TOP_RIGHT` *default*
  /// 3. `ADCHOICES_BOTTOM_RIGHT`
  /// 4. `ADCHOICES_BOTTOM_LEFT`
  int get adChoicesPlacement => _adChoichesPlacement;
  set adChoicesPlacement(int value) {
    if (value != null)
      assert(
        [
          ADCHOICES_TOP_LEFT,
          ADCHOICES_TOP_RIGHT,
          ADCHOICES_BOTTOM_RIGHT,
          ADCHOICES_BOTTOM_LEFT,
        ].contains(value),
        'The entered value is not accepted. Accepted values: 0, 1, 2, 3',
      );
    _adChoichesPlacement = value ?? 1;
  }

  int _mediaAspectRatio = MEDIA_ASPECT_RATIO_LANDSCAPE;

  /// This sets the aspect ratio for image or video to be returned for the native ad.
  /// Setting NativeMediaAspectRatio to one of the following constants will cause only
  /// ads with media of the specified aspect ratio to be returned:
  ///
  /// 1. NATIVE_MEDIA_ASPECT_RATIO_LANDSCAPE *default*
  /// 2. NATIVE_MEDIA_ASPECT_RATIO_PORTRAIT
  /// 3. NATIVE_MEDIA_ASPECT_RATIO_SQUARE
  /// 4. NATIVE_MEDIA_ASPECT_RATIO_ANY
  int get mediaAspectRatio => _mediaAspectRatio;
  set mediaAspectRatio(int aspect) {
    if (aspect != null)
      assert(
        [
          MEDIA_ASPECT_RATIO_ANY,
          MEDIA_ASPECT_RATIO_LANDSCAPE,
          MEDIA_ASPECT_RATIO_PORTRAIT,
          MEDIA_ASPECT_RATIO_SQUARE,
        ].contains(aspect),
        'The entered value is not accepted. Accepted values: 1, 2, 3, 4',
      );
  }

  VideoOptions _videoOptions = VideoOptions();
  VideoOptions get videoOptions => _videoOptions;
  set videoOptions(VideoOptions options) {
    assert(options != null, 'The video options can NOT be null');
    _videoOptions = _videoOptions.copyWith(options);
  }

  Map<String, dynamic> toJson() {
    return {
      'returnUrlsForImageAssets': false,
      'requestMultipleImages': false,
      'requestCustomMuteThisAd': requestCustomMuteThisAd ?? false,
      'adChoicesPlacement': adChoicesPlacement ?? ADCHOICES_TOP_RIGHT,
      'mediaAspectRatio': mediaAspectRatio ?? MEDIA_ASPECT_RATIO_LANDSCAPE,
      'videoOptions': (videoOptions ?? VideoOptions()).toJson(),
    };
  }
}

class VideoOptions {
  bool _startMuted = true;
  bool get startMuted => _startMuted;
  set startMuted(bool start) => _startMuted = start ?? true;

  VideoOptions copyWith(VideoOptions old) {
    if (old == null) return this;
    return VideoOptions()..startMuted = old.startMuted ?? startMuted;
  }

  Map<String, dynamic> toJson() {
    return {'startMuted': startMuted ?? false};
  }
}
