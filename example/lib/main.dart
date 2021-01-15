import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

import 'screens/native_ads.dart';
import 'screens/banner_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.initialize();
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
      debugShowCheckedModeBanner: false,
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          title: Text('Ads demo'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [Tab(text: 'Native Ads'), Tab(text: 'Banner Ads')],
          ),
        ),
        body: TabBarView(
          children: [NativeAds(), BannerAds()],
        ),
      ),
    );
  }
}
