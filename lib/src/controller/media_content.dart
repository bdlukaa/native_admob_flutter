class MediaContent {

  final bool hasVideoContent;

  final double aspectRatio;
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