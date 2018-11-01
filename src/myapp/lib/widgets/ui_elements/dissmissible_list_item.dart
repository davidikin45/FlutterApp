import 'package:flutter/material.dart';

class DismissibleListItem extends StatelessWidget {
  final String keyValue;
  final Widget listItem;
  final Function onDismissed;

  DismissibleListItem(this.listItem, this.keyValue, this.onDismissed);

  @override
  Widget build(BuildContext context) {
     return Dismissible(
        background: Container(color: Colors.red),
        onDismissed:(DismissDirection direction) => onDismissed(direction),
        key:  Key(keyValue),
        child: Column(children: <Widget>[listItem, Divider()]));
  }
}
