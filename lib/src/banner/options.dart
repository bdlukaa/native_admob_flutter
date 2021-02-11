class BannerAdOptions {
  final bool reloadWhenOrientationChanges;
  final bool reloadWhenSizeChanges;

  const BannerAdOptions({
    this.reloadWhenOrientationChanges = true,
    this.reloadWhenSizeChanges = true,
  })  : assert(reloadWhenOrientationChanges != null),
        assert(reloadWhenSizeChanges != null);
}
