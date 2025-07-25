import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/auth/auth_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/auth/auth_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/auth/auth_state.dart';

@RoutePage()
class ConfirmNewPasswordPage extends StatefulWidget {
  const ConfirmNewPasswordPage({super.key});

  @override
  State<ConfirmNewPasswordPage> createState() => _ConfirmNewPasswordPageState();
}

class _ConfirmNewPasswordPageState extends State<ConfirmNewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm New Password'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ConfirmNewPasswordSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password confermata con successo')),
            );
            context.pushRoute(const LoginPageRoute());
          }
        },
        child: Column(
          children: [
            Text('Inserisci la nuova password'),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _getErrorMessage(),
              ),
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Conferma Password',
                errorText: _getErrorMessage(),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  context.read<AuthBloc>().add(ConfirmNewPasswordEvent(
                        password: _passwordController.text,
                        confirmPassword: _confirmPasswordController.text,
                      )),
              child: Text('Conferma'),
            )
          ],
        ),
      ),
    );
  }

  String _getErrorMessage() {
    print(
        'context.watch<AuthBloc>().state: ${context.watch<AuthBloc>().state}');
    switch (context.watch<AuthBloc>().state) {
      case ConfirmNewPasswordEmptyErrorState():
        return 'Password non può essere vuota';
      case ConfirmNewPasswordMismatchErrorState():
        return 'Le password non corrispondono';
      case ConfirmNewPasswordValidationErrorState():
        return 'Password non valida';
      case ConfirmNewPasswordErrorState():
        return 'Errore durante la conferma della nuova password';
      default:
        return '';
    }
  }
}
