import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_bloc.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_event.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_state.dart';

@RoutePage()
class CompleteGoogleProfilePage extends StatefulWidget {
  final String userId;
  final String email;
  final String? name;
  final String? avatarUrl;

  const CompleteGoogleProfilePage({
    super.key,
    required this.userId,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  @override
  State<CompleteGoogleProfilePage> createState() => _CompleteGoogleProfilePageState();
}

class _CompleteGoogleProfilePageState extends State<CompleteGoogleProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _countryController = TextEditingController();
  
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365 * 18));

  @override
  void initState() {
    super.initState();
    
    // Precompila il nome se disponibile dall'account Google
    if (widget.name != null) {
      final nameParts = widget.name!.split(' ');
      if (nameParts.isNotEmpty) {
        _nameController.text = nameParts.first;
        if (nameParts.length > 1) {
          _surnameController.text = nameParts.sublist(1).join(' ');
        }
      }
    }
    
    // Usa l'indirizzo email come username predefinito
    final emailParts = widget.email.split('@');
    if (emailParts.isNotEmpty) {
      _usernameController.text = emailParts.first;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _onCompleteProfilePressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        CompleteGoogleProfileEvent(
          userId: widget.userId,
          username: _usernameController.text.trim(),
          nome: _nameController.text.trim(),
          cognome: _surnameController.text.trim(),
          dataDiNascita: _birthDate,
          citta: _cityController.text.trim(),
          provincia: _provinceController.text.trim(),
          stato: _countryController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa il tuo profilo'),
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
          } else if (state is AuthenticatedState) {
            // Redirect to home after successful profile completion
            context.router.replaceNamed('/home');
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
                  // Header
                  if (widget.avatarUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(widget.avatarUrl!),
                      ),
                    ),
                  Text(
                    'Completa il tuo profilo',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Sei autenticato come ${widget.email}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un username';
                      }
                      if (value.length < 3) {
                        return 'L\'username deve avere almeno 3 caratteri';
                      }
                      return null;
                    },
                    enabled: state is! AuthLoadingState,
                  ),
                  const SizedBox(height: 16),
                  
                  // Personal Information
                  const Text(
                    'Informazioni personali',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci il tuo nome';
                      }
                      return null;
                    },
                    enabled: state is! AuthLoadingState,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _surnameController,
                    decoration: const InputDecoration(
                      labelText: 'Cognome',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci il tuo cognome';
                      }
                      return null;
                    },
                    enabled: state is! AuthLoadingState,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: state is AuthLoadingState
                        ? null
                        : () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Data di nascita',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(
                          text: '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleziona la tua data di nascita';
                          }
                          return null;
                        },
                        enabled: state is! AuthLoadingState,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Location Information
                  const Text(
                    'Informazioni sulla località',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Città',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci la tua città';
                      }
                      return null;
                    },
                    enabled: state is! AuthLoadingState,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _provinceController,
                    decoration: const InputDecoration(
                      labelText: 'Provincia',
                      prefixIcon: Icon(Icons.map),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci la tua provincia';
                      }
                      return null;
                    },
                    enabled: state is! AuthLoadingState,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Paese',
                      prefixIcon: Icon(Icons.public),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci il tuo paese';
                      }
                      return null;
                    },
                    enabled: state is! AuthLoadingState,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: state is AuthLoadingState ? null : _onCompleteProfilePressed,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: state is AuthLoadingState
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Completa Registrazione',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
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