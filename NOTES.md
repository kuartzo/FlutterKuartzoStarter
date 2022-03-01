# NOTES

## Create Ory Hydra OAuth2 Client

```shell
$ DOMAIN="https://kuartzo.com"
$ APP_ID="oauth-pkce-kuartzo-app"
# APP_NAME="oauth-pkce-kuartzo-app"
$ ANDROID_SCHEME="com.appauth.demo"
$ ANDROID_HOST="deeplinks"
$ docker-compose -f quickstart.yml exec hydra \
    hydra clients create \
    --endpoint ${DOMAIN}:445 \
    --id ${APP_ID} \
    --token-endpoint-auth-method none \
    --response-types code,id_token \
    --grant-types authorization_code,refresh_token \
    --scope openid,profile,email,offline_access \
    --callbacks ${DOMAIN}:810/loginredirect,${ANDROID_SCHEME}://${ANDROID_HOST}/callback,${ANDROID_SCHEME}://${ANDROID_HOST}/endSession \
    --post-logout-callbacks ${DOMAIN}:810/endredirect,${ANDROID_SCHEME}://${ANDROID_HOST}/endSession \
    --allowed-cors-origins ${DOMAIN}:810
# get client
$ curl -s -X GET "http://localhost:4445/clients/${APP_ID}" | jq
```
    
## Test DeepLinks

```shell
# settings
$ adb -s 192.168.1.171:43431 shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "com.appauth.demo://deeplinks/settings"'
# details/1
$ adb -s 192.168.1.171:43431 shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "com.appauth.demo://deeplinks/details/1"'
# cart
$ adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "com.appauth.demo://deeplinks/cart"'
# callback
$ adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "com.appauth.demo://deeplinks/callback"'

$ adb shell -s 192.168.1.171:43431 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "com.appauth.demo://weblinks/callback?code=py6V1XlOAczAoQb6mZ56hBW2Lwxn6aqpmSZqKWh-1zI.aXE4DeCw9uKJRUIlxaOmUPwi8UCnTB7_yanun0qkBko&scope=openid+profile+email+offline_access&state=2FHW7odtTEcGC_-EPfhYVg"'
```

## Migrate OAUth2 Login to App

1. find `com.raywenderlich.navigation_app` replace with `com.appauth.demo_app`
2. find `com.raywenderlich.navigationApp` replace with `com.appauth.demoApp`

##  Fix OAuth2 Redirect with DeepLinks and navigation 2.0

problem redirect to `/login` deeplink

seems that after change `appAuthRedirectScheme: 'com.redirectScheme.comm'` to `appAuthRedirectScheme: 'com.appauth.demo'` and with deeplinks disabled `// initPlatformState();` oauth redirect starts to work with old `oauth-pkce5` tested client

`app/lib/app/oauth_client_constants.dart`

```dart
  static const OauthClientConstants kuartzo = OauthClientConstants._(
    issuer: 'https://kuartzo.com:444',
    clientId: 'oauth-pkce5',
    redirectUrl: 'com.appauth.demo://callback',
    postLogoutRedirectUrl: 'com.appauth.demo://endSession',
    // clientId: 'oauth-pkce-kuartzo-app',
    // redirectUrl: 'com.appauth.demo://deeplinks/callback',
    // postLogoutRedirectUrl: 'com.appauth.demo://deeplinks/endSession',
```

`app/android/app/build.gradle`

```
{
    ...
    defaultConfig {
        ...
        // place correct redirectScheme~
        manifestPlaceholders = [
            appAuthRedirectScheme: 'com.redirectScheme.comm',
            applicationName: "android.app.Application"
        ]
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig signingConfigs.debug
        }
    }
}
```

```
{
    ...
    defaultConfig {
        ...
        // place correct redirectScheme~
        manifestPlaceholders = [
            appAuthRedirectScheme: 'com.appauth.demo'
        ]
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig signingConfigs.debug
            manifestPlaceholders = [applicationName: "android.app.Application"]
        }
        debug {
            manifestPlaceholders = [applicationName: "android.app.Application"]
        }
        build{
            manifestPlaceholders = [applicationName: "android.app.Application"]
        }
    }
}
```

try enabled deeplinks uncomment `initPlatformState();`

it works with deepLinks, great

now try uncomment deepLink in `AndroidManifest.xml`

change `app/android/app/src/main/AndroidManifest.xml` to 

```xml
    <!-- Deep Linking -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!-- Note: scheme matching in the Android framework is case-sensitive, unlike the RFC. As a result, you should always specify schemes using lowercase letters. -->
        <data
            android:scheme="com.appauth.demoapp"
            android:host="deeplinks" />
    </intent-filter>
</activity>
```

run app and test some deeplinks with

```shell
# details/1
$ adb -s 192.168.1.171:43431 shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "com.appauth.demo://deeplinks/details/1"'
```

## Find the Magix Trick to put Callbak working

is just don't use deeplinks in callback ex `com.appauth.demo://deeplinks/callback` will not work because it will pass into `app/lib/router/router_delegate.dart` in method `void parseRoute(Uri uri)`, and that is the reason why we lost oauth flow and redirect, if we use `com.appauth.demo://callback` like we use in `oauth-pkce5` it work without issues, some persistence, lucky and some dispair always help

to prove that will fail change

`app/lib/app/oauth_client_constants.dart`

```dart
  static const OauthClientConstants kuartzo = OauthClientConstants._(
    issuer: 'https://kuartzo.com:444',
    // clientId: 'oauth-pkce5',
    // redirectUrl: 'com.appauth.demo://callback',
    // postLogoutRedirectUrl: 'com.appauth.demo://endSession',
    clientId: 'oauth-pkce-kuartzo-app',
    redirectUrl: 'com.appauth.demo://deeplinks/callback',
    postLogoutRedirectUrl: 'com.appauth.demo://deeplinks/endSession',
```

and try, we see that it will pass in `app/lib/router/router_delegate.dart` in method `void parseRoute(Uri uri)` losting the flow

```dart
  // Parse Deep Link URI
  void parseRoute(Uri uri) {
    ...
      switch (path) {
        ...
        case 'login':
        case 'callback':
          replaceAll(LoginPageConfig);
```

done with login flow at last......until next hole we have road to walk again