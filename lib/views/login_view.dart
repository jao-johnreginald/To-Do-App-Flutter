import 'package:flutter/material.dart';
import 'package:todo_app_flutter/constants/routes.dart';
import 'package:todo_app_flutter/services/auth/auth_exceptions.dart';
import 'package:todo_app_flutter/services/auth/auth_service.dart';
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
            onPressed: logIn,
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

  void logIn() async {
    final email = _email.text;
    final password = _password.text;
    try {
      await AuthService.firebase().logIn(email: email, password: password);
      final user = AuthService.firebase().currentUser;
      if (user?.isEmailVerified ?? false) {
        navigate(todosRoute);
      } else {
        navigate(verifyEmailRoute);
      }
    } on UserNotFoundException {
      await showErrorDialog(context, "User not found");
    } on WrongPasswordException {
      await showErrorDialog(context, "Wrong credentials");
    } on GenericException {
      await showErrorDialog(context, "Authentication error");
    }
  }

  void navigate(String route) {
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }
}
