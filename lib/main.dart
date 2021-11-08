import 'package:flutter/material.dart';
import 'package:my_shop/Providers/Product.dart';
import 'package:provider/provider.dart';

import 'Providers/CartProvider.dart';
import 'Providers/OrderProvider.dart';
import 'Providers/Product_Provider.dart';
import 'Providers/authProvider.dart';
import 'Screens/AddEdit_Screen.dart';
import 'Screens/Orders_Screen.dart';
import 'Screens/Product_Detail_Screen.dart';
import 'Screens/Products_OverView_Screen.dart';
import 'Screens/Cart_Screen.dart';
import 'Screens/User_Product_Screen.dart';
import 'Screens/auth_screen.dart';
import 'Screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        // when the AuthProvider change the ProducrPro will also change the instace of AuthProvider is authprov

        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => null,
          update: (ctx, authprov, prevoiusproducts) => ProductProvider(
              authprov.token as String,
              prevoiusproducts != null ? prevoiusproducts.items : [],
              authprov.userId as String),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartProvider(),
        ),

        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => null,
          update: (ctx, authprover, prevoiusorder) => OrderProvider(
            authprover.token as String,
            prevoiusorder != null ? prevoiusorder.getOrderItems : [],
            authprover.userId as String,
          ),
        ),
        // ChangeNotifierProvider(
        //   create: (ctx) => OrderProvider(),
        // ),
      ],
      child: Consumer<AuthProvider>(
          builder: (ctx, auth, _) => MaterialApp(
                title: 'MyShop',
                theme: ThemeData(
                  primaryColor: Color.fromRGBO(24, 154, 180, 1),
                  accentColor: Color.fromRGBO(117, 230, 218, 1),
                  canvasColor: Color.fromRGBO(248, 250, 253, 1),
                  buttonColor: Color.fromRGBO(108, 194, 138, 1),
                  indicatorColor: Color.fromRGBO(253, 121, 36, 1),
                  fontFamily: 'Lato',

                  //back color rgb(212,241,244) rgb(163,235,177)
                  textTheme: ThemeData.light().textTheme.copyWith(
                        bodyText1: TextStyle(
                            fontSize: 17, color: Color.fromRGBO(20, 51, 51, 1)),
                        bodyText2:
                            TextStyle(color: Color.fromRGBO(20, 51, 51, 1)),
                        headline6: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lato',
                        ),
                      ),
                ),
                // if auth is true then  load ProductOveriviewScreen  else load AuthScreen
                home: auth.isAuth
                    ? ProductOveriviewScreen()
                    : FutureBuilder(
                        future: auth.tryAutoLogin(),
                        builder: (ctx, authResultsnapdata) =>
                            authResultsnapdata.connectionState ==
                                    ConnectionState.waiting
                                ? SplashScreen()
                                : AuthScreen(),
                      ),
                routes: {
                  AuthScreen.routeName: (ctx) => AuthScreen(),
                  ProductOveriviewScreen.routeName: (ctx) =>
                      ProductOveriviewScreen(),
                  ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                  CartScreen.routeName: (ctx) => CartScreen(),
                  OrderScreen.routeName: (ctx) => OrderScreen(),
                  UserProductScreen.routeName: (ctx) => UserProductScreen(),
                  AddEditProductScreen.routeName: (ctx) =>
                      AddEditProductScreen(),
                },
              )),
    );
  }
}
