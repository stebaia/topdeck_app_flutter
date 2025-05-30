import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_operations_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_operations_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_state.dart';

/// Dialog for joining a tournament using an invite code
class JoinTournamentDialog extends StatefulWidget {
  const JoinTournamentDialog({super.key});

  @override
  State<JoinTournamentDialog> createState() => _JoinTournamentDialogState();
}

class _JoinTournamentDialogState extends State<JoinTournamentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TournamentOperationsBloc, TournamentOperationState>(
      listener: (context, state) {
        if (state is TournamentJoinedState) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ti sei unito al torneo "${state.tournament.name}"!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is TournamentOperationErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner),
            SizedBox(width: 8),
            Text('Unisciti al Torneo'),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inserisci il codice invito per unirti a un torneo privato.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Codice Invito',
                  hintText: 'Es. ABC12345',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Il codice invito è obbligatorio';
                  }
                  if (value.trim().length < 6) {
                    return 'Il codice deve essere di almeno 6 caratteri';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _joinTournament(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Il codice invito ti è stato fornito dal creatore del torneo.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          BlocBuilder<TournamentOperationsBloc, TournamentOperationState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is JoiningTournamentState ? null : _joinTournament,
                child: state is JoiningTournamentState
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Unisciti'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _joinTournament() {
    if (_formKey.currentState!.validate()) {
      final code = _codeController.text.trim().toUpperCase();
      context.read<TournamentOperationsBloc>().add(JoinTournamentByCodeOperationEvent(code));
    }
  }
} 