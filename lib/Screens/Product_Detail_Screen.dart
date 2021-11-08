import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:my_shop/Providers/Product_Provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/ProductDetailScreen';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;

    // it is  the instance of the  ProductProvider class.
    final loadProduct = Provider.of<ProductProvider>(context, listen: false);

    // final productDetails =
    //     loadProduct.firstWhere((item) => item.id == productId);
    final productDetails = loadProduct.findProductById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          productDetails.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            backgroundColor: Colors.black87,
          ),
        ),
      ),
      body: CustomScrollView(
        //SingleChildScrollView(
        slivers: <Widget>[
          SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(productDetails.title),
                background: Hero(
                  tag: productDetails.id,
                  child: Image.network(
                    productDetails.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              )),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                height: 10,
              ),
              Text(
                '\$${productDetails.price}',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '\$${productDetails.description}',
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ]),
          ),
        ],
        // child: Column(
        //   children: [
        //     Container(
        //       height: 400,
        //       width: double.infinity,
        //       padding: const EdgeInsets.all(2),
        //       child:
        //     ),

        //   ],
        // ),
      ),
    );
  }
}
