import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/OrderProvider.dart';
import '../Widgets/Order_Screen_item.dart';
import '../Widgets/app_drawer.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/OrderScreen';

  @override
  Widget build(BuildContext context) {
    //  final orderObj = Provider.of<OrderProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Order Details'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: Provider.of<OrderProvider>(context, listen: false)
                .fetchAndSetOrders(),
            builder: (ctx, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (dataSnapshot.error != null) {
                return Center(
                  child: Text('An error Ocurred!'),
                );
              } else {
                return Consumer<OrderProvider>(
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.getOrderItems.length,
                    itemBuilder: (ctx, i) =>
                        OrderItemScreen(orderData.getOrderItems[i]),
                  ),
                );
              }
            }));
  }
}
