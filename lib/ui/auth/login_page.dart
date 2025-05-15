import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_bloc.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_event.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_state.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Check if already authenticated
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      // Redirect to home on the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('User already authenticated, redirecting to home...');
        context.router.replaceNamed('/home');
      });
    } else {
      print('User not authenticated, staying on login page');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignInEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }
  
  void _onGoogleLoginPressed() {
    context.read<AuthBloc>().add(SignInWithGoogleNativelyEvent());
  }

  void _onGoogleOAuthLoginPressed() {
    context.read<AuthBloc>().add(SignInWithGoogleEvent());
  }

  void _onForgotPasswordPressed() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email first'),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          ResetPasswordEvent(
            email: _emailController.text.trim(),
          ),
        );
  }

  void _navigateToRegister() {
    context.router.pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PasswordResetSentState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password reset email sent to ${state.email}'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthenticatedState) {
            // Navigate to home or dashboard
            print('Authentication successful! Redirecting to home...');
            context.router.replaceNamed('/home');
          } else if (state is GoogleAuthenticatedNeedsProfileState) {
            // Naviga alla pagina di completamento profilo
            print('Google authentication successful, redirecting to profile completion page...');
            context.router.navigate(
              CompleteGoogleProfilePageRoute(
                userId: state.userId,
                email: state.email,
                name: state.name,
                avatarUrl: state.avatarUrl,
              ),
            );
          } else if (state is UnauthenticatedState) {
            // Log state change
            print('User is unauthenticated, staying on login page');
          } else if (state is AuthLoadingState) {
            // Log loading state
            print('Authentication in progress...');
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.sports_esports,
                        size: 100,
                        color: Colors.blue,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    enabled: state is! AuthLoadingState,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    enabled: state is! AuthLoadingState,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state is AuthLoadingState ? null : _onLoginPressed,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: state is AuthLoadingState
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Google Sign In Button (Nativo)
                  ElevatedButton.icon(
                    onPressed: state is AuthLoadingState ? null : _onGoogleLoginPressed,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: state is AuthLoadingState
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Caricamento...', style: TextStyle(fontSize: 16)),
                              ],
                            )
                          : const Text(
                              'Accedi con Google (Nativo)',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  TextButton(
                    onPressed: state is AuthLoadingState
                        ? null
                        : _onForgotPasswordPressed,
                    child: const Text('Forgot Password?'),
                  ),
                  const Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: state is AuthLoadingState
                            ? null
                            : _navigateToRegister,
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 