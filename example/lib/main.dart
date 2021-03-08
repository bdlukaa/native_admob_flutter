import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

import 'screens/native_ads.dart';
import 'screens/full_screen_ads.dart';
import 'screens/banner_ads.dart';

void main() async {
  /// Make sure you add this line here, so the plugin can access the native side
  WidgetsFlutterBinding.ensureInitialized();

  /// Make sure to initialize the MobileAds sdk. It returns a future
  /// that will be completed as soon as it initializes
  await MobileAds.initialize();
  // This is my device id. Ad yours here
  MobileAds.setTestDeviceIds(['9345804C1E5B8F0871DFE29CA0758842']);

  /// Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // appOpenAd.show();
    return MaterialApp(
      title: 'Native Ads Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Init the controller
  final bannerController = BannerAdController();

  /// The banner height
  // double _bannerAdHeight = 0;

  @override
  void initState() {
    super.initState();
    bannerController.onEvent.listen((e) {
      final event = e.keys.first;
      // final info = e.values.first;
      switch (event) {
        case BannerAdEvent.loaded:
          // setState(() => _bannerAdHeight = (info as int)?.toDouble());
          break;
        default:
          break;
      }
    });
    bannerController.load();
  }

  @override
  void dispose() {
    bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.deepPurple,
        appBar: AppBar(
          title: Text('Ads demo'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.navigate_next),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text('Native Ads')),
                    body: NativeAds(),
                  ),
                ));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [NativeAds(), BannerAds(), FullScreenAds()],
              ),
            ),

            /// Here's an example of how you can use a BannerAd in the
            /// bottom of the screen and above the navigation bar,
            /// since it's the recommended way. You can move this widget
            /// to the top of the list ([]) to use it in the top.
            /// Make sure to use the adaptive banner size (default) to
            /// the banner ad fit the best
            ///
            /// Sometimes an banner ad can have a black background, that's
            /// expected. Make sure to add an opaque background to your banner
            /// ad (using builder or whatever)
            BannerAd(controller: bannerController),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.blue,
          child: TabBar(
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: 'Native Ads'),
              Tab(text: 'Banner Ads'),
              Tab(text: 'Full Screen Ads'),
            ],
          ),
        ),
      ),
    );
  }
}
