import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_flutter/constants/routes.dart';
import 'package:todo_app_flutter/utils/show_error_dialog.dart';

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
            onPressed: () {
              navigate(registerRoute);
            },
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
      final auth = FirebaseAuth.instance;
      await auth.signInWithEmailAndPassword(email: email, password: password);
      if (auth.currentUser?.emailVerified ?? false) {
        navigate(todosRoute);
      } else {
        navigate(verifyEmailRoute);
      }
    } on FirebaseAuthException catch (e) {
      await showErrorDialog(context, e.code);
    }
  }

  void navigate(String route) {
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }
}
