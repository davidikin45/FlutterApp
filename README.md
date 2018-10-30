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
8. Open VS Code
9. Extensions 
10. Type "Flutter" and install
11. Type "Material Icon Theme", Install and activate
12. Run the following command
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
10. In VS Code Press F5 to launch or type
```
flutter run
```

## main.dart
```
import 'package:flutter/material.dart';

import './product_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.deepPurple),
        home: Scaffold(
            appBar: AppBar(
              title: Text('EasyList'),
            ),
            body: ProductManager(startingProduct: 'Food Tester')));
  }
}
```

## product_manager.dart
```
import 'package:flutter/material.dart';

import './products.dart';

class ProductManager extends StatefulWidget {
  final String startingProduct;

  ProductManager({this.startingProduct = 'Sweets Tester'}) {
    print('[ProductManager Widget] Constructor');
  }

  @override
  State<StatefulWidget> createState() {
    print('[ProductManager Widget] createState');
    return _ProductManagerState();
  }
}

class _ProductManagerState extends State<ProductManager> {
  List<String> _products = [];

  @override
  void initState() {
    print('[ProductManager State] initState');
    _products.add(widget.startingProduct);
    super.initState();
  }

  @override
  void didUpdateWidget(ProductManager oldWidget) {
    print('[ProductManager State] didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    print('[ProductManager State] build');
    return Column(children: [
      Container(
          margin: EdgeInsets.all(10.0),
          child: RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                setState(() {
                  _products.add('Advanved Food Tester');
                });
              },
              child: Text('Add Product'))),
      Products(_products)
    ]);
  }
}
```

## products.dart
```
import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  final List<String> products;

  Products([this.products = const []]){
    print('[Products Widget] Constructor');
  }

  @override
  Widget build(BuildContext context) {
    print('[Products Widget] build');
    return Column(
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

## Useful notes
* [Learn Dart](https://www.dartlang.org/)
* @override is optional
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
```

## Authors

* **David Ikin**