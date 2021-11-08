import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/Product_Provider.dart';
import '../Widgets/ProductScreen_Items.dart';
import '../Widgets/app_drawer.dart';
import 'AddEdit_Screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/UserProductScreen';

  Future<void> _refreshProduct(BuildContext context) async {
    final res = await Provider.of<ProductProvider>(context, listen: false)
        .fetchAndSetProduct(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productobj = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Manages Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AddEditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProduct(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProduct(context),
                    child: Consumer<ProductProvider>(
                      builder: (ctx, productobj, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                            itemCount: productobj.items.length,
                            itemBuilder: (_, i) => Column(
                                  children: [
                                    ProductScreenItem(
                                      productobj.items[i].id,
                                      productobj.items[i].title,
                                      productobj.items[i].imageUrl,
                                    ),
                                    Divider(),
                                  ],
                                )),
                      ),
                    ),
                  ),
      ),
    );
  }
}
