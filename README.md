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
```
11. In VS Code Press F5 to launch or type
```
flutter run
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

## main.dart with named routes
```
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/products.dart';
import './pages/product.dart';

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
  List<Map<String, dynamic>> _products = [];

  void _addProduct(Map<String, dynamic> product) {
    setState(() {
      _products.add(product);
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  dynamic staticRoutes() {
    return {
      '/': (BuildContext context) => AuthPage(),
      '/products': (BuildContext context) => ProductsPage(_products),
      '/admin': (BuildContext context) =>
          ProductsAdminPage(_addProduct, _deleteProduct)
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
          builder: (BuildContext context) => ProductPage(
              _products[index]['title'],
                _products[index]['image'],
                _products[index]['price'],
                _products[index]['description']),);
    }
    return null;
  }

  Route<bool> unknownRouteHandler(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (BuildContext context) => ProductsPage(_products));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        onUnknownRoute: unknownRouteHandler);
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

## Authors

* **David Ikin**