import 'package:flutter/material.dart';
import 'package:todo_app_flutter/constants/routes.dart';
import 'package:todo_app_flutter/services/auth/auth_service.dart';
import 'package:todo_app_flutter/views/login_view.dart';
import 'package:todo_app_flutter/views/register_view.dart';
import 'package:todo_app_flutter/views/todos_view.dart';
import 'package:todo_app_flutter/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        todosRoute: (context) => const TodosView()
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const TodosView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return Scaffold(
              appBar: AppBar(title: const Text("Loading")),
              body: const Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}
