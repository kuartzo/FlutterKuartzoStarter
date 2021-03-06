import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../router/ui_pages.dart';

const String loggedInKey = 'loggedIn';
const String accessTokenKey = 'accessToken';
const String idTokenKey = 'idToken';
const String refreshTokenKey = 'refreshToken';
const String accessTokenExpirationDateTimeKey = 'accessTokenExpirationDateTime';

// defines what types of page states the app can be in.
// If the app is in the none state, nothing needs to be done.
// If it is in the addPage state, then a page needs to be added.
// To pop a page, set the page state to pop.
enum PageState { none, addPage, addAll, addWidget, pop, replace, replaceAll }

// wraps several items that allow the router to handle a page action.
class PageAction {
  PageState state;
  // The page, pages and widget are all optional fields
  // and each are used differently depending on the page state
  PageConfiguration? page;
  List<PageConfiguration>? pages;
  Widget? widget;

  PageAction(
      {this.state = PageState.none,
      this.page = null,
      this.pages = null,
      this.widget = null});
}

class OAuthResponse {
  String? accessToken;
  String? idToken;
  String? refreshToken;
  String? accessTokenExpirationDateTime;

  OAuthResponse(this.accessToken, this.idToken, this.refreshToken,
      this.accessTokenExpirationDateTime);
}

// AppState. This class holds the logged-in flag, shopping cart items and current page action
class AppState extends ChangeNotifier {
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  bool _splashFinished = false;
  bool get splashFinished => _splashFinished;

  final cartItems = [];

  // ignore: prefer_const_constructors
  final _storage = FlutterSecureStorage();

  OAuthResponse? _oAuthResponse;
  OAuthResponse? get oAuthResponse => _oAuthResponse;

  PageAction _currentAction = PageAction();
  PageAction get currentAction => _currentAction;
  set currentAction(PageAction action) {
    _currentAction = action;
    notifyListeners();
  }

  AppState() {
    getLoggedInState();
  }

  void resetCurrentAction() {
    _currentAction = PageAction();
  }

  void addToCart(String item) {
    cartItems.add(item);
    notifyListeners();
  }

  void removeFromCart(String item) {
    cartItems.add(item);
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }

  void setSplashFinished() {
    // Set the splash state to be finished
    _splashFinished = true;
    // If the user is logged in, show the list page.
    if (_loggedIn) {
      _currentAction =
          PageAction(state: PageState.replaceAll, page: ListItemsPageConfig);
    }
    // Otherwise show the login page.
    else {
      _currentAction =
          PageAction(state: PageState.replaceAll, page: LoginPageConfig);
    }
    // By setting the current action and calling notifyListeners,
    // you will trigger a state change and the router will update
    // its list of pages based on the current app state.
    notifyListeners();
  }

  void login(OAuthResponse oAuthResponse) {
    _loggedIn = true;
    _oAuthResponse = oAuthResponse;
    saveLoginState(loggedIn, oAuthResponse);
    _currentAction =
        PageAction(state: PageState.replaceAll, page: ListItemsPageConfig);
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    saveLoginState(loggedIn);
    _currentAction =
        PageAction(state: PageState.replaceAll, page: LoginPageConfig);
    notifyListeners();
  }

  void saveLoginState(bool loggedIn, [OAuthResponse? oAuthResponse]) async {
    await _storage.write(key: loggedInKey, value: loggedIn ? 'true' : 'false');
    if (loggedIn) {
      await _storage.write(
          key: accessTokenKey,
          value: oAuthResponse?.accessToken ?? '',
          aOptions: _getAndroidOptions());
      await _storage.write(
          key: idTokenKey,
          value: oAuthResponse?.idToken ?? '',
          aOptions: _getAndroidOptions());
      await _storage.write(
          key: refreshTokenKey,
          value: oAuthResponse?.refreshToken ?? '',
          aOptions: _getAndroidOptions());
      await _storage.write(
          key: accessTokenExpirationDateTimeKey,
          value: oAuthResponse?.accessTokenExpirationDateTime ?? '',
          aOptions: _getAndroidOptions());
    } else {
      await _storage.deleteAll();
    }
  }

  void getLoggedInState() async {
    final allValues = await _storage.readAll(aOptions: _getAndroidOptions());
    if (allValues.containsKey(loggedInKey)) {
      _loggedIn = allValues[loggedInKey] == 'true';
      if (_loggedIn) {
        _oAuthResponse = OAuthResponse(
            allValues[accessTokenKey],
            allValues[idTokenKey],
            allValues[refreshTokenKey],
            allValues[accessTokenExpirationDateTimeKey]);
        print('idToken: ${_oAuthResponse?.idToken}');
      }
    } else {
      _loggedIn = false;
    }
  }

  // secure storage
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
}
