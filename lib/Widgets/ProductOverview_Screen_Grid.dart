import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Widgets/Product_Item_Grid.dart';
import '../Providers/Product_Provider.dart';

class ProductOverviewGrid extends StatelessWidget {
  final bool _showFavorites;

  ProductOverviewGrid(this._showFavorites);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    final loadProduct =
        _showFavorites ? productData.FavoritesItems : productData.items;
    return GridView.builder(
      padding: EdgeInsets.all(12),
      itemCount: loadProduct.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        // create: (ctx) => loadProduct[index],
        value: loadProduct[index],
        child: ProductItem(
            //  loadProduct[index].id,
            //   loadProduct[index].title, loadProduct[index].imageUrl

            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .95,
        crossAxisSpacing: 10,
      ),
    );
  }
}
