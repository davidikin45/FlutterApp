import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import './price_tag.dart';
import './address_tag.dart';
import '../ui_elements/title_default.dart';
import '../../models/product.dart';
import '../../scoped-models/main.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard(this.product);

  Widget _buildTitlePriceRow() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(child: TitleDefault(product.title)),
          Flexible(child: SizedBox(width: 8.0)),
          Flexible(child: PriceTag(product.price.toString()))
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ButtonBar(alignment: MainAxisAlignment.center, children: <Widget>[
        IconButton(
            icon: Icon(Icons.info),
            color: Theme.of(context).accentColor,
            onPressed: (){ 
              model.selectProduct(product.id);
              Navigator.pushNamed<bool>(
                context, '/product/' + product.id).then((_){
                   model.selectProduct(null);
                });}),
        IconButton(
            color: Colors.red,
            icon: Icon(product.isFavourite
                ? Icons.favorite
                : Icons.favorite_border),
            onPressed: () {
              model.selectProduct(product.id);
              model.toggleProductFavouriteStatus();
            })
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
            tag: product.id,
            child: FadeInImage(
              image: NetworkImage(product.imageUrl),
              height: 300.0,
              fit: BoxFit.cover,
              placeholder: AssetImage('assets/food.jpg'),
            ),
          ),
          _buildTitlePriceRow(),
          SizedBox(height: 10.0),
          AddressTag(product.locAddress),
          _buildActionButtons(context)
        ],
      ),
    );
  }
}
