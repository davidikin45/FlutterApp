import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:map_view/map_view.dart';

import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/products.dart';
import './pages/product.dart';

import './models/product.dart';
import './scoped-models/main.dart';

import './widgets/helpers/custom_route.dart';

import './shared/keys.dart' as keys;
import './shared/config.dart' as config;

void main() {
  debugPaintSizeEnabled = false;
  debugPaintBaselinesEnabled = false;
  debugPaintPointersEnabled = false;
  MapView.setApiKey(keys.googleApiKey);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;



  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        //triggers rerender
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  dynamic staticRoutes() {
    return {
      '/': (BuildContext context) =>
          !_isAuthenticated ? AuthPage() : ProductsPage(_model),
      '/admin': (BuildContext context) => !_isAuthenticated ? AuthPage() : ProductsAdminPage(_model)
    };
  }

  Route<bool> dynamicRouteHandler(RouteSettings settings) {
    if(!_isAuthenticated)
    {
      return MaterialPageRoute<bool>(
        builder: (BuildContext context) => AuthPage()
      );
    }

    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '') {
      return null;
    }
    if (pathElements[1] == 'product') {
      final String id = pathElements[2];
      final Product product = _model.allProducts.firstWhere((p) => p.id == id);
      return CustomRoute<bool>(
        builder: (BuildContext context) => !_isAuthenticated ? AuthPage() : ProductPage(product),
      );
    }
    return null;
  }

  Route<bool> unknownRouteHandler(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (BuildContext context) => !_isAuthenticated ? AuthPage() : ProductsPage(_model));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
        //one instance of model
        model: _model,
        child: MaterialApp(
            title: config.appTitle,
            //debugShowMaterialGrid: true,
            theme: config.getAdaptiveThemeData(context),
            //home: AuthPage(),
            routes: staticRoutes(),
            onGenerateRoute: (RouteSettings settings) =>
                dynamicRouteHandler(settings),
            onUnknownRoute: (RouteSettings settings) =>
                unknownRouteHandler(settings)));
  }
}
