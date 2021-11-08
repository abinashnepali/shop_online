import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token!;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<bool> tryAutoLogin() async {
    final pres = await SharedPreferences.getInstance();

    if (!pres.containsKey('userData')) {
      return false;
    }
    //  final responseData = pres.getString('userData') as String;
    final userDataextracted = json.decode(pres.getString('userData') as String)
        as Map<String, Object>;
    _expiryDate = DateTime.parse(userDataextracted['expiryDate'] as String);
    if (_expiryDate!.isBefore(DateTime.now())) {
      return false;
    }
    _token = userDataextracted['token'] as String;
    _userId = userDataextracted['userId'] as String;
    notifyListeners();
    _autologOut();
    return true;
  }

  Future<void> _auhthneated(
      String? email, String? password, String link) async {
    Uri url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$link?key=AIzaSyD-BgadeSVgfTIz0SSvLIE2l4LN3Ifb7kY');

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'].toString();
      print('token: $_token');
      _userId = responseData['localId'];
      var expertime = responseData['expiresIn'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(expertime)));
      _autologOut();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String()
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String? email, String? password) async {
    final String link = 'signUp';
    return _auhthneated(email, password, link);
    // Uri url = Uri.parse(
    //     'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyD-BgadeSVgfTIz0SSvLIE2l4LN3Ifb7kY');

    // try {
    //   final response = await http.post(url,
    //       body: json.encode({
    //         'email': email,
    //         'password': password,
    //         'returnSecureToken': true,
    //       }));
    //   print(json.decode(response.body));
    //   if (response.statusCode >= 400) {
    //     print('Something is wrong');
    //   }
    // } catch (error) {
    //   throw error;
    // }
  }

  Future<void> login(String? email, String? password) async {
    final String link = 'signInWithPassword';
    return _auhthneated(email, password, link);
    // Uri url = Uri.parse(
    //     'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyD-BgadeSVgfTIz0SSvLIE2l4LN3Ifb7kY');
    // final response = await http.post(url,
    //     body: json.encode({
    //       'email': email,
    //       'password': password,
    //       'returnSecureToken': true,
    //     }));
    // if (response.statusCode >= 400) {
    //   return;
    // }
    // print(json.decode(response.body));
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    notifyListeners();
    final pres = await SharedPreferences.getInstance();
    // it will remove only userdata
    // pres.remove('userData');
    // it wil clear all  data store on the devices
    pres.clear();
  }

  void _autologOut() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timetoExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timetoExpiry), logout);
  }
}
