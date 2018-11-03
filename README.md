# Getting Started with Flutter

## Install Flutter
* [Setup Instructions](https://flutter.io/setup-windows/)
1. Install [Flutter](https://flutter.io/get-started/install/) to C:\src\flutter
2. Open C:\src\flutter\packages\flutter_tools\gradle\flutter.gradle
3. Add google() to buildscript
```
buildscript {
    repositories {
		google()
        jcenter()
        maven {
            url 'https://dl.google.com/dl/android/maven2'
        }
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:3.1.2'
    }
}
```
4. Add C:\src\flutter to the user "Path" variable
5. Install [Android Studio](https://developer.android.com/studio/)
6. File > Settings > Plugins < Browse repositories
7. Type "Flutter" and install
8. Type "Android WiFi Connect" and install
9. Open VS Code
10. Extensions 
11. Type "Flutter" and install
12. Type "Material Icon Theme", Install and activate
13. Run the following command
```
flutter doctor
```

## Setting up a new project
1. Open VS Code
2. View > Command Palette
3. Type “flutter”, and select the Flutter: New Project action
4. Enter a project name (such as myapp), and press Enter
5. Create or select the parent directory for the new project folder
6. Wait for project creation to complete and the main.dart file to appear
7. Can also use the following command:
```
flutter create flutter_course
```
8. Open Android Studio and open myapp\android
9. Tools > AVD Manager > Create new Virtual Device with latest SDK version.
10. Create the following folders
```
assets
fonts
pages
widgets
models
scoped-models
```
11. In VS Code Press F5 to launch or type
```
flutter run
```
## Analyzing Code
1. Run the following command
```
flutter analyze
```

## Useful notes
* [Learn Dart](https://www.dartlang.org/)
* Ctrl+Shift+F5 = Hot Reload
* Ctrl+F5 = Hot Restart
* @override is optional
* prefix with _ for private fields.
* State widgets call build when loaded and when internal data changes.
* Stateless widgets call build when loaded and when external data changes.
* Wrap code in setState(){} which modifies state
```
 setState(() {
	_products.add('Advanved Food Tester');
});
```
* Access widget properties in state by using widget.property. No need to call setState in initState.
```
 @override
    void initState() {
      _products.add(widget.startingProduct);
      super.initState();
    }
```
* Named constructor params and optional params
```
ProductManager({this.startingProduct = 'Sweets Tester'})
```
* Optional params only
```
Products([this.products = const []])
```
* Pass functions (delegates)
```
final Function addProduct;
```
* build()  must not return null but can return container()

## Firebase Db
1. Create a new project using [Firebase](https://firebase.google.com/)
2. Database > Create Realtime Database
3. Start in test mode
4. Authentication > Set up sign-in method
5. Email/Password
6. [Firebase Auth REST API](https://firebase.google.com/docs/reference/rest/auth/)
7. Authentication > Web setup > apiKey
8. Signup
```
https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=[API_KEY]
```
9. Login
```
https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=[API_KEY]
```
10. Database > Rules to enable authentication
```
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```
## Firebase Image Storage
1. Storage >  Get Started
2. Functions >  Get Started
3. Install  
```
npm install -g firebase-tools
```
4. Run the following command
```
cd myapp
firebase login
firebase init
```
5. Use arrows to select Functions and press space and then enter
6. Select project and press enter
7. Select JavaScript as language
8. Enter n for ESLint
9. Enter y for installing dependencies
10. Add node_modules to .gitignore
11. Enable Google Cloud Storage API
12. Create a service key
13. Set auth environnment var
```
set GOOGLE_APPLICATION_CREDENTIALS="C:\keys\Flutter Products-8b49c1dd428e.json"
```
14. Install dependencies
```
npm install --save cors
npm install --save busboy
npm install --save uuid
npm install --save @google-cloud/storage
npm install --save firebase-admin
```
15. cog > Project settings > Service accounts > Generate new private key > Generate key
16. Save file in myapp\functions\{projectid}.json
17. functions\index.js
```
const functions = require('firebase-functions');
const cors = require('cors')({ origin: true });
const Busboy = require('busboy');
const os = require('os');
const path = require('path');
const fs = require('fs');
const fbAdmin = require('firebase-admin');
const uuid = require('uuid/v4');

const gcconfig = {
  projectId: 'flutter-products-43c5c',
  keyFilename: 'flutter-products-43c5c.json'
};

const {Storage} = require('@google-cloud/storage');

const gcs = new Storage(gcconfig);

fbAdmin.initializeApp({
  credential: fbAdmin.credential.cert(require('./flutter-products-43c5c.json'))
});

exports.storeImage = functions.https.onRequest((req, res) => {
  return cors(req, res, () => {
    if (req.method !== 'POST') {
      return res.status(500).json({ message: 'Not allowed.' });
    }

    if (
      !req.headers.authorization ||
      !req.headers.authorization.startsWith('Bearer ')
    ) {
      return res.status(401).json({ error: 'Unauthorized.' });
    }

    let idToken;
    idToken = req.headers.authorization.split('Bearer ')[1];

    const busboy = new Busboy({ headers: req.headers });
    let uploadData;
    let oldImagePath;

    busboy.on('file', (fieldname, file, filename, encoding, mimetype) => {
      const filePath = path.join(os.tmpdir(), filename);
      uploadData = { filePath: filePath, type: mimetype, name: filename };
      file.pipe(fs.createWriteStream(filePath));
    });

    busboy.on('field', (fieldname, value) => {
      oldImagePath = decodeURIComponent(value);
    });

    busboy.on('finish', () => {
      const bucket = gcs.bucket('flutter-products-43c5c.appspot.com');
      const id = uuid();
      let imagePath = 'images/' + id + '-' + uploadData.name;
      if (oldImagePath) {
        imagePath = oldImagePath;
      }

      return fbAdmin
        .auth()
        .verifyIdToken(idToken)
        .then(decodedToken => {
          return bucket.upload(uploadData.filePath, {
            uploadType: 'media',
            destination: imagePath,
            metadata: {
              metadata: {
                contentType: uploadData.type,
                firebaseStorageDownloadTokens: id
              }
            }
          });
        })
        .then(() => {
          return res.status(201).json({
            imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/' +
              bucket.name +
              '/o/' +
              encodeURIComponent(imagePath) +
              '?alt=media&token=' +
              id,
            imagePath: imagePath
          });
        })
        .catch(error => {
          return res.status(401).json({ error: 'Unauthorized!' });
        });
    });  
    return busboy.end(req.rawBody);
  });
});

exports.deleteImage = functions.database.ref('/products/{productId}').onDelete(snapshot => {
  const imageData = snapshot.val();
  const imagePath = imageData.imagePath;

   const bucket = gcs.bucket('flutter-products-43c5c.appspot.com');
   return bucket.file(imagePath).delete();
});
```
17. Run the following command to deploy
```
firebase deploy
```
18. Recreate database and set rules

## Http Requests, Shared preferences, Rx Dart, Map View, Location, Image Picker, MIME, Url Launcher, Launch Icons
* (flutter http)[https://pub.dartlang.org/packages/http]
* (Shared Preferences)[https://pub.dartlang.org/packages/shared_preferences]
* (Rx Dart)[https://pub.dartlang.org/packages/rxdart]
* (Map View)[https://pub.dartlang.org/packages/map_view]
* (Location)[https://pub.dartlang.org/packages/location]
* (Image Picker)[https://pub.dartlang.org/packages/image_picker]
* (mime)[https://pub.dartlang.org/packages/mime]
* (url launcher)[https://pub.dartlang.org/packages/url_launcher]
* (launcher icons)[https://pub.dartlang.org/packages/flutter_launcher_icons]
1. Modify pubspec.yml
```
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^0.1.2
  scoped_model: ^0.3.0
  http: "^0.11.3+17"
  shared_preferences: ^0.4.3
  rxdart: ^0.19.0
  map_view: ^0.0.14
  location: ^1.4.1
  image_picker: ^0.4.10
  mime: ^0.9.6+2
  url_launcher: ^4.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
    
  flutter_launcher_icons: ^0.6.1

flutter_icons:
  android: true 
  ios: true
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "#FFFAFAFA"
  adaptive_icon_foreground: "assets/icon/icon.png"
```
2. Run the following command
```
flutter packages get
```
3. Go to: https://console.developers.google.com/
4. Enable billing and enter CC details
5. Enable Maps SDK for Android
6. Enable Maps SDK for iOS
7. Enable Maps for Static Api
8. Enable Geocoding API
9. Under Credentials, choose Create Credential.
10. android\app\src\main\AndroidMainfest.xml
```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.myapp">

    <!-- The INTERNET permission is required for development. Specifically,
         flutter needs it to communicate with the running application
         to allow setting breakpoints, to provide hot reload, etc.
    -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

    <!-- io.flutter.app.FlutterApplication is an android.app.Application that
         calls FlutterMain.startInitialization(this); in its onCreate method.
         In most cases you can leave this as-is, but you if you want to provide
         additional functionality it is fine to subclass or reimplement
         FlutterApplication and put your custom class here. -->
    <application
        android:name="io.flutter.app.FlutterApplication"
        android:label="myapp"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- This keeps the window background of the activity showing
                 until Flutter renders its first frame. It can be removed if
                 there is no splash screen (such as the default splash screen
                 defined in @style/LaunchTheme). -->
            <meta-data
                android:name="io.flutter.app.android.SplashScreenUntilFirstFrame"
                android:value="true" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <activity android:name="com.apptreesoftware.mapview.MapActivity" android:theme="@style/Theme.AppCompat.Light.DarkActionBar"/>
        <meta-data android:name="com.google.android.maps.v2.API_KEY" android:value=""/>
        <meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version"/>
    </application>
</manifest>
```
11. ios\Runner\Info.plist
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>myapp</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>$(FLUTTER_BUILD_NAME)</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>$(FLUTTER_BUILD_NUMBER)</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIMainStoryboardFile</key>
	<string>Main</string>
	<key>NSLocationWhenInUseUsageDescription</key>
    <string>Using location to display on a map</string>
	<key>NSLocationAlwaysUsageDescription</key>
    <string>Using location to display on a map</string>
	<key>NSPhotoLibraryUsageDescription</key>
    <string>Product photos</string>
	<key>NSCameraUsageDescription</key>
    <string>Product photos</string>
	<key>NSMicrophoneUsageDescription</key>
    <string>Product photos</string>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<false/>
</dict>
</plist>
```
12. android\build.gradle
```
dependencies {
        classpath 'com.android.tools.build:gradle:3.1.2'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.1.2-4'
    }

subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency { details ->
            if (details.requested.group == 'com.android.support'
                    && !details.requested.name.contains('multidex') ) {
                details.useVersion "26.1.0"
            }
        }
    }
}
```
13. copy icon into assets\icon\icon.png
14. Run the following command
```
flutter pub get
flutter pub pub run flutter_launcher_icons:main
```
15. Icon directories
```
android\app\src\main\res
ios\Runner\Assets.xcassets\AppIcon.appiconset
```
16. Set application name for android in android\app\src\main\AndroidManifest.xml by setting android:label attribute
```
android:label="AppName"
```
17. Set application name for iOS in ios\Runner\Info.plist by setting the CFBundName string
```
<key>CFBundleName</key>
<string>AppName</string>
```

## Android Splash Screen
1. android\src\main\res\drawable
```
<?xml version="1.0" encoding="utf-8"?>
<!-- Modify this file to customize your launch splash screen -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
    <item android:drawable="@drawable/ic_launcher_foreground" />
    <!-- You can insert your own image assets here -->
    <!-- <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/launch_image" />
    </item> -->
</layer-list>
```

## iOS Splash Screen
1. ios\Runner\LaunchImage.imageset
2. Copy the android files and override ios files.
```
android\src\main\res\drawable\drawable-mdpi\ic_launcher_foreground.png > LaunchImage.png
android\src\main\res\drawable\drawable-hdpi\ic_launcher_foreground.png > LaunchImage@2x.png
android\src\main\res\drawable\drawable-xhdpi\ic_launcher_foreground.png > LaunchImage@3x.png
android\src\main\res\drawable\drawable-xxhdpi\ic_launcher_foreground.png > LaunchImage@4x.png
```
3. ios\Runner\LaunchImage.imageset\Contents.json
```
{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "LaunchImage.png",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "filename" : "LaunchImage@2x.png",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "filename" : "LaunchImage@3x.png",
      "scale" : "3x"
    },
    {
      "idiom" : "universal",
      "filename" : "LaunchImage@4x.png",
      "scale" : "4x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
```

## Releasing for Android
* (Android Release)[https://flutter.io/android-release/]
1. android\app\src\build.gradle applicationId "com.example.myapp" must be unique and match with package="com.example.myapp" in android\app\src\main\AndroidMainifest.xml
2. upgrade android\app\src\build.gradle defaultConfig versionCode > Internal and versionName > external each time a release is made.
3. Create a key store
```
keytool -genkey -v -keystore c:\keys\key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```
4. Create new file android\key.properties
```
storePassword=<password from previous step>
keyPassword=<password from previous step>
keyAlias=key
storeFile=C:/keys/key.jks
```
5. Add key.properties to .gitignore
6. add the following lines aboe android in android\app\main\build.gradle
```
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

android {
```
7. Replace buildTypes with the following
```
signingConfigs {
    release {
     keyAlias keystoreProperties['keyAlias']
     keyPassword keystoreProperties['keyPassword']
     storeFile file(keystoreProperties['storeFile'])
     storePassword keystoreProperties['storePassword']
  }
}
buildTypes {
  release {
    signingConfig signingConfigs.release
  }
}
```
8. Run the following command
```
flutter build apk
```
9. Outputs to the following directory
```
build\app\outputs\apk\release\app-release.apk
```
10. Go to Google Play Console

## Releasing for iOS
* (iOS Release)[https://flutter.io/ios-release/]

## /shared/result.dart
```
import 'package:flutter/material.dart';

class ApiResult<T> extends DataResult<T>
{
  final Map<String, dynamic> json;

  ApiResult({@required bool success, @required T data, @required this.json, String message = ''}) : super(success:success,data: data, message:message);
}

class DataResult<T> extends Result
{
  final T data;

 DataResult({@required bool success, @required this.data, String message = ''}) : super(success:success,message:message);
}

class Result
{
  final bool success;
  final String message;

  static Result ok([String successMessage = ''])
  {
    return Result(success: true, message: successMessage);
  }

  static Result fail(String errorMessage)
  {
    return Result(success: false, message: errorMessage);
  }

  static DataResult<T> okData<T>(T data, [String successMessage = ''])
  {
    return DataResult<T>(success: true,data: data, message: successMessage);
  }

  static DataResult<T> failData<T>(String errorMessage)
  {
    return DataResult<T>(success: false, data: null, message: errorMessage);
  }

  static ApiResult<T> okApi<T>(T data, Map<String, dynamic> json, [String successMessage = ''])
  {
    return ApiResult<T>(success: true,data: data, json:json, message: null);
  }

  static ApiResult<T> failApi<T>(T data, Map<String, dynamic> json, String errorMessage)
  {
    return ApiResult<T>(success: false, data: data, json:json, message: errorMessage);
  }

  Result({@required this.success, this.message = ''});
}
```

## /apis/base.dart
```
import 'package:http/http.dart' as http;
import '../shared/result.dart';
import 'dart:convert';

abstract class ApiBase {
  String getRequestData(Object payload) {
    return json.encode(payload);
  }

  ApiResult<Map<String, dynamic>> getResponseData(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      return Result.failApi(
          'Response statusCode ${response.statusCode.toString()}',
          response.body);
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    return Result.okApi(responseData, response.body);
  }
}
```

## /apis/product.dart
```
iimport 'package:http/http.dart' as http;
import './base.dart';

import '../shared/result.dart';
import '../dtos/product.dart';

class ProductApi extends ApiBase {
  final String baseUrl = 'https://flutter-products-43c5c.firebaseio.com';

  Future<ApiResult<List<ProductDto>>> fetchAll() async {
    var resp = await http.get('$baseUrl/products.json');

    var apiResponse = getResponseData(resp);

    if (!apiResponse.success) {
      return Result.failApi<List<ProductDto>>(
          null, apiResponse.json, apiResponse.message);
    }

    final List<ProductDto> list = [];

    if (apiResponse.data != null) {
      apiResponse.data.forEach((String id, dynamic item) {
        final ProductDto newProduct = ProductDto.fromDynamic(id, item);
        list.add(newProduct);
      });
    }

    return Result.okApi(list, apiResponse.json);
  }

  Future<ApiResult<String>> add(String userEmail, String userId, String title,
      String description, String image, double price) async {
    final payload = ProductDto(
        title: title,
        description: description,
        image: 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
        price: price,
        userEmail: userEmail,
        userId: userId);

    var resp = await http.post('$baseUrl/products.json',
        body: getRequestBody(payload));

    var apiResponse = getResponseData(resp);

    if (!apiResponse.success) {
      return Result.failApi<String>(
          null, apiResponse.json, apiResponse.message);
    }

    String id = apiResponse.json['name'];
    return Result.okApi(id, apiResponse.json);
  }

  Future<ApiResult<Map<String, dynamic>>> update(
      String id,
      String userEmail,
      String userId,
      String title,
      String description,
      String image,
      double price) async {
    final payload = ProductDto(
        title: title,
        description: description,
        image: 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
        price: price,
        userEmail: userEmail,
        userId: userId);

    var resp = await http.put('$baseUrl/products/$id.json',
        body: getRequestBody(payload));

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> delete(String id) async {
    var resp = await http.delete('$baseUrl/products/$id.json');

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }
}
```

## /dtos/product.dart
```
import 'package:flutter/material.dart';

//immutable
class ProductDto {
  final String id;
  final String title;
  final String description;
  final double price;
  final String image;

  final String userEmail;
  final String userId;

  ProductDto(
      {this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.image,
      @required this.userEmail,
      @required this.userId});

  factory ProductDto.fromDynamic(String id, dynamic json) {
    return ProductDto(
      id: id,
      title: json['title'],
      description: json['description'],
      price: json['price'],
      image: json['image'],
      userEmail: json['userEmail'],
      userId: json['userId'],
    );
  }

   Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'price': price,
        'image': image,
        'userEmail': userEmail,
        'userId': userId,
      };
}
```

## /dtos/firebase.dart
```
import 'package:flutter/material.dart';

class AuthenticationRequestDto {
  final String email;
  final String password;
  final bool returnSecureToken;

  AuthenticationRequestDto(
      {@required this.email,
      @required this.password,
      this.returnSecureToken = true});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'returnSecureToken': returnSecureToken
      };
}

class LoginResponseDto {
  final String kind;
  final String idToken;
  final String refreshToken;
  final String expiresIn;

  LoginResponseDto(
      {@required this.kind,
      @required this.idToken,
      @required this.refreshToken,
      @required this.expiresIn});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
        kind: json['kind'],
        idToken: json['idToken'],
        refreshToken: json['refreshToken'],
        expiresIn: json['expiresIn']);
  }
}

class SignupResponseDto {
  final String kind;
  final String idToken;
  final String email;
  final String refreshToken;
  final String expiresIn;
  final String localId;

  SignupResponseDto(
      {@required this.kind,
      @required this.idToken,
      @required this.email,
      @required this.refreshToken,
      @required this.expiresIn,
      @required this.localId});

  factory SignupResponseDto.fromJson(Map<String, dynamic> json) {
    return SignupResponseDto(
        kind: json['kind'],
        idToken: json['idToken'],
        email: json['email'],
        refreshToken: json['refreshToken'],
        expiresIn: json['expiresIn'],
        localId: json['localId']);
  }
}
```

## /apis/auth.dart
```
import 'package:http/http.dart' as http;
import './base.dart';

import '../shared/result.dart';
import '../dtos/firebase.dart';

class AuthApi extends ApiBase {
  final String apiKey = 'AIzaSyBezaAajSgJS53o2YnVH72MYKA8rW1QNR0';
  final String baseUrl = 'https://www.googleapis.com/identitytoolkit/v3/relyingparty';

  Future<ApiResult<SignupResponseDto>> signup(String email, String password) async {
    final payload = AuthenticationRequestDto (
      email: email,
      password: password,
      returnSecureToken: true
    );

    var resp = await http.post('$baseUrl/signupNewUser?key=$apiKey', body: getRequestBody(payload));

    var apiResponse = getResponseData(resp);

    if(!apiResponse.success)
    {
      return Result.failApi<SignupResponseDto>(null, apiResponse.json, apiResponse.message);
    }

    var dto = SignupResponseDto.fromJson(apiResponse.json);

    return Result.okApi(dto, apiResponse.json);
  }

  Future<ApiResult<LoginResponseDto>> login(String email, String password) async {
     final payload = AuthenticationRequestDto (
      email: email,
      password: password,
      returnSecureToken: true
    );

    var resp = await http.post('$baseUrl/verifyPassword?key=$apiKey', body: getRequestBody(payload));

    var apiResponse = getResponseData(resp);

    if(!apiResponse.success)
    {
      return Result.failApi<LoginResponseDto>(null, apiResponse.json, apiResponse.message);
    }

    var dto = LoginResponseDto.fromJson(apiResponse.json);

    return Result.okApi(dto, apiResponse.json);
  }
}
```

## App State
* (scoped model)https://pub.dartlang.org/packages/scoped_model
1. Modify pubspec.yml
```
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^0.1.2
  scoped_model: ^0.3.0
```
2. Run the following command
```
flutter packages get
```
3. Use the following syntax to access state
```
ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){
return ...
})
```

## models\auth.dart
```
enum AuthMode{
  Signup,
  Login
}
```

## models\product.dart
```
import 'package:flutter/material.dart';

//immutable
class Product {
  final String title;
  final String description;
  final double price;
  final String image;
  final bool isFavourite;

  final String userEmail;
  final String userId;

  Product({
    @required this.title, 
    @required this.description, 
    @required this.price, 
    @required this.image,
    @required this.userEmail,
    @required this.userId,
    this.isFavourite = false});
}
```

## scoped-models\main.dart
```
import 'package:scoped_model/scoped_model.dart';

import './common.dart';
import './products.dart';
import './user.dart';

class MainModel extends Model with UserModel, ProductsModel {
   
}
```

## scoped-models\common.dart
```
import 'package:scoped_model/scoped_model.dart';

import '../models/auth.dart';
import '../models/user.dart';
import '../models/product.dart';

import '../apis/auth.dart';
import '../apis/product.dart';
import '../shared/result.dart';

class CommonModel extends Model {
  String _selProductId;
  List<Product> _products = [];
  User _authenticatedUser;
  bool _isLoading = false;

  void triggerRender() {
    notifyListeners(); //triggers rerender like setState does
  }

  void showSpinner() {
    _isLoading = true;
    triggerRender();
  }

  void hideSpinner() {
    _isLoading = false;
    triggerRender();
  }
}

class UtilityModel extends CommonModel {
  bool get isLoading {
    return _isLoading;
  }
}

class UserModel extends CommonModel {
   Future<Result> authenticate(String email, String password, [AuthMode mode = AuthMode.Login]) async {
     showSpinner();

    try {
      ApiResult<Map<String, dynamic>> resp;
      if(mode == AuthMode.Login)
      {
         resp = await AuthApi().login(email, password);
      }
      else
      {
         resp = await AuthApi().signup(email, password);
      }

      if (!resp.success) {
        hideSpinner();
        var errorMessage = resp.data['error']['message'];

        if (errorMessage == 'EMAIL_EXISTS') {
          return Result.fail('This email already exists.');
        }
        else if (errorMessage == 'EMAIL_NOT_FOUND' || errorMessage == 'INVALID_PASSWORD') {
          return Result.fail('Invalid credentials.');
        }
       
        return Result.fail('Invalid credentials.');
      }

      hideSpinner();
      return Result.ok('Authentication succeeded');
    } catch (err) {
      hideSpinner();
      return Result.fail('Please try again!');
    }
  }
}

class ProductsModel extends CommonModel {
  bool _showFavourites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavourites) {
      return List.from(_products.where((p) => p.isFavourite).toList());
    }
    return List.from(_products);
  }

  String get selectedProductId {
    return _selProductId;
  }

  Product get selectedProduct {
    if (_selProductId == null) {
      return null;
    }
    return _products.firstWhere((p) => p.id == _selProductId);
  }

  bool get displayFavouritesOnly {
    return _showFavourites;
  }

  int get selectedProductIndex {
    return _products.indexWhere((p) => p.id == _selProductId);
  }

  Future<Null> fetchProducts() async {
    showSpinner();
    try {
      var resp = await ProductApi().fetchAll();
      if (!resp.success) {
        hideSpinner();
        return;
      }
      _products = resp.data;
      hideSpinner();
      _selProductId = null;
      return;
    } catch (err) {
      hideSpinner();
      return;
    }
  }

  Future<Result> addProduct(
      String title, String description, String image, double price) async {
    showSpinner();
    try {
      var resp = await ProductApi().add(_authenticatedUser.email,
          _authenticatedUser.id, title, description, image, price);
      if (!resp.success) {
        hideSpinner();
        return Result.fail('Please try again!');
      }

      final Product newProduct = Product(
          id: resp.data['name'].toString(),
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);

      hideSpinner();
      return Result.ok();
    } catch (err) {
      hideSpinner();
      return Result.fail('Please try again!');
    }
  }

  Future<Result> updateProduct(
      String title, String description, String image, double price) async {
    showSpinner();
    try {
      var resp = await ProductApi().update(
          selectedProduct.id,
          selectedProduct.userEmail,
          selectedProduct.userId,
          title,
          description,
          image,
          price);
      if (!resp.success) {
        hideSpinner();
        return Result.fail('Please try again!');
      }

      final updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      _products[selectedProductIndex] = updatedProduct;
      hideSpinner();
      return Result.ok();
    } catch (err) {
      hideSpinner();
      return Result.fail('Please try again!');
    }
  }

  Future<Result> deleteProduct() async {
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    showSpinner();
    try {
      var resp = await ProductApi().delete(deletedProductId);
      if (!resp.success) {
        hideSpinner();
        return Result.fail('Please try again!');
      }
      hideSpinner();
      return Result.ok();
    } catch (err) {
      hideSpinner();
      return Result.fail('Please try again!');
    }
  }

  void toggleProductFavouriteStatus() {
    final bool isCurrentlyFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavourite: newFavouriteStatus);
    _products[selectedProductIndex] = updatedProduct;
    triggerRender();
  }

  void selectProduct(String id) {
    _selProductId = id;
    triggerRender();
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    triggerRender();
  }
}

```

## main.dart with state and named routes
* Wrap MaterialApp with ScopedModel<MainModel>
```
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:scoped_model/scoped_model.dart';

import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/products.dart';
import './pages/product.dart';

import './scoped-models/main.dart';

void main() {
  debugPaintSizeEnabled = false;
  debugPaintBaselinesEnabled = false;
  debugPaintPointersEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  dynamic staticRoutes() {
    return {
      '/': (BuildContext context) => AuthPage(),
      '/products': (BuildContext context) => ProductsPage(),
      '/admin': (BuildContext context) =>
          ProductsAdminPage()
    };
  }

  Route<bool> dynamicRouteHandler(RouteSettings settings) {
    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '') {
      return null;
    }
    if (pathElements[1] == 'product') {
      final int index = int.parse(pathElements[2]);
      return MaterialPageRoute<bool>(
          builder: (BuildContext context) => ProductPage(index),);
    }
    return null;
  }

  Route<bool> unknownRouteHandler(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (BuildContext context) => ProductsPage());
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      //one instance of model
      model: MainModel(),
      child: MaterialApp(
        //debugShowMaterialGrid: true,
        theme: ThemeData(
            //fontFamily: 'Oswald',
            brightness: Brightness.light,
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple),
        //home: AuthPage(),
        routes: staticRoutes(),
        onGenerateRoute: dynamicRouteHandler,
        onUnknownRoute: unknownRouteHandler));
  }
}
```

## pages\product_edit.dart
```
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import '../shared/result.dart';

import '../models/product.dart';
import '../scoped-models/main.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg'
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildTitleTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Title',
      ),
      initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return "Title is required and should be 5+ characters long.";
        }
      },
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Description',
      ),
      initialValue: product == null ? '' : product.description,
      validator: (String value) {
        if (value.isEmpty || value.length < 10) {
          return "Description is required and should be 10+ characters long.";
        }
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
      maxLines: 4,
    );
  }

  Widget _buildProductPriceTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Price',
      ),
      initialValue: product == null ? '' : product.price.toString(),
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return "Price is required and should be a number.";
        }
      },
      onSaved: (String value) {
        //No need to call setState unless you want to rerender
        // setState(() {
        //   _priceValue = double.parse(value);
        // });
        _formData['price'] = double.parse(value);
      },
      keyboardType: TextInputType.number,
    );
  }

  void _showErrorMessage(String errorMessage)
  {
    showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(errorMessage),
                  content: Text('Please try again!'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Okay'))
                  ],
                );
              });
  }

  void _submitFormHandler(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    if (selectedProductIndex == -1) {
      addProduct(_formData['title'], _formData['description'],
              _formData['image'], _formData['price'])
          .then((Result result) {
        if (result.success) {
          Navigator.pushReplacementNamed(context, '/products')
              .then((_) => setSelectedProduct(null));
        } else {
          _showErrorMessage(result.errorMessage);
        }
      });
    } else {
      updateProduct(_formData['title'], _formData['description'],
              _formData['image'], _formData['price'])
        .then((Result result) {
        if (result.success) {
          Navigator.pushReplacementNamed(context, '/products')
              .then((_) => setSelectedProduct(null));
        } else {
          _showErrorMessage(result.errorMessage);
        }
      });
    }
  }

  Widget _buildSaveButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(child: CircularProgressIndicator())
          : RaisedButton(
              child: Text('Save'),
              textColor: Colors.white,
              onPressed: () => _submitFormHandler(
                  model.addProduct,
                  model.updateProduct,
                  model.selectProduct,
                  model.selectedProductIndex));
    });
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
        onTap: () {
          //closes form when clicking somewhere
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
            margin: EdgeInsets.all(10.0),
            child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
                  children: <Widget>[
                    _buildTitleTextField(product),
                    _buildDescriptionTextField(product),
                    _buildProductPriceTextField(product),
                    SizedBox(height: 10.0),
                    _buildSaveButton()
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      final Widget pageContent =
          _buildPageContent(context, model.selectedProduct);

      return model.selectedProductIndex == -1
          ? pageContent
          : Scaffold(
              appBar: AppBar(title: Text('Edit Product')), body: pageContent);
    });
  }
}

```

## Stateless Widget
* Create build methods to keep the build() method clean.
```
import 'package:flutter/material.dart';

import './price_tag.dart';
import './address_tag.dart';
import '../ui_elements/title_default.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int productIndex;

  ProductCard(this.product, this.productIndex);

  Widget _buildTitlePriceRow()
  {
    return ...
  }

  Widget _buildActionButtons(BuildContext context)
  {
    return ...
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
        child: Column(children: <Widget>[
      Image.asset(product['image']),
      _buildTitlePriceRow(),
      AddressTag('Union Square, San Francisco'),
      _buildActionButtons(context)
    ]));
  }
}
```

## Material Components Widgets
[Material Components Widgets](https://flutter.io/widgets/material/)

## Image widget
1. Create a new folder named assets
2. Copy images into  assets
3. Edit pubspec.yaml
4. Add image to assets:
```
  assets:
    - assets/food.jpg
```
5. Use the image with the following syntax
```
Image.asset('assets/food.jpg')
AssetImage(product.image)
Image.network('https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg')
NetworkImage(product.image)

 FadeInImage(
        image: NetworkImage(product.image), 
        height: 300.0,
        fit: BoxFit.cover,
      placeholder: AssetImage('assets/food.jpg'))
```

## Fonts
1. Create a new folder named fonts
2. Copy .ttf fonts into  assets
3. Edit pubspec.yaml
4. Add font to assets:
```
  fonts:
    - family: Oswald
      fonts:
         - asset: fonts/Oswald-Bold.ttf
           weight: 700
```
5. Use the font with the following syntax
```
Text(products[index]['title'], style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, fontFamily: 'Oswald'))
```

## Loading Indicator
```
Center(child: CircularProgressIndicator())
```

## Pull Down Refresh
* Ensure the onRefresh method returns a Future
```
RefreshIndicator(onRefresh:(){model.fetchProducts();}, child: content);
```

## List View
1. This method will render all items
```
import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  final List<String> products;

  Products([this.products = const []]){
    print('[Products Widget] Constructor');
  }

 //Using a ListView will by default RENDER all items
  @override
  Widget build(BuildContext context) {
    print('[Products Widget] build');
    return ListView(
        children: products
            .map((product) => Card(
                  child: Column(children: <Widget>[
                    Image.asset('assets/food.jpg'),
                    Text(product)
                  ]),
                ))
            .toList());
  }
}
```
2. This method will only render items on the screen
```
import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  final List<String> products;

  Products([this.products = const []]) {
    print('[Products Widget] Constructor');
  }

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
        child: Column(children: <Widget>[
      Image.asset('assets/food.jpg'),
      Text(products[index])
    ]));
  }

  @override
  Widget build(BuildContext context) {
    print('[Products Widget] build');
    return ListView.builder(
        itemBuilder: _buildProductItem, itemCount: products.length);
  }
}
```

## Navigation
1. Navigate to new page handling return value
```
        FlatButton(
            child: Text('Details'),
            onPressed: () => Navigator.pushNamed<bool>(context, '/product/' + index.toString())
                        .then((bool result) {
                            if (result)
                            {
                                deleteProduct(index);
                            }
                        }))
```
2. Navifate to named route
```
Navigator.pushReplacementNamed(context, '/admin');
```
3. Navigate to new page not allowing user to go back
```
RaisedButton(
                child: Text('LOGIN'),
                onPressed: () {
                   Navigator.pushReplacementNamed(context, '/');
                }
```				
4. Navigate back
```
    return WillPopScope(
        onWillPop: (){
          print('Back button pressed!');
          Navigator.pop(context, false);
		   //allows user to leave
            return Future.value(false);
        },
        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text('DELETE'),
                          onPressed: () => Navigator.pop(context, true)));
```

##Map Object = json
```
Map<String, String>
Map<String, String> product = {'title': 'Chocolate', 'image': 'assets/food.jpg'}
product['title']
```

## Tabs
```
import 'package:flutter/material.dart';

import './products.dart';
import './product_create.dart';
import './product_list.dart';

class ProductsAdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              AppBar(
                automaticallyImplyLeading: false,
                title: Text('Choose'),
              ),
              ListTile(
                title: Text('All Products'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ProductsPage()));
                },
              )
            ],
          ),
        ),
        //bottomNavigationBar
        appBar: AppBar(
          title: Text('Manage Products'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.create),
                text: 'Create Product',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'My Products',
              ),
            ],
          ),
        ),
        body: TabBarView(children: <Widget>[
          ProductCreatePage(),
          ProductListPage()
        ],),
      ),
    );
  }
}
```

## Dialog
```
  _showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Are you sure?'),
              content: Text('This action cannot be undone!'),
              actions: <Widget>[
                FlatButton(
                    child: Text('DISCARD'),  
                    onPressed: () {
                      //Closes dialog
                      Navigator.pop(context);
                    }),
                FlatButton(
                    child: Text('CONTINUE'),
                    onPressed: () {
                      Navigator.pop(context); 
                      Navigator.pop(context, true);
                    })
              ]);
        });
  }
 onPressed: () => _showWarningDialog(context)))
```

##Modal
```
onPressed: () {
        showModalBottomSheet(context:context, builder: (BuildContext context){
          return Center(child: Text('This is a Modal!'));
        });
      }
```

## Rows/Columns
* Expanded takes all available space
* flex property distributes space relatively
```
Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 10,
              child:Text(products[index]['title'],
                style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Oswald'))),
            SizedBox(width: 8.0),
             Expanded(
                flex: 10,
               child:Container(
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Theme.of(context).accentColor),
                child: Text('\$${products[index]['price'].toString()}',
                    style: TextStyle(color: Colors.white))))
          ],
        )
```

## Icons
1. Navigation icon
```
 ListTile(
          leading: Icon(Icons.edit),
          title: Text('Manage Products'), onTap: (){
            Navigator.pushReplacementNamed(context, '/admin');
        }) 
```

2. Icon Button
```
 IconButton(
            icon: Icon(Icons.info),
            color: Theme.of(context).accentColor,
            onPressed: () => Navigator.pushNamed<bool>(
                context, '/product/' + index.toString())),
                 IconButton(
            color: Colors.red,
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              
            })
```

## Media Queries
```
final double deviceWidth =  MediaQuery.of(context).size.width;
final targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
```

## Custom Buttons
```
 GestureDetector(
                child: Container(
                    color: Colors.green,
                    padding: EdgeInsets.all(5.0),
                    child: Text('My Button')),
                onTap: () {})
```

## Native Android Code
1. android\app\src\main\java\com\example\myapp\MainActivity.java
```
package com.example.myapp;

import android.os.Bundle;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "flutter-course.com/battery";

  private int getBatteryLevel(){
    int batteryLevel = -1;
    if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP)
    {
      BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
      batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
    }
    else
    {
      Intent intent = new ContextWrapper(getApplicationContext())
      .registerReceiver(null new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
      batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
    }

    return batteryLevel;
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    new MethodChannel(getFlutterView(), CHANNEL)
    .setMethodCallHandler(new MethodCallHandler(){
      @Override
      public void onMethodCall(MEthodCall call, Result result)
      {
        if(call.method.equals("getBatteryLevel"))
        {
          int batteryLevel = getBatteryLevel();
          if(batteryLevel != -1)
          {
            result.success(batteryLevel);
          }
          else{
            result.error("UNAVAILABLE", "Could not fetch battery level.", null);
          }
        }
        else
        {
          result.notImplemented();
        }
      }
    });
    GeneratedPluginRegistrant.registerWith(this);
  }
}
 
```
2. battery.dart
```
import 'package:flutter/services.dart';

Future<String> getBatteryLevel() async {
  final _platformChannel = MethodChannel('flutter-course.com/battery');
  String batteryLevel;
  try {
    final int result = await _platformChannel.invokeMethod('getBatteryLevel');
    batteryLevel = 'Battery level is $result %.';
  } catch (err) {
    batteryLevel = 'Failed to get battery level.';
  }
  return batteryLevel;
}
```

## iOS Native
1. ios\Runner\AppDelegate.m
```
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

#import <Flutter/Flutter.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
  FlutterMethodChannel* batteryChannel = [FlutterMethodChannel methodChannelWithName: @"flutter-course.com/battery" binaryMessenger: controller];
  [batteryChannel setMethodCallHandler: ^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"getBatteryLevel" isEqualToString:call.method]) {
      int batteryLevel = [self getBatteryLevel];

      if (batteryLevel == -1) {
        result([FlutterError errorWithCode:@"UNAVAILABLE" message:@"Battery info not available." details:nil]);
      } else {
        result(@(batteryLevel));
      }
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (int)getBatteryLevel {
  UIDevice* device = UIDevice.currentDevice;
  device.batteryMonitoringEnabled = YES;
  if (device.batteryState == UIDeviceBatteryStateUnknown) {
    return -1;
  } else {
    return (int)(device.batteryLevel * 100);
  }
}

@end
```

## Animations
* (Flutter Animations)[https://flutter.io/animations/]

## Authors

* **David Ikin**