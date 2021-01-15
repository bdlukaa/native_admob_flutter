import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

class BannerAds extends StatefulWidget {
  const BannerAds({Key key}) : super(key: key);

  @override
  _BannerAdsState createState() => _BannerAdsState();
}

class _BannerAdsState extends State<BannerAds>
    with AutomaticKeepAliveClientMixin {
  Widget child;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (child != null) return child;
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => child = SizedBox());
        await Future.delayed(Duration(milliseconds: 20));
        setState(() => child = null);
      },
      child: ListView(
        children: [
          BannerAd(
            loading: Text('loading'),
            error: Text('error'),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
