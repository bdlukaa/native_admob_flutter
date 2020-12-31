import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NativeAds.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          // Create a native ad with the default style
          NativeAd(
            height: 110,
            buildLayout: adBannerLayoutBuilder,
            loading: Text('loading'),
            error: Text('error'),
          ),

          NativeAd(
            height: 100,
            buildLayout: secondBuilder,
            loading: Text('loading'),
            error: Text('error'),
            icon: AdImageView(size: 80),
            headline: AdTextView(
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            media: AdMediaView(height: 80, width: 120),
          ),

          NativeAd(
            height: 300,
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
              borderRadius: AdBorderRadius.all(10),
              text: 'Anúncio',
              border: BorderSide(color: Colors.green, width: 1),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

AdLayoutBuilder get fullBuilder => (ratingBar, media, icon, headline,
        advertiser, body, price, store, attribuition, button) {
      return AdLinearLayout(
        padding: EdgeInsets.all(10),
        // The first linear layout width needs to be extended to the
        // parents height, otherwise the children won't fit good
        width: MATCH_PARENT,
        gradient: AdLinearGradient(
          colors: [Colors.indigo[300], Colors.indigo[700]],
          orientation: AdGradientOrientation.tl_br,
        ),
        children: [
          media,
          AdLinearLayout(
            children: [
              icon,
              AdLinearLayout(children: [
                headline,
                AdLinearLayout(
                  children: [attribuition, advertiser],
                  orientation: HORIZONTAL,
                  width: WRAP_CONTENT,
                ),
              ], margin: EdgeInsets.only(left: 4)),
            ],
            width: WRAP_CONTENT,
            orientation: HORIZONTAL,
            margin: EdgeInsets.all(6),
          ),
          AdLinearLayout(
            children: [button],
            // gravity: LayoutGravity.center_horizontal,
          ),
        ],
        // backgroundColor: Colors.blue,
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
        gradient: AdRadialGradient(
          colors: [Colors.blue[300], Colors.blue[900]],
          center: Alignment(0.5, 0.5),
          radius: 1000,
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
                height: 25,
              ),
            ],
            margin: EdgeInsets.all(4),
          ),
        ],
      );
    };
