import 'package:flutter/material.dart';

import '../Providers/Product_Provider.dart';
import '../Screens/AddEdit_Screen.dart';
import 'package:provider/provider.dart';

class ProductScreenItem extends StatelessWidget {
  final String id;

  final String title;
  final String imageUrl;

  ProductScreenItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Card(
      child: ListTile(
        title: Text(
          title,
          //style: Theme.of(context).textTheme.bodyText1,
        ),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        trailing: Container(
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                color: Theme.of(context).buttonColor,
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(AddEditProductScreen.routeName, arguments: id);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).errorColor,
                onPressed: () async {
                  try {
                    await Provider.of<ProductProvider>(context, listen: false)
                        .deleteProduct(id);
                  } catch (error) {
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Deleting Failed!!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
