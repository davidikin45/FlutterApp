import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../pages/product_edit.dart';
import '../widgets/ui_elements/dissmissible_list_item.dart';

import '../models/product.dart';
import '../scoped-models/main.dart';

class ProductListPage extends StatefulWidget {
  final MainModel model;

  ProductListPage(this.model);

@override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProductListPageState();
  }
}

class _ProductListPageState extends State<ProductListPage>{
  @override
  initState()
  {
    widget.model.fetchProducts(onlyForUser: true);
    super.initState();
  }

  Widget _buildDismissableListItem(BuildContext context, Widget listItem,
      int index, String key, MainModel model) {
    return DismissibleListItem(
        listItem,
        key,
        (DismissDirection direction) =>
            onSwipe(direction, index, model));
  }

  Widget _buildListItem(BuildContext context, int index, Product product, MainModel model) {
    return ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(product.image)),
        title: Text(product.title),
        subtitle: Text('\$${product.price.toString()}'),
        trailing: _buildEditButton(context, index, model));
  }

  void onSwipe(DismissDirection direction, int index, MainModel model) {
    if (direction == DismissDirection.endToStart) {
      model.selectProduct(model.allProducts[index].id);
      model.deleteProduct();
    }
    //left to right
    else if (direction == DismissDirection.startToEnd) {}
  }

  Widget _buildEditButton(BuildContext context, int index,  MainModel model) {
     return IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              model.selectProduct(model.allProducts[index].id);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return ProductEditPage();
              })).then((_){
                model.selectProduct(null);
              });
            });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return _buildDismissableListItem(
                  context,
                  _buildListItem(context, index, model.allProducts[index], model),
                  index,
                  model.allProducts[index].title,
                  model);
            },
            itemCount: model.allProducts.length);
      },
    );
  }
}
