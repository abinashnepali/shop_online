import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Screens/Product_Detail_Screen.dart';
import '../Providers/Product.dart';
import '../Providers/CartProvider.dart';
import '../Providers/authProvider.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productItem = Provider.of<Product>(context, listen: false);
    final authProvObj = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvObj.token as String;
    final userId = authProvObj.userId as String;
    final cartObj = Provider.of<CartProvider>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: productItem.id);
          },
          child: Hero(
            tag: productItem.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/prodcutplaceholder.png'),
              image: NetworkImage(productItem.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          // Image.network(
          //   productItem.imageUrl,
          //   fit: BoxFit.cover,
          // ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              icon: Icon(
                productItem.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: Theme.of(context).indicatorColor,
              onPressed: () {
                productItem.toggleFavoriteStatus(token, userId);
              },
            ),
            //child: Text('Never Changes'),
          ),
          title: Text(
            productItem.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              color: Theme.of(context).indicatorColor,
              onPressed: () {
                cartObj.addItemsOnCard(
                    productItem.id, productItem.title, productItem.price);
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Added Items  to Cart!!'),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cartObj.removeSingleItem(productItem.id);
                    },
                  ),
                ));
              }),
        ),
      ),
    );
  }
}
