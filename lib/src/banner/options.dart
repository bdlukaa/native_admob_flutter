class BannerAdOptions {
  /// Reload the ad whenever its size changes. Defaults to `true`
  final bool reloadWhenSizeChanges;

  /// Reload the ad whenever its unit id changes. Defaults to `true`
  final bool reloadWhenUnitIdChanges;

  const BannerAdOptions({
    this.reloadWhenSizeChanges = true,
    this.reloadWhenUnitIdChanges = true,
  })  : assert(reloadWhenSizeChanges != null),
        assert(reloadWhenUnitIdChanges != null);
}
