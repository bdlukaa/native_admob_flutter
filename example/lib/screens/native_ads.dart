import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

class NativeAds extends StatefulWidget {
  const NativeAds({Key key}) : super(key: key);

  @override
  _NativeAdsState createState() => _NativeAdsState();
}

class _NativeAdsState extends State<NativeAds>
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
        padding: EdgeInsets.all(10),
        children: [
          NativeAd(
            height: 60,
            builder: (context, child) {
              return Material(
                elevation: 8,
                child: child,
              );
            },
            buildLayout: adBannerLayoutBuilder,
            loading: Text('loading'),
            error: Text('error'),
            icon: AdImageView(padding: EdgeInsets.only(left: 6)),
            headline: AdTextView(
              style: TextStyle(color: Colors.black),
              maxLines: 1,
            ),
            advertiser: AdTextView(style: TextStyle(color: Colors.black)),
            body: AdTextView(style: TextStyle(color: Colors.black)),
            media: AdMediaView(height: 70, width: 120),
            button: AdButtonView(
              margin: EdgeInsets.only(left: 6, right: 6),
              textStyle: TextStyle(color: Colors.green, fontSize: 14),
            ),
          ),
          SizedBox(height: 10),
          NativeAd(
            height: 100,
            builder: (context, child) {
              return Material(
                elevation: 8,
                child: child,
              );
            },
            buildLayout: secondBuilder,
            loading: Text('loading'),
            error: Text('error'),
            icon: AdImageView(size: 80),
            headline: AdTextView(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
            media: AdMediaView(height: 80, width: 120),
          ),
          SizedBox(height: 10),
          NativeAd(
            height: 300,
            builder: (context, child) {
              return Material(
                elevation: 8,
                child: child,
              );
            },
            buildLayout: fullBuilder,
            loading: Text('loading'),
            error: Text('error'),
            icon: AdImageView(size: 40),
            headline: AdTextView(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
            media: AdMediaView(
              height: 180,
              width: MATCH_PARENT,
            ),
            attribution: AdTextView(
              width: WRAP_CONTENT,
              height: WRAP_CONTENT,
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
              margin: EdgeInsets.only(right: 4),
              maxLines: 1,
              text: 'Anúncio',
              decoration: AdDecoration(
                borderRadius: AdBorderRadius.all(10),
                border: BorderSide(color: Colors.green, width: 1),
              ),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

AdLayoutBuilder get fullBuilder => (ratingBar, media, icon, headline,
        advertiser, body, price, store, attribuition, button) {
      return AdLinearLayout(
        padding: EdgeInsets.all(10),
        // The first linear layout width needs to be extended to the
        // parents height, otherwise the children won't fit good
        width: MATCH_PARENT,
        decoration: AdDecoration(
            gradient: AdLinearGradient(
          colors: [Colors.indigo[300], Colors.indigo[700]],
          orientation: AdGradientOrientation.tl_br,
        )),
        children: [
          media,
          AdLinearLayout(
            children: [
              icon,
              AdLinearLayout(children: [
                headline,
                AdLinearLayout(
                  children: [attribuition, advertiser, ratingBar],
                  orientation: HORIZONTAL,
                  width: MATCH_PARENT,
                ),
              ], margin: EdgeInsets.only(left: 4)),
            ],
            gravity: LayoutGravity.center_horizontal,
            width: WRAP_CONTENT,
            orientation: HORIZONTAL,
            margin: EdgeInsets.only(top: 6),
          ),
          AdLinearLayout(
            children: [button],
            orientation: HORIZONTAL,
          ),
        ],
      );
    };

AdLayoutBuilder get secondBuilder => (ratingBar, media, icon, headline,
        advertiser, body, price, store, attribution, button) {
      return AdLinearLayout(
        padding: EdgeInsets.all(10),
        // The first linear layout width needs to be extended to the
        // parents height, otherwise the children won't fit good
        width: MATCH_PARENT,
        orientation: HORIZONTAL,
        decoration: AdDecoration(
          gradient: AdRadialGradient(
            colors: [Colors.blue[300], Colors.blue[900]],
            center: Alignment(0.5, 0.5),
            radius: 1000,
          ),
        ),
        children: [
          icon,
          AdLinearLayout(
            children: [
              headline,
              AdLinearLayout(
                children: [attribution, advertiser, ratingBar],
                orientation: HORIZONTAL,
                width: WRAP_CONTENT,
                height: 20,
              ),
              button,
            ],
            margin: EdgeInsets.symmetric(horizontal: 4),
          ),
        ],
      );
    };
