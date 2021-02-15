/// The events a full screen ad can receive. Listen
/// to the events using `fullScreenAd.onEvent.listen((event) {})`.
///
/// Avaiable events:
///   - loading (When the ad starts loading)
///   - loaded (When the ad is loaded)
///   - loadFailed (When the ad failed to load)
///   - showed (When the ad showed successfully)
///   - showFailed (When it failed on showing)
///   - closed (When the ad is closed)
///
/// Useful links:
///   - https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-app-open-ad#ad-events
///   - https://github.com/bdlukaa/native_admob_flutter/wiki/Creating-an-interstitial-ad#ad-events
enum FullScreenAdEvent {
  /// Called when the ad starts loading. This event is usually thrown by `ad.load()`
  loading,

  /// Called when the ad is loaded. This event is usually thrown by `ad.load()`
  loaded,

  /// Called when the load failed. This event is usually thrown by `ad.load()`
  ///
  /// Attempting to load a new ad from the `loadFailed` event is strongly discouraged.
  /// If you must load an ad from this event, limit ad load retries to avoid
  /// continuous failed ad requests in situations such as limited network connectivity.
  loadFailed,

  /// Called when the ad is closed. The same as `await ad.show()`
  closed,

  /// Called when it failed on showing. This event is usually thrown by `ad.show()`
  ///
  /// Attempting to show the ad again from the `showFailed` event is strongly discouraged.
  /// If you must show the ad from this event, limit ad show retries to avoid
  /// continuous failed attempts in situations such as limited network connectivity.
  showFailed,

  /// Called when it showed successfully. This event is usually thrown by `ad.show()`
  showed,
}
