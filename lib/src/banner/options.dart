class BannerAdOptions {
  /// Reload the ad whenever the orientation changes. Defaults to `true`
  final bool reloadWhenOrientationChanges;

  /// Reload the ad whenever its size changes. Defaults to `true`
  final bool reloadWhenSizeChanges;

  const BannerAdOptions({
    this.reloadWhenOrientationChanges = true,
    this.reloadWhenSizeChanges = true,
  })  : assert(reloadWhenOrientationChanges != null),
        assert(reloadWhenSizeChanges != null);
}
