import 'dart:developer' as dartdev show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Email"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Password"),
          ),
          TextButton(
            onPressed: login,
            child: const Text("Login"),
          ),
          TextButton(
            onPressed: navigateToRegisterView,
            child: const Text("Not registered yet? Register here!"),
          )
        ],
      ),
    );
  }

  void login() async {
    final email = _email.text;
    final password = _password.text;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      navigateToTodosView();
    } on FirebaseAuthException catch (e) {
      dartdev.log(e.code);
    }
  }

  void navigateToTodosView() {
    Navigator.of(context).pushNamedAndRemoveUntil("/todos/", (_) => false);
  }

  void navigateToRegisterView() {
    Navigator.of(context).pushNamedAndRemoveUntil("/register/", (_) => false);
  }
}
