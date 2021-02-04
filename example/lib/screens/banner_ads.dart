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
        padding: EdgeInsets.symmetric(vertical: 10),
        children: [
          BannerAd(
            builder: (context, child) {
              return Container(
                color: Colors.black,
                child: child,
              );
            },
            loading: Text('loading'),
            error: Text('error'),
            size: BannerSize.ADAPTIVE,
          ),
          SizedBox(height: 10),
          BannerAd(
            builder: (context, child) {
              return Container(
                color: Colors.black,
                child: child,
              );
            },
            loading: Text('loading'),
            error: Text('error'),
            // ignore: deprecated_member_use
            size: BannerSize.SMART_BANNER,
          ),
          SizedBox(height: 10),
          BannerAd(
            builder: (context, child) {
              return Container(
                color: Colors.black,
                child: child,
              );
            },
            loading: Text('loading'),
            error: Text('error'),
            size: BannerSize.BANNER,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
