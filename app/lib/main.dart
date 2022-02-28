import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

import 'app/app.dart';
// barrel files
import 'router/router.dart';

void main() {
  runApp(MyApp(
    key: UniqueKey(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({required Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appState = AppState();
  // Define instances of ShoppingRouterDelegate and ShoppingParser
  // to use in MaterialApp.router, they are required for Navigator 2.0
  late ShoppingRouterDelegate _delegate;
  final _parser = ShoppingParser();
  // declare back button dispatcher
  late ShoppingBackButtonDispatcher _backButtonDispatcher;
  // deeplinks _linkSubscription is a StreamSubscription for listening to incoming links. Call .cancel() on it to dispose of the stream.
  late StreamSubscription _linkSubscription;
  // constants
  // final OauthClientConstants _oauthConstants = OauthClientConstants.kuartzo;

  _MyAppState() {
    // Create the delegate with the appState field
    _delegate = ShoppingRouterDelegate(_appState);
    // Set up the initial route of this app to be the Splash page using setNewRoutePath.
    _delegate.setNewRoutePath(SplashPageConfig);
    // initialize backButtonDispatcher
    _backButtonDispatcher = ShoppingBackButtonDispatcher(_delegate);
  }

  @override
  void initState() {
    super.initState();
    // deepLinks
    initPlatformState();
  }

  @override
  void dispose() {
    // dispose linkSubscription
    _linkSubscription.cancel();
    super.dispose();
  }

  // deepLinks : Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Attach a listener to the Uri links stream
    // Initialize StreamSubscription by listening for any deep link events.
    _linkSubscription = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      setState(() {
        // Have the app's delegate parse the uri and then navigate using the previously defined parseRoute.
        if (uri != null) {
          _delegate.parseRoute(uri);
        }
      });
    }, onError: (Object err) {
      print('Got error $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => _appState,
      // Since Navigator 2.0 is backward-compatible with Navigator 1.0,
      // the easiest way to start with Navigator 2.0 is to use MaterialApp's
      // MaterialApp.router(...) constructor. This requires you to provide instances of a
      // RouterDelegate and a RouteInformationParser as the ones discussed above.
      child: MaterialApp.router(
        title: 'Navigation App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerDelegate: _delegate,
        routeInformationParser: _parser,
        backButtonDispatcher: _backButtonDispatcher,
        // backButtonDispatcher: RootBackButtonDispatcher(),
      ),
    );
  }
}
