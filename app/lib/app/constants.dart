class OauthClientConstants {
  final String clientId;
  final String redirectUrl;
  final String issuer;
  final String discoveryUrl;
  final String postLogoutRedirectUrl;
  final String authorizationEndpoint;
  final String tokenEndpoint;
  final String endSessionEndpoint;
  final List<String> scopes;
  final String healthCheckApiEndpoint;

  // use private constructor so that we can only create
  // instances inside the class;
  // the `const` keyword of constructor makes every instance
  // initialized with the same parameters the same copy,
  // so that we can compare them by `==` or `switch` statements
  const OauthClientConstants._({
    required this.clientId,
    required this.redirectUrl,
    required this.issuer,
    required this.discoveryUrl,
    required this.postLogoutRedirectUrl,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.endSessionEndpoint,
    required this.scopes,
    required this.healthCheckApiEndpoint,
  });

  static const OauthClientConstants kuartzo = OauthClientConstants._(
    clientId: 'oauth-pkce5',
    redirectUrl: 'com.appauth.demo://callback',
    issuer: 'https://kuartzo.com:444',
    discoveryUrl: 'https://kuartzo.com:444/.well-known/openid-configuration',
    postLogoutRedirectUrl: 'com.appauth.demo://endSession',
    authorizationEndpoint: 'https://kuartzo.com:444/oauth2/auth',
    tokenEndpoint: 'https://kuartzo.com:444/oauth2/token',
    endSessionEndpoint: 'https://kuartzo.com:444/oauth2/sessions/logout',
    scopes: <String>[
      'openid',
      'profile',
      'email',
      'offline_access',
    ],
    healthCheckApiEndpoint: 'https://demo.identityserver.io/api/test',
  );

  // static const OauthClientConstants gbp = Constants._(
  //   clientId: 'Great British Pound',
  //   redirectUrl: 'GBP',
  //   issuer: '£',
  // );

  // static const OauthClientConstants jpy = Constants._(
  //   clientId: 'Japanese Yen',
  //   redirectUrl: 'JPY',
  //   issuer: '¥',
  // );

  // put the values into an array so that we can iterate amoung them
  static const List<OauthClientConstants> values = [kuartzo /*, gbp, jpy*/];
}
