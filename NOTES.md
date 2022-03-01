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

problem redirect to `/login` weblink

get 
location:com.appauth.demo://weblinks/callback?code=py6V1XlOAczAoQb6mZ56hBW2Lwxn6aqpmSZqKWh-1zI.aXE4DeCw9uKJRUIlxaOmUPwi8UCnTB7_yanun0qkBko&scope=openid+profile+email+offline_access&state=2FHW7odtTEcGC_-EPfhYVg
      but keeps in same screen seems a deep link problem or a sort of

      the problem of keeps stoped on redirect was bad android:scheme after change to android:scheme="com.appauth.demo" it redirect to splash

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
