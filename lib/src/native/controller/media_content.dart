/// Class used to tell the info about the media content of a Native Ad.
/// It's usually used alongside [NativeAdController]. A media content is
/// never null.
///
/// The Media Content can be an image or a video. If you're using test ads,
/// video ads needs to be requested using the Native Video Test Ad Unit Id,
/// which you can get by calling `MobileAds.nativeAdVideoTestUnitId`
class MediaContent {
  /// Indicates whether the media content has video content (`true`) or not (`false`).
  final bool? hasVideoContent;

  /// The aspect ratio of the media content, which can be an image or a video.
  /// This usually corresponds to the aspect ratio set in `options` ([NativeAdOptions]):
  /// - MEDIA_ASPECT_RATIO_ANY: Can be any of the aspect ratios said below
  /// - MEDIA_ASPECT_RATIO_LANDSCAPE: Usually 16:9
  /// - MEDIA_ASPECT_RATIO_PORTRAIT: Usually 4:3
  /// - MEDIA_ASPECT_RATIO_SQUARE: Usually 1:1
  ///
  /// For more info, [read the documentation](https://github.com/bdlukaa/native_admob_flutter/wiki/Native-Ad-Options#mediaaspectratio)
  final double? aspectRatio;

  /// The duration of the video, if avaiable
  final Duration? duration;

  /// Creates a new [MediaContent] object
  const MediaContent({
    this.aspectRatio,
    this.duration,
    this.hasVideoContent,
  });

  /// Creates a new [MediaContent] object based on a json.
  ///
  /// This is usually by the controller to receive the
  /// info from the platform side
  static MediaContent fromJson(map) {
    return MediaContent(
      duration: Duration(
        milliseconds: (map['duration'] as double).toInt() * 100000,
      ),
      aspectRatio: map['aspectRatio'],
      hasVideoContent: map['hasVideoContent'],
    );
  }

  /// Copy [this] with the values from a new [MediaContent]
  MediaContent copyWith(MediaContent content) {
    return MediaContent(
      aspectRatio: content.aspectRatio ?? this.aspectRatio,
      duration: content.duration ?? this.duration,
      hasVideoContent: content.hasVideoContent ?? this.hasVideoContent,
    );
  }
}
