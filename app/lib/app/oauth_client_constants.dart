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
    required this.issuer,
    required this.redirectUrl,
    required this.postLogoutRedirectUrl,
    required this.discoveryUrl,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.endSessionEndpoint,
    required this.scopes,
    required this.healthCheckApiEndpoint,
  });

  static const OauthClientConstants kuartzo = OauthClientConstants._(
    issuer: 'https://kuartzo.com:444',
    clientId: 'oauth-pkce5',
    redirectUrl: 'com.appauth.demo://callback',
    postLogoutRedirectUrl: 'com.appauth.demo://endSession',
    // don't use deeplinks in login oauth flow
    discoveryUrl: 'https://kuartzo.com:444/.well-known/openid-configuration',
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

  // put the values into an array so that we can iterate them
  static const List<OauthClientConstants> values = [kuartzo /*, gbp, jpy*/];
}
