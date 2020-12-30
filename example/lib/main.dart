import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NativeAds.initialize();
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
      body: Column(
        children: [
          // Create a native ad with the default style
          NativeAd(
            height: 110,
            buildLayout: adBannerLayoutBuilder,
            loading: Text('loading'),
            error: Text('error'),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0, 0),
                end: Alignment(1, 1),
                colors: [Colors.blue[300], Colors.blue[900]],
              ),
            ),
            child: NativeAd(
              height: 100,
              buildLayout: secondBuilder,
              loading: Text('loading'),
              error: Text('error'),
              icon: AdImageView(size: 80),
              headline: AdTextView(
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              media: AdMediaView(height: 80, width: 120),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0, 0),
                end: Alignment(1, 1),
                colors: [Colors.indigo[300], Colors.indigo[900]],
              ),
            ),
            child: NativeAd(
              height: 300,
              buildLayout: fullBuilder,
              loading: Text('loading'),
              error: Text('error'),
              icon: AdImageView(size: 40),
              headline: AdTextView(
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              media: AdMediaView(
                height: 180,
                width: MATCH_PARENT,
              ),
            ),
          )
        ],
      ),
    );
  }
}

AdLayoutBuilder fullBuilder = (ratingBar, media, icon, headline, advertiser,
    body, price, store, attribuition, button) {
  return AdLinearLayout(
    margin: EdgeInsets.all(10),
    borderRadius: AdBorderRadius.all(10),
    // The first linear layout width needs to be extended to the
    // parents height, otherwise the children won't fit good
    width: MATCH_PARENT,
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
      button,
    ],
    // backgroundColor: Colors.blue,
  );
};

AdLayoutBuilder secondBuilder = (ratingBar, media, icon, headline, advertiser,
    body, price, store, attribuition, button) {
  return AdLinearLayout(
    margin: EdgeInsets.all(10),
    borderRadius: AdBorderRadius.all(10),
    // The first linear layout width needs to be extended to the
    // parents height, otherwise the children won't fit good
    width: MATCH_PARENT,
    orientation: HORIZONTAL,
    children: [
      icon,
      AdLinearLayout(
        children: [
          headline,
          AdLinearLayout(
            children: [attribuition, advertiser, ratingBar],
            orientation: HORIZONTAL,
            width: WRAP_CONTENT,
            height: 25,
          ),
        ],
        margin: EdgeInsets.all(6),
      ),
    ],
  );
};
