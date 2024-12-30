import 'package:flutter/material.dart';
import 'package:todo_app_flutter/constants/routes.dart';
import 'package:todo_app_flutter/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify email"),
      ),
      body: Column(
        children: [
          const Text(
            "An email verification link was sent to your email. Please click on the link to verify your email.\nIf you haven't received a verification email yet, Please click on the button below.",
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text("Send email verification"),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              navigateToLoginView();
            },
            child: const Text("Back to register screen"),
          )
        ],
      ),
    );
  }

  void navigateToLoginView() {
    Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (_) => false);
  }
}
