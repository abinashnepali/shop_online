import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart';
import 'package:my_shop/Models/http_Exception.dart';
import 'package:my_shop/Providers/authProvider.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/authscreen';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.title!.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _animController;
  late Animation<Offset> _slideanimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideanimation = Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.bounceIn));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    ));

    //coz using animatedbuilder listern is not necessary
    // _heightanimation.addListener(() {
    //   setState(() {});
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animController.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An Error Occured!'),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.pop(ctx);
                    })
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    final authProvObj = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_authMode == AuthMode.Login) {
        await authProvObj.login(_authData['email'], _authData['password']);
      } else {
        await authProvObj.signup(_authData['email'], _authData['password']);
      }
    } on HtppException catch (error) {
      var errormessage = 'Authenticate Failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errormessage = 'The email address is already in use.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errormessage = 'Invalid Email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errormessage = 'Invalid  User Name Or Email.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errormessage = 'The Password is too weak!!';
      }
      _showErrorDialog(errormessage);
    } catch (error) {
      var errormessage = 'Could not authenticate you.Please try Again Later';
      _showErrorDialog(errormessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _animController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: // AnimatedBuilder(
            //   animation: _heightanimation,
            //   builder: (ctx, ch) =>
            AnimatedContainer(
          duration: Duration(microseconds: 300),
          curve: Curves.easeIn,
          height: _authMode == AuthMode.Signup ? 320 : 260,
          //height: _heightanimation.value.height,
          constraints: BoxConstraints(
              minHeight: _authMode == AuthMode.Signup ? 320 : 260),
          width: deviceSize.width * 0.75,
          padding: EdgeInsets.all(16.0),
          //child: ch),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'E-Mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Invalid email!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value as String;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 5) {
                        return 'Password is too short!';
                      }
                    },
                    onSaved: (value) {
                      _authData['password'] = value as String;
                    },
                  ),
                  // if (_authMode == AuthMode.Signup)
                  AnimatedContainer(
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                        maxHeight: _authMode == AuthMode.Signup ? 120 : 0),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideanimation,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.Signup,
                          decoration:
                              InputDecoration(labelText: 'Confirm Password'),
                          obscureText: true,
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match!';
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    RaisedButton(
                      child: Text(
                          _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                      onPressed: _submit,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).primaryColor,
                      textColor:
                          Theme.of(context).primaryTextTheme.button!.color,
                    ),
                  Text(
                    '${_authMode == AuthMode.Login ? 'Create Account.' : 'Click Here to Login'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  FlatButton(
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'}'),
                    onPressed: _switchAuthMode,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          //) //AnimatedBulider
        ));
  }
}
