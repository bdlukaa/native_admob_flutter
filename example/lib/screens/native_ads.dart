import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

class NativeAds extends StatefulWidget {
  const NativeAds({Key? key}) : super(key: key);

  @override
  _NativeAdsState createState() => _NativeAdsState();
}

class _NativeAdsState extends State<NativeAds>
    with AutomaticKeepAliveClientMixin {
  Widget? child;

  final controller = NativeAdController();

  @override
  void initState() {
    super.initState();
    controller.load(keywords: ['valorant', 'games', 'fortnite']);
    controller.onEvent.listen((event) {
      if (event.keys.first == NativeAdEvent.loaded) {
        printAdDetails(controller);
      }
      setState(() {});
    });
  }

  void printAdDetails(NativeAdController controller) async {
    /// Just for showcasing the ability to access
    /// NativeAd's details via its controller.
    print("------- NATIVE AD DETAILS: -------");
    print(controller.headline);
    print(controller.body);
    print(controller.price);
    print(controller.store);
    print(controller.callToAction);
    print(controller.advertiser);
    print(controller.iconUri);
    print(controller.imagesUri);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (child != null) return child!;
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => child = SizedBox());
        // await controller.load(force: true);
        await Future.delayed(Duration(milliseconds: 20));
        setState(() => child = null);
      },
      child: ListView(padding: EdgeInsets.all(10), children: [
        if (controller.isLoaded)
          NativeAd(
            controller: controller,
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
            headline: AdTextView(style: TextStyle(color: Colors.black)),
            advertiser: AdTextView(style: TextStyle(color: Colors.black)),
            body:
                AdTextView(style: TextStyle(color: Colors.black), maxLines: 1),
            media: AdMediaView(height: 70, width: 120),
            button: AdButtonView(
              margin: EdgeInsets.only(left: 6, right: 6),
              textStyle: TextStyle(color: Colors.green, fontSize: 14),
              elevation: 18,
              elevationColor: Colors.amber,
            ),
          ),
        SizedBox(height: 10),
        NativeAd(
          height: 115,
          builder: (context, child) {
            return Material(
              elevation: 8,
              child: child,
            );
          },
          buildLayout: smallAdTemplateLayoutBuilder,
          // buildLayout: secondBuilder,
          loading: Text('loading'),
          error: Text('error'),
          icon: AdImageView(size: 70),
          headline: AdTextView(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
          ),
          body: AdTextView(style: TextStyle(color: Colors.black)),
          advertiser: AdTextView(style: TextStyle(color: Colors.black)),
          media: AdMediaView(height: 80, width: 120),
          button: AdButtonView(
            decoration: AdDecoration(backgroundColor: Colors.blue),
            textStyle: TextStyle(color: Colors.white),
          ),
          attribution: AdTextView(
            width: WRAP_CONTENT,
            text: 'Ad',
            decoration: AdDecoration(
              border: BorderSide(color: Colors.green, width: 2),
              borderRadius: AdBorderRadius.all(16.0),
            ),
            style: TextStyle(color: Colors.green),
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
          ),
        ),
        SizedBox(height: 10),
        NativeAd(
          height: 320,
          unitId: MobileAds.nativeAdVideoTestUnitId,
          builder: (context, child) {
            return Material(
              elevation: 8,
              child: child,
            );
          },
          buildLayout: mediumAdTemplateLayoutBuilder,
          // buildLayout: fullBuilder,
          loading: Text('loading'),
          error: Text('error'),
          icon: AdImageView(size: 40),
          headline: AdTextView(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
          ),
          body: AdTextView(style: TextStyle(color: Colors.black), maxLines: 1),
          media: AdMediaView(
            height: 170,
            width: MATCH_PARENT,
          ),
          attribution: AdTextView(
            width: WRAP_CONTENT,
            text: 'Ad',
            decoration: AdDecoration(
              border: BorderSide(color: Colors.green, width: 2),
              borderRadius: AdBorderRadius.all(16.0),
            ),
            style: TextStyle(color: Colors.green),
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
          ),
          button: AdButtonView(
            elevation: 18,
            decoration: AdDecoration(backgroundColor: Colors.blue),
            height: MATCH_PARENT,
            textStyle: TextStyle(color: Colors.white),
          ),
          ratingBar: AdRatingBarView(starsColor: Colors.white),
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
          // unitId: MobileAds.nativeAdVideoTestUnitId,
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
            elevation: 6,
            elevationColor: Colors.deepPurpleAccent,
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
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          button: AdButtonView(
            elevation: 18,
            elevationColor: Colors.amber,
            height: MATCH_PARENT,
          ),
          ratingBar: AdRatingBarView(starsColor: Colors.white),
        ),
      ]),
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
          colors: [Colors.indigo[300]!, Colors.indigo[700]!],
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
            colors: [Colors.blue[300]!, Colors.blue[900]!],
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
