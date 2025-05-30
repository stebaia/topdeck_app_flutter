import 'package:flutter/material.dart';
import 'package:topdeck_app_flutter/utils/password_validator.dart';

/// Widget per mostrare la forza della password e i suggerimenti
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showSuggestions;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showSuggestions = true,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final validationResult = PasswordValidator.validate(password);
    final strength = validationResult.strength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra di forza della password
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength.score,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(strength.colorValue),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength.label,
              style: TextStyle(
                color: Color(strength.colorValue),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),

        // Messaggi di errore
        if (validationResult.errors.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...validationResult.errors.map((error) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.close,
                      color: Colors.red[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        validationResult.getErrorMessage(error),
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],

        // Suggerimenti per migliorare la password
        if (showSuggestions && validationResult.errors.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Suggerimenti per migliorare:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          ...PasswordValidator.generateSuggestions(validationResult)
              .map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
        ],

        // Indicatore di successo
        if (validationResult.isValid) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Password sicura!',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Widget per un campo password con validazione integrata
class ValidatedPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool showStrengthIndicator;
  final bool showSuggestions;
  final ValueChanged<PasswordValidationResult>? onValidationChanged;
  final FormFieldValidator<String>? additionalValidator;

  const ValidatedPasswordField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.showStrengthIndicator = true,
    this.showSuggestions = true,
    this.onValidationChanged,
    this.additionalValidator,
  });

  @override
  State<ValidatedPasswordField> createState() => _ValidatedPasswordFieldState();
}

class _ValidatedPasswordFieldState extends State<ValidatedPasswordField> {
  bool _obscureText = true;
  PasswordValidationResult? _lastValidationResult;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPasswordChanged);
    super.dispose();
  }

  void _onPasswordChanged() {
    final password = widget.controller.text;
    final validationResult = PasswordValidator.validate(password);

    if (_lastValidationResult != validationResult) {
      _lastValidationResult = validationResult;
      widget.onValidationChanged?.call(validationResult);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: widget.labelText ?? 'Password',
            hintText: widget.hintText,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Inserisci una password';
            }

            final validationResult = PasswordValidator.validate(value);
            if (!validationResult.isValid) {
              return validationResult.errorMessages.first;
            }

            return widget.additionalValidator?.call(value);
          },
        ),
        if (widget.showStrengthIndicator) ...[
          const SizedBox(height: 12),
          PasswordStrengthIndicator(
            password: widget.controller.text,
            showSuggestions: widget.showSuggestions,
          ),
        ],
      ],
    );
  }
}

/// Widget per confermare la password
class PasswordConfirmationField extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? labelText;
  final String? hintText;

  const PasswordConfirmationField({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    this.labelText,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: confirmPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: labelText ?? 'Conferma Password',
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        return PasswordValidator.validatePasswordConfirmation(
          passwordController.text,
          value ?? '',
        );
      },
    );
  }
}
