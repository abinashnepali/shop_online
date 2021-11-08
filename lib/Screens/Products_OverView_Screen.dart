import 'package:flutter/material.dart';
import 'package:my_shop/Providers/Product_Provider.dart';
import 'package:provider/provider.dart';

import '../Widgets/ProductOverview_Screen_Grid.dart';
import '../Models/EnumFiltere.dart';
import '../Widgets/badge.dart';
import '../Providers/CartProvider.dart';
import 'Cart_Screen.dart';
import '../Widgets/app_drawer.dart';

class ProductOveriviewScreen extends StatefulWidget {
  static const routeName = '/ProductOveriviewScreen';

  @override
  _ProductOveriviewScreenState createState() => _ProductOveriviewScreenState();
}

class _ProductOveriviewScreenState extends State<ProductOveriviewScreen> {
  bool _showFavorites = false;
  bool _initState = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_initState) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<ProductProvider>(context).fetchAndSetProduct().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _initState = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Items"),
        actions: <Widget>[
          // it create pop of menu with 3 dots
          PopupMenuButton(
            onSelected: (FilterOptions selectedvalue) {
              setState(() {
                if (selectedvalue == FilterOptions.Favorites) {
                  _showFavorites = true;
                } else {
                  _showFavorites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          // Consumer is use because the cardprovier to only this Cart  widget
          Consumer<CartProvider>(
            builder: (_, cartdata, ch) => Badge(
              child: ch, //as Widget,
              value: cartdata.carditemCount.toString(),
              color: null,
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductOverviewGrid(_showFavorites),
      //  ClipRRect(
      //   borderRadius: BorderRadius.circular(10),
      //   child: new ProductOverviewGrid(),
      // ),
    );
  }
}
