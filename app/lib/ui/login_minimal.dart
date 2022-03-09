// ignore: unnecessary_import
import 'dart:io';

// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:local_auth/local_auth.dart';

import '../app/app.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class Login extends StatefulWidget {
  const Login({required Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isBusy = false;
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  String? _codeVerifier;
  String? _authorizationCode;
  String? _refreshToken;
  String? _accessToken;
  String? _idToken;

  final TextEditingController _authorizationCodeTextController =
      TextEditingController();
  final TextEditingController _accessTokenTextController =
      TextEditingController();
  final TextEditingController _accessTokenExpirationTextController =
      TextEditingController();

  final TextEditingController _idTokenTextController = TextEditingController();
  final TextEditingController _refreshTokenTextController =
      TextEditingController();
  String? _userInfo;

  // get hydra details from https://kuartzo.com:444/.well-known/openid-configuration
  final String _clientId = OauthClientConstants.kuartzo.clientId;
  final String _redirectUrl = OauthClientConstants.kuartzo.redirectUrl;
  final String _issuer = OauthClientConstants.kuartzo.issuer;
  final String _discoveryUrl = OauthClientConstants.kuartzo.discoveryUrl;
  final String _postLogoutRedirectUrl =
      OauthClientConstants.kuartzo.postLogoutRedirectUrl;
  final List<String> _scopes = OauthClientConstants.kuartzo.scopes;

  final AuthorizationServiceConfiguration _serviceConfiguration =
      AuthorizationServiceConfiguration(
    authorizationEndpoint: OauthClientConstants.kuartzo.authorizationEndpoint,
    tokenEndpoint: OauthClientConstants.kuartzo.tokenEndpoint,
    endSessionEndpoint: OauthClientConstants.kuartzo.endSessionEndpoint,
  );

  // biometrics / local auth
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
    _checkBiometrics();
    _getAvailableBiometrics();
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    var authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }

  Future<void> _authenticateWithBiometrics() async {
    var authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });

      authenticated = await auth.authenticate(
          localizedReason:
              'Scan your fingerprint (or face or whatever) to authenticate',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true);

      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }

    if (!mounted) {
      return;
    }

    final message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    // provider
    final _appState = Provider.of<AppState>(context, listen: false);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Authentication/ Login'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: _isBusy,
                child: const LinearProgressIndicator(),
              ),
              // if (_supportState == _SupportState.unknown)
              //   const CircularProgressIndicator()
              // else if (_supportState == _SupportState.supported)
              //   const Text('This device is supported')
              // else
              //   const Text('This device is not supported'),
              // const Divider(height: 20),
              // Text('Can check biometrics: $_canCheckBiometrics\n'),
              // ElevatedButton(
              //   child: const Text('Check biometrics'),
              //   onPressed: _checkBiometrics,
              // ),
              // const Divider(height: 20),
              // Text('Available biometrics: $_availableBiometrics\n'),
              // ElevatedButton(
              //   child: const Text('Get available biometrics'),
              //   onPressed: _getAvailableBiometrics,
              // ),
              // const Divider(height: 20),
              // Text('Current State: $_authorized\n'),
              if (_isAuthenticating)
                ElevatedButton(
                  onPressed: _cancelAuthentication,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Text('Cancel Authentication'),
                      Icon(Icons.cancel),
                    ],
                  ),
                ),
              if (!_isAuthenticating && _authorized != 'Authorized')
                // Column(
                //   children: <Widget>[
                ElevatedButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Text('Authenticate'),
                      Icon(Icons.perm_device_information),
                    ],
                  ),
                  onPressed: _authenticate,
                ),
              // ElevatedButton(
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: <Widget>[
              //       Text(_isAuthenticating
              //           ? 'Cancel'
              //           : 'Authenticate: biometrics only'),
              //       const Icon(Icons.fingerprint),
              //     ],
              //   ),
              //   onPressed: _authenticateWithBiometrics,
              // ),
              //   ],
              // ),
              // TODO: use a boolean value here
              if (_authorized == 'Authorized')
                // Column(
                //   children: [
                ElevatedButton(
                  child: const Text('Sign in with no code exchange'),
                  onPressed: () => _signInWithNoCodeExchange(),
                ),
              ElevatedButton(
                child: const Text('Exchange code'),
                onPressed: _authorizationCode != null
                    ? () => _exchangeCode(_appState)
                    : null,
              ),
              ElevatedButton(
                child: const Text('Sign in with auto code exchange'),
                onPressed: () => _signInWithAutoCodeExchange(_appState),
              ),
              if (Platform.isIOS)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: const Text(
                      'Sign in with auto code exchange using ephemeral session (iOS only)',
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => _signInWithAutoCodeExchange(_appState,
                        preferEphemeralSession: true),
                  ),
                ),
              ElevatedButton(
                child: const Text('Refresh token'),
                onPressed:
                    _refreshToken != null ? () => _refresh(_appState) : null,
              ),
              ElevatedButton(
                child: const Text('End session'),
                onPressed: _idToken != null
                    ? () async {
                        await _endSession(_appState);
                      }
                    : null,
              ),
              const Text('authorization code'),
              TextField(
                controller: _authorizationCodeTextController,
              ),
              const Text('access token'),
              TextField(
                controller: _accessTokenTextController,
              ),
              const Text('access token expiration'),
              TextField(
                controller: _accessTokenExpirationTextController,
              ),
              const Text('id token'),
              TextField(
                controller: _idTokenTextController,
              ),
              const Text('refresh token'),
              TextField(
                controller: _refreshTokenTextController,
              ),
              const Text('test api results'),
              Text(_userInfo ?? ''),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _endSession(AppState appState) async {
    try {
      _setBusyState();
      await _appAuth.endSession(EndSessionRequest(
          idTokenHint: _idToken,
          postLogoutRedirectUrl: _postLogoutRedirectUrl,
          serviceConfiguration: _serviceConfiguration));
      _clearSessionInfo();
      appState.logout();
    } catch (_) {}
    _clearBusyState();
  }

  void _clearSessionInfo() {
    setState(() {
      _codeVerifier = null;
      _authorizationCode = null;
      _authorizationCodeTextController.clear();
      _accessToken = null;
      _accessTokenTextController.clear();
      _idToken = null;
      _idTokenTextController.clear();
      _refreshToken = null;
      _refreshTokenTextController.clear();
      _accessTokenExpirationTextController.clear();
      _userInfo = null;
    });
  }

  Future<void> _refresh(AppState appState) async {
    try {
      _setBusyState();
      final result = await _appAuth.token(TokenRequest(_clientId, _redirectUrl,
          refreshToken: _refreshToken, issuer: _issuer, scopes: _scopes));
      _processTokenResponse(appState, result);
      await _testApi(result);
    } catch (_) {
      _clearBusyState();
    }
  }

  Future<void> _exchangeCode(AppState appState) async {
    try {
      _setBusyState();
      final result = await _appAuth.token(TokenRequest(_clientId, _redirectUrl,
          authorizationCode: _authorizationCode,
          discoveryUrl: _discoveryUrl,
          codeVerifier: _codeVerifier,
          scopes: _scopes));
      _processTokenResponse(appState, result);
      await _testApi(result);
    } catch (_) {
      _clearBusyState();
    }
  }

  Future<void> _signInWithNoCodeExchange() async {
    try {
      _setBusyState();
      // use the discovery endpoint to find the configuration
      final result = await _appAuth.authorize(
        AuthorizationRequest(_clientId, _redirectUrl,
            discoveryUrl: _discoveryUrl, scopes: _scopes, loginHint: 'bob'),
      );
      // or just use the issuer
      // var result = await _appAuth.authorize(
      //   AuthorizationRequest(
      //     _clientId,
      //     _redirectUrl,
      //     issuer: _issuer,
      //     scopes: _scopes,
      //   ),
      // );
      if (result != null) {
        _processAuthResponse(result);
      }
    } catch (_) {
      _clearBusyState();
    }
  }

  Future<void> _signInWithAutoCodeExchange(AppState appState,
      {bool preferEphemeralSession = false}) async {
    try {
      _setBusyState();

      // show that we can also explicitly specify the endpoints rather than getting from the details from the discovery document
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          serviceConfiguration: _serviceConfiguration,
          scopes: _scopes,
          preferEphemeralSession: preferEphemeralSession,
        ),
      );

      // this code block demonstrates passing in values for the prompt parameter. in this case it prompts the user login even if they have already signed in. the list of supported values depends on the identity provider
      // final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
      //   AuthorizationTokenRequest(_clientId, _redirectUrl,
      //       serviceConfiguration: _serviceConfiguration,
      //       scopes: _scopes,
      //       promptValues: ['login']),
      // );

      if (result != null) {
        _processAuthTokenResponse(appState, result);
        await _testApi(result);
      }
    } catch (_) {
      _clearBusyState();
    }
  }

  void _clearBusyState() {
    setState(() {
      _isBusy = false;
    });
  }

  void _setBusyState() {
    setState(() {
      _isBusy = true;
    });
  }

  void _processAuthTokenResponse(
      AppState appState, AuthorizationTokenResponse response) {
    setState(() {
      _accessToken = _accessTokenTextController.text = response.accessToken!;
      _idToken = _idTokenTextController.text = response.idToken!;
      _refreshToken = _refreshTokenTextController.text = response.refreshToken!;
      _accessTokenExpirationTextController.text =
          response.accessTokenExpirationDateTime!.toIso8601String();
      // call appState.login
      appState.login(OAuthResponse(_accessToken, _idToken, _refreshToken,
          response.accessTokenExpirationDateTime!.toIso8601String()));
    });
  }

  void _processAuthResponse(AuthorizationResponse response) {
    setState(() {
      // save the code verifier as it must be used when exchanging the token
      _codeVerifier = response.codeVerifier;
      _authorizationCode =
          _authorizationCodeTextController.text = response.authorizationCode!;
      _isBusy = false;
    });
  }

  void _processTokenResponse(AppState appState, TokenResponse? response) {
    setState(() {
      _accessToken = _accessTokenTextController.text = response!.accessToken!;
      _idToken = _idTokenTextController.text = response.idToken!;
      _refreshToken = _refreshTokenTextController.text = response.refreshToken!;
      _accessTokenExpirationTextController.text =
          response.accessTokenExpirationDateTime!.toIso8601String();
      // call appState.login
      appState.login(OAuthResponse(_accessToken, _idToken, _refreshToken,
          response.accessTokenExpirationDateTime!.toIso8601String()));
    });
  }

  // TODO: replace with DIO api health check
  Future<void> _testApi(TokenResponse? response) async {
    // final httpResponse = await http.get(
    //     Uri.parse(OauthClientConstants.kuartzo.healthCheckApiEndpoint),
    //     headers: <String, String>{'Authorization': 'Bearer $_accessToken'});
    setState(() {
      // _userInfo = httpResponse.statusCode == 200 ? httpResponse.body : '';
      _isBusy = false;
    });
  }
}
