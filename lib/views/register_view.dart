import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_flutter/constants/routes.dart';
import 'package:todo_app_flutter/utils/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text("Register"),
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
            onPressed: register,
            child: const Text("Register"),
          ),
          TextButton(
            onPressed: navigateToLoginView,
            child: const Text("Already registered? Login here!"),
          )
        ],
      ),
    );
  }

  void register() async {
    final email = _email.text;
    final password = _password.text;
    try {
      final auth = FirebaseAuth.instance;
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await auth.currentUser?.sendEmailVerification();
      navigateToVerifyEmailView();
    } on FirebaseAuthException catch (e) {
      await showErrorDialog(context, e.code);
    }
  }

  void navigateToVerifyEmailView() {
    Navigator.of(context).pushNamed(verifyEmailRoute);
  }

  void navigateToLoginView() {
    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
  }
}
