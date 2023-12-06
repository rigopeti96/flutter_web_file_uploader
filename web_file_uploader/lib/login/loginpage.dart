import 'package:flutter/material.dart';
import 'package:homework/createuser/createuser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import '../../main.dart';
import 'logindataresponse.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<LoginDataResponse> login(BuildContext context, L10n l10n) async{
    try{
      final response = await http.post(
        Uri.parse('http://192.168.0.171:8080/api/auth/signin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        LoginDataResponse loginResponse = LoginDataResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        jwtToken = loginResponse.accessToken;
        userName = loginResponse.employeename;
        _showToast(context, l10n.loginSuccessMessage, l10n.okButton);
        Navigator.of(context).pop();
        return loginResponse;
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        throw Exception('Failed to login.');
      }
    } on Exception catch (e) {
      print(e);
      _showToast(context, l10n.connectionErrorMessage, l10n.okButton);
      throw Exception('Failed to connect.');
    }

  }

  void _showToast(BuildContext context, String message, String okButton) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: okButton, onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final L10n? l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n!.loginTitle)),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/splash.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: l10n.userNameTag,
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: l10n.passwordTag,
                    filled: true,
                    fillColor: Colors.white
                ),
              ),
              ElevatedButton(
                child: Text(l10n.loginButton),
                onPressed: (){
                  login(context, l10n);
                  //Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text(l10n.createUserBack),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}