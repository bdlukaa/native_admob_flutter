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
    // bool requestMultipleImages,
    // bool returnUrlsForImageAssets,
    int adChoichesPlacement,
    int mediaAspectRatio,
    VideoOptions videoOptions,
  }) {
    this.requestCustomMuteThisAd = requestCustomMuteThisAd;
    // this.requestMultipleImages = requestMultipleImages;
    // this.returnUrlsForImageAssets = returnUrlsForImageAssets;
    this.adChoicesPlacement = adChoicesPlacement;
    this.mediaAspectRatio = mediaAspectRatio;
    this.videoOptions = videoOptions ?? VideoOptions();
  }

  bool _returnUrlsForImageAssets = false;
  bool get returnUrlsForImageAssets => _returnUrlsForImageAssets;
  set returnUrlsForImageAssets(bool v) =>
      _returnUrlsForImageAssets = v ?? false;

  bool _requestMultipleImages = false;
  bool get requestMultipleImages => _requestMultipleImages;
  set requestMultipleImages(bool v) => _requestMultipleImages = v ?? false;

  bool _requestCustomMuteThisAd = false;
  bool get requestCustomMuteThisAd => _requestCustomMuteThisAd;
  set requestCustomMuteThisAd(bool request) =>
      _requestCustomMuteThisAd = request ?? false;

  int _adChoichesPlacement = ADCHOICES_TOP_RIGHT;
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
      'returnUrlsForImageAssets': returnUrlsForImageAssets ?? false,
      'requestMultipleImages': requestMultipleImages ?? false,
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
