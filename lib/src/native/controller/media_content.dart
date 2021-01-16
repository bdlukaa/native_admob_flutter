class MediaContent {
  /// Indicates whether the media content has video content.
  final bool hasVideoContent;

  /// The aspect ratio of the media content.
  final double aspectRatio;

  /// The duration of the video.
  final Duration duration;

  MediaContent({
    this.aspectRatio,
    this.duration,
    this.hasVideoContent,
  });

  factory MediaContent.fromJson(Map<String, dynamic> map) {
    return MediaContent(
      duration: Duration(seconds: map['duration']),
      aspectRatio: map['aspectRatio'],
      hasVideoContent: map['hasVideoContent'],
    );
  }
}
